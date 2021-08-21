import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:provider/provider.dart';

import 'client.dart';
import 'paginated_list_view.dart';
import 'utils.dart' as utils;

class Pages extends StatefulWidget {
  const Pages({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  final Object? courseId;

  @override
  _PagesState createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  @override
  Widget build(BuildContext context) {
    var courseId = widget.courseId;

    return PageList(courseId: courseId);
  }
}

class PageList extends StatefulWidget {
  const PageList({
    Key? key,
    required this.courseId,
    this.perPage = 10,
  }) : super(key: key);

  final Object? courseId;
  final int perPage;

  @override
  _PageListState createState() => _PageListState();
}

class _PageListState extends State<PageList> {
  late final ntucool.Pagination<ntucool.Page> _pages;

  @override
  void initState() {
    super.initState();

    var courseId = widget.courseId;
    var perPage = widget.perPage;

    var client = Provider.of<AppClient>(context, listen: false);

    _pages = client.api.pages.listPages(
      context: 'courses',
      contextId: courseId,
      perPage: perPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    var perPage = widget.perPage;
    var pages = _pages;

    return CoolPaginatedListView<ntucool.Page>(
      pagination: pages,
      perPage: perPage,
      itemBuilder: (context, index, page) {
        // Build title.
        Widget? title;
        var rowChildren = <Widget>[];
        Widget expandedChild;
        var data = page.title;
        if (data is String) {
          expandedChild = Text(
            data,
            overflow: TextOverflow.ellipsis,
          );
        } else {
          expandedChild = Text('');
        }
        rowChildren.add(Expanded(child: expandedChild));
        var updatedAt = utils.tryFormat(
          DateFormat.yMMMd().format,
          page.updatedAt,
          isUtc: false,
        );
        if (updatedAt == null) {
          var createdAt = utils.tryFormat(
            DateFormat.yMMMd().format,
            page.createdAt,
            isUtc: false,
          );
          if (createdAt != null) {
            rowChildren.add(
              Text(
                createdAt,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            );
          }
        } else {
          rowChildren.add(
            Text(
              updatedAt,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          );
        }
        title = Row(children: rowChildren);

        return ListTile(
          title: title,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 0),
    );
  }
}
