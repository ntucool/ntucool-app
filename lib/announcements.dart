import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'client.dart' show AppClient;
import 'paginated_list_view.dart';

class Announcements extends StatefulWidget {
  const Announcements({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  final Object? courseId;

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  Widget? _body;

  @override
  Widget build(BuildContext context) {
    var courseId = widget.courseId;
    var body = _body;
    if (body == null) {
      return AnnouncementList(
        courseId: courseId,
        onTap: (index, announcement) {
          var htmlUrl = announcement.htmlUrl;
          var message = announcement.message;
          if (message is String) {
            // _body = SingleChildScrollView(
            //   padding: EdgeInsets.all(12),
            //   child: Html(input: message),
            // );
            _body = Padding(
              padding: EdgeInsets.all(8),
              child: WebView(
                initialUrl: Uri.dataFromString(
                  message,
                  mimeType: 'text/html',
                  encoding: utf8,
                ).toString(),
              ),
            );
            setState(() {});
          }
        },
      );
    } else {
      return body;
    }
  }
}

class AnnouncementList extends StatefulWidget {
  const AnnouncementList({
    Key? key,
    required this.courseId,
    this.perPage = 40,
    this.onTap,
  }) : super(key: key);

  final Object? courseId;
  final int perPage;
  final void Function(int index, ntucool.DiscussionTopic announcement)? onTap;

  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  late final ntucool.Pagination<ntucool.DiscussionTopic> _announcements;

  @override
  void initState() {
    super.initState();

    var courseId = widget.courseId;
    var perPage = widget.perPage;

    var client = Provider.of<AppClient>(context, listen: false);

    _announcements = client.api.discussionTopics.listDiscussionTopics(
      context: 'courses',
      contextId: courseId,
      onlyAnnouncements: true,
      perPage: perPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    var perPage = widget.perPage;
    var announcements = _announcements;
    var widgetOnTap = widget.onTap;

    return CoolPaginatedListView<ntucool.DiscussionTopic>(
      pagination: announcements,
      perPage: perPage,
      itemBuilder: (context, index, announcement) {
        // Build leading.
        Widget? icon;
        var size = 32.0;
        var author = announcement.author;
        if (author is Map) {
          var avatarImageUrl = author['avatar_image_url'];
          if (avatarImageUrl is String) {
            icon = ClipOval(
              child: Image.network(
                avatarImageUrl,
                width: size,
                height: size,
              ),
            );
          }
        }
        if (icon == null) {
          icon = Icon(
            Icons.account_circle,
            size: size,
          );
        }
        var leading = icon;

        // Build title.
        Widget? title;
        var rowChildren = <Widget>[
          Expanded(
            child: Text(
              announcement.userName.toString(),
              style: Theme.of(context).textTheme.subtitle1?.apply(
                    fontSizeFactor: 1.1,
                    fontWeightDelta: 1,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];
        var postedAt = announcement.postedAt;
        if (postedAt is String) {
          try {
            var dateTime = DateTime.parse(postedAt).toLocal();
            postedAt = DateFormat.yMMMd().format(dateTime);
            rowChildren.add(
              Align(
                alignment: Alignment.topRight,
                widthFactor: 1,
                child: Text(
                  postedAt,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            );
          } on FormatException {}
        }
        title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: rowChildren,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              announcement.title.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

        // Build subtitle
        Widget? subtitle;
        var message = announcement.message;
        if (message is String) {
          var document = parser.parse(message);
          var data = document.body?.text;
          if (data != null) {
            document = parser.parse(data);
            data = document.documentElement?.text;
            if (data != null) {
              subtitle = Container(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  data.replaceAll(RegExp(r'\n+'), ' '),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
          }
        }

        GestureTapCallback? onTap;
        if (widgetOnTap != null) {
          onTap = () {
            widgetOnTap(index, announcement);
          };
        }

        return ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          contentPadding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          onTap: onTap,
          horizontalTitleGap: 8,
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 0,
      ),
    );
  }
}
