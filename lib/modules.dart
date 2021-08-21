import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'client.dart';
import 'expansion_tile.dart' as expansion_tile;
import 'paginated_list_view.dart';
import 'utils.dart' as utils;

// https://github.com/instructure/canvas-lms/blob/master/ui/shared/module-sequence-footer/jquery/index.js
const moduleItemTypeIcons = {
  'File': Icon(Icons.attachment),
  'Page': Icon(Icons.pages),
  'Discussion': Icon(Icons.forum),
  'Assignment': Icon(Icons.assignment),
  'Quiz': Icon(Icons.quiz),
  'SubHeader': null,
  'ExternalUrl': Icon(Icons.link),
  'ExternalTool': Icon(Icons.link),
};

class Modules extends StatefulWidget {
  const Modules({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  final Object? courseId;

  @override
  _ModulesState createState() => _ModulesState();
}

class _ModulesState extends State<Modules> {
  @override
  Widget build(BuildContext context) {
    var courseId = widget.courseId;

    return ModuleList(
      courseId: courseId,
    );
  }
}

class ModuleList extends StatefulWidget {
  const ModuleList({
    Key? key,
    required this.courseId,
    this.perPage = 10,
  }) : super(key: key);

  final Object? courseId;
  final int perPage;

  @override
  _ModuleListState createState() => _ModuleListState();
}

class _ModuleListState extends State<ModuleList> {
  late final ntucool.Pagination<ntucool.Module> _modules;

  @override
  void initState() {
    super.initState();

    var courseId = widget.courseId;
    var perPage = widget.perPage;

    var client = Provider.of<AppClient>(context, listen: false);

    _modules = client.api.modules.listModules(
      courseId: courseId,
      include: ['items'],
      perPage: perPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    var courseId = widget.courseId;
    var perPage = widget.perPage;
    var modules = _modules;

    return CoolPaginatedListView<ntucool.Module>(
      pagination: modules,
      perPage: perPage,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index, module) {
        return ModuleTile(
          courseId: courseId,
          module: module,
          index: index,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: 12,
      ),
    );
  }
}

class ModuleTile extends StatefulWidget {
  const ModuleTile({
    Key? key,
    required this.courseId,
    required this.module,
    this.index,
    this.initiallyExpanded = false,
  }) : super(key: key);

  final Object? courseId;
  final ntucool.Module module;
  final int? index;
  final bool initiallyExpanded;

  @override
  _ModuleTileState createState() => _ModuleTileState();
}

class _ModuleTileState extends State<ModuleTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    var courseId = widget.courseId;
    var module = widget.module;
    var index = widget.index;

    PageStorageKey? key;
    if (index != null) {
      key = PageStorageKey(index);
    }

    // Build title.
    Widget title;
    var name = module.name;
    if (name is String) {
      TextOverflow overflow;
      if (_expanded) {
        overflow = TextOverflow.clip;
      } else {
        overflow = TextOverflow.ellipsis;
      }
      title = Text(
        name,
        overflow: overflow,
      );
    } else {
      title = Text('');
    }

    var theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: expansion_tile.ExpansionTile(
          key: key,
          title: title,
          onExpansionChanged: (expanding) {
            setState(() {
              _expanded = expanding;
            });
          },
          children: [
            Theme(
              data: theme,
              child: const Divider(height: 1),
            ),
            Theme(
              data: theme,
              child: ModuleItemList(
                courseId: courseId,
                module: module,
                parentIndex: index,
              ),
            ),
          ],
          initiallyExpanded: _expanded,
          maintainState: true,
        ),
      ),
    );
  }
}

class ModuleItemList extends StatefulWidget {
  const ModuleItemList({
    Key? key,
    required this.courseId,
    required this.module,
    this.perPage = 10,
    this.parentIndex,
  }) : super(key: key);

  final Object? courseId;
  final ntucool.Module module;
  final int perPage;
  final int? parentIndex;

  @override
  _ModuleItemListState createState() => _ModuleItemListState();
}

