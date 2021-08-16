import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;

class CoolPaginatedListView<T> extends StatefulWidget {
  const CoolPaginatedListView({
    Key? key,
    required this.pagination,
    required this.perPage,
    required this.itemBuilder,
    required this.separatorBuilder,
  }) : super(key: key);

  final ntucool.Pagination<T> pagination;
  final int perPage;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;

  @override
  _CoolPaginatedListViewState<T> createState() =>
      _CoolPaginatedListViewState<T>();
}

class _CoolPaginatedListViewState<T> extends State<CoolPaginatedListView<T>> {
  int? _itemCount;

  @override
  Widget build(BuildContext context) {
    var perPage = widget.perPage;
    return ListView.separated(
      itemBuilder: (context, index) {
        T item;
        try {
          item = widget.pagination[index];
        } on RangeError {
          var i = (index ~/ perPage + 1) * perPage;
          (() async {
            try {
              await widget.pagination.elementAt(i);
            } on RangeError {
              if (!mounted) {
                return;
              }
              setState(() {
                _itemCount = widget.pagination.values.length;
              });
              return;
            }
            if (!mounted) {
              return;
            }
            setState(() {
              _itemCount = widget.pagination.values.length + 1;
            });
          })();
          return ListTile(
            title: Center(
              child: CircularProgressIndicator(),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          );
        }
        return widget.itemBuilder(context, index, item);
      },
      separatorBuilder: widget.separatorBuilder,
      itemCount: _itemCount ?? widget.pagination.values.length + 1,
    );
  }
}
