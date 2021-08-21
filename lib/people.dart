import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:provider/provider.dart';

import 'client.dart';
import 'paginated_list_view.dart';

const sentinel = ntucool.sentinel;

class People extends StatefulWidget {
  const People({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  final Object courseId;

  @override
  _PeopleState createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  @override
  Widget build(BuildContext context) {
    var courseId = widget.courseId;
    // TODO: Implement Groups.
    return Everyone(courseId: courseId);
  }
}

class Everyone extends StatefulWidget {
  const Everyone({
    Key? key,
    required this.courseId,
    this.perPage = 50,
  }) : super(key: key);

  final Object courseId;
  final int perPage;

  @override
  _EveryoneState createState() => _EveryoneState();
}

class _EveryoneState extends State<Everyone> {
  late final ntucool.Pagination<ntucool.User> _users;
  Map<Object?, Map<Object?, Object?>> _allRoles = {};
  Map<Object?, Map<Object?, Object?>> _sections = {};

  @override
  void initState() {
    super.initState();

    var courseId = widget.courseId;
    var perPage = widget.perPage;

    var client = Provider.of<AppClient>(context, listen: false);

    _users = client.api.courses.listUsersInCourse(
      courseId: courseId,
      include: ['enrollments', 'avatar_url'],
      perPage: perPage,
    );

    (() async {
      var jsEnv = await client.api.jsEnv.maybeRoster(courseId: courseId);
      if (jsEnv != null) {
        var allRoles = jsEnv.allRoles;
        if (allRoles is List) {
          for (var role in allRoles) {
            if (role is Map && role.containsKey('id')) {
              var id = role['id'];
              _allRoles[id] = role;
            }
          }
        }
        var sections = jsEnv.sections;
        if (sections is List) {
          for (var section in sections) {
            if (section is Map && section.containsKey('id')) {
              var id = section['id'];
              _sections[id] = section;
            }
          }
        }
        setState(() {});
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    var perPage = widget.perPage;
    var users = _users;

    return CoolPaginatedListView<ntucool.User>(
      pagination: users,
      perPage: perPage,
      itemBuilder: (context, index, user) {
        // Build leading.
        Widget leading;
        var avatarUrl = user.avatarUrl;
        if (avatarUrl is String) {
          var size = IconTheme.of(context).size ?? 24;
          leading = ClipOval(
            child: Image.network(
              avatarUrl,
              width: size,
              height: size,
            ),
          );
        } else {
          leading = Icon(Icons.account_circle);
        }

        // Build subtitle.
        Widget? subtitle;
        var sections = _sections;
        var allRoles = _allRoles;
        var enrollments = user.enrollments;
        if (enrollments is List) {
          var children = <Widget>[];
          for (var enrollment in enrollments) {
            if (enrollment is! ntucool.Enrollment) {
              continue;
            }
            var textSpanChildren = <InlineSpan>[];

            var roleId = enrollment.roleId;
            // TODO: Decide what to do.
            // 1. If there is no corresponding label to roleId.
            // 2. If roleId does not exist.
            if (roleId != sentinel) {
              if (roleId is int) {
                roleId = roleId.toString();
              }
              if (allRoles.containsKey(roleId)) {
                var role = allRoles[roleId]!;
                if (role.containsKey('label')) {
                  var label = role['label'];
                  textSpanChildren.add(
                    TextSpan(
                      text: label.toString(),
                    ),
                  );
                }
              }
            }

            var courseSectionId = enrollment.courseSectionId;
            // TODO: Decide what to do.
            // 1. If there is no corresponding label to courseSectionId.
            // 2. If courseSectionId does not exist.
            if (courseSectionId != sentinel) {
              if (courseSectionId is int) {
                courseSectionId = courseSectionId.toString();
              }
              if (sections.containsKey(courseSectionId)) {
                var section = sections[courseSectionId]!;
                if (section.containsKey('name')) {
                  var name = section['name'];
                  textSpanChildren.addAll(
                    [
                      TextSpan(
                        text: ' in ',
                      ),
                      TextSpan(
                        text: name.toString(),
                      ),
                    ],
                  );
                }
              }
            }

            if (textSpanChildren.isNotEmpty) {
              children.add(
                Text.rich(
                  TextSpan(
                    children: textSpanChildren,
                  ),
                ),
              );
            }
          }
          if (children.isNotEmpty) {
            subtitle = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            );
          }
        }

        return ListTile(
          leading: Center(
            widthFactor: 1,
            child: leading,
          ),
          title: Text(user.name.toString()),
          subtitle: subtitle,
          onTap: () {},
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 0,
      ),
    );
  }
}