class _ModuleItemListState extends State<ModuleItemList>
    with AutomaticKeepAliveClientMixin {
  late ntucool.Pagination<ntucool.ModuleItem> _itemsPagination;

  ntucool.Pagination<ntucool.ModuleItem> _listModuleItems() {
    var courseId = widget.courseId;
    var module = widget.module;
    var perPage = widget.perPage;

    var moduleId = module.id;
    if (moduleId == ntucool.sentinel) {
      // TODO: Do something if module id does not exist.
    }

    var client = Provider.of<AppClient>(context, listen: false);

    var itemsPagination = client.api.modules.listModuleItems(
      courseId: courseId,
      moduleId: module.id,
      perPage: perPage,
    );

    return itemsPagination;
  }

  @override
  void initState() {
    super.initState();

    var module = widget.module;

    ntucool.Pagination<ntucool.ModuleItem> itemsPagination;
    var items = utils.whereIterable<ntucool.ModuleItem>(module.items);
    if (items == null) {
      itemsPagination = _listModuleItems();
    } else {
      items = items.toList(growable: false);
      int? itemsCount = utils.tryParseInt(module.itemsCount);
      if (items.length == itemsCount) {
        itemsPagination = ntucool.Pagination.fromIterable(items);
      } else {
        itemsPagination = _listModuleItems();
      }
    }
    _itemsPagination = itemsPagination;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var perPage = widget.perPage;
    var parentIndex = widget.parentIndex;
    var itemsPagination = _itemsPagination;

    Key? key;
    if (parentIndex != null) {
      key = PageStorageKey(parentIndex);
    }

    return CoolPaginatedListView<ntucool.ModuleItem>(
      key: key,
      pagination: itemsPagination,
      perPage: perPage,
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index, moduleItem) {
        var type = moduleItem.type;

        // Build leading.
        Widget? leading = moduleItemTypeIcons[type];
        double? horizontalTitleGap;
        var indent = utils.tryParseInt(moduleItem.indent);
        if (indent != null && indent > 0) {
          var indentUnitSize = IconTheme.of(context).size ?? 24;
          if (leading == null) {
            leading = SizedBox(width: indentUnitSize * indent);
            horizontalTitleGap = 0;
          } else {
            leading = Padding(
              padding: EdgeInsets.only(left: indentUnitSize * indent),
              child: leading,
            );
          }
        }

        Widget? title;
        var data = utils.castOrNull<String>(moduleItem.title);
        if (data != null) {
          title = Text(data);
        }

        Widget? trailing;
        GestureTapCallback? onTap;
        GestureLongPressCallback? onLongPress;

        // TODO: Consider using android_intent_plus for better control.
        // https://pub.dev/packages/android_intent_plus
        switch (type) {
          case 'ExternalUrl':
            var externalUrl = utils.castOrNull<String>(moduleItem.externalUrl);
            // TODO: Do something if externalUrl is not valid.
            if (externalUrl != null) {
              var textSpanChildren = [
                if (data != null) ...[
                  TextSpan(
                    text: data,
                    style: TextStyle(color: Colors.blue),
                  ),
                  WidgetSpan(child: const SizedBox(width: 8)),
                ],
                WidgetSpan(
                  child: const Icon(Icons.launch),
                  alignment: PlaceholderAlignment.middle,
                )
              ];
              title = Text.rich(TextSpan(children: textSpanChildren));
              onTap = () async {
                print(externalUrl);
                if (await canLaunch(externalUrl)) {
                  if (!mounted) {
                    return;
                  }
                  await launch(externalUrl);
                }
              };
            }
            break;
          case 'ExternalTool':
            var url = utils.castOrNull<String>(moduleItem.url);
            // TODO: Do something if url is not valid.
            if (url != null) {
              var textSpanChildren = [
                if (data != null) ...[
                  TextSpan(
                    text: data,
                    style: TextStyle(color: Colors.blue),
                  ),
                  WidgetSpan(child: const SizedBox(width: 8)),
                ],
                WidgetSpan(
                  child: const Icon(Icons.launch),
                  alignment: PlaceholderAlignment.middle,
                )
              ];
              title = Text.rich(TextSpan(children: textSpanChildren));

              onTap = () async {
                print(url);
                var client = Provider.of<AppClient>(context, listen: false);
                var response =
                    await client.session.openUrl('GET', Uri.parse(url));
                if (!mounted) {
                  return;
                }
                var text = await response.text();
                if (!mounted) {
                  return;
                }
                var data = jsonDecode(text);
                var sessionlesslaunch = utils.castOrNull<String>(data['url']);
                print(sessionlesslaunch);
                if (sessionlesslaunch != null) {
                  if (await canLaunch(sessionlesslaunch)) {
                    if (!mounted) {
                      return;
                    }
                    await launch(sessionlesslaunch);
                  }
                }
              };
            }
            break;
          default:
        }

        return ListTile(
          leading: leading,
          title: title,
          trailing: trailing,
          onTap: onTap,
          onLongPress: onLongPress,
          horizontalTitleGap: horizontalTitleGap,
          minLeadingWidth: 0,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 0),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
