import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:provider/provider.dart';

import 'client.dart' show AppClient;
import 'course.dart' show CoursePage;

const sentinel = ntucool.sentinel;

class Courses extends StatefulWidget {
  const Courses({Key? key}) : super(key: key);

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  ntucool.Pagination<ntucool.Course>? _courses;
  int? _coursesLength;
  var _customColors;

  @override
  void initState() {
    super.initState();
    var client = Provider.of<AppClient>(context, listen: false);
    (() async {
      var customColors = await client.api.users.getCustomColors(id: 'self');
      setState(() {
        _customColors = customColors;
      });
    })();
    _courses = client.api.courses.getCourses(include: ['term']);
  }

  @override
  Widget build(BuildContext context) {
    var tmp = _customColors;
    var courses = _courses;
    if (courses == null) {
      return Container();
    }
    var perPage = 2;
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        ntucool.Course course;
        try {
          course = courses[index];
        } on RangeError {
          var i = (index ~/ perPage + 1) * perPage;
          (() async {
            try {
              await courses.elementAt(i);
            } on RangeError {
              setState(() {
                _coursesLength = courses.values.length;
              });
              return;
            } on StateError catch (e) {
              if (e.message == 'Client is closed') {
                // TODO: Perhaps do something if client is closed.
              }
              throw e;
            }
            setState(() {
              _coursesLength = courses.values.length + 1;
            });
          })();
          return ListTile(
            title: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        Color? color;
        String? assetString;
        var id = course.id;
        if (id != sentinel) {
          assetString = 'course_$id';
        }
        if (assetString is String &&
            tmp is Map &&
            tmp.containsKey('custom_colors')) {
          var colors = tmp['custom_colors'];
          if (colors is Map && colors.containsKey(assetString)) {
            var hexColor = colors[assetString];
            if (hexColor is String &&
                hexColor.length == 7 &&
                hexColor.startsWith('#')) {
              var value = int.tryParse('FF' + hexColor.substring(1), radix: 16);
              if (value != null) {
                color = Color(value);
              }
            }
          }
        }

        // Build subtitle.
        Column? subtitle;
        var columnChildren = <Widget>[];
        Text? term;
        var courseTerm = course.term;
        if (courseTerm is ntucool.Term) {
          term = Text(courseTerm.name.toString());
        }
        if (term != null) {
          columnChildren.add(term);
        }
        // TODO: Show enrollments.
        if (columnChildren.isNotEmpty) {
          subtitle = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnChildren,
          );
        }

        return ListTile(
          leading: Center(
            widthFactor: 1,
            child: Container(
              color: color,
              width: 24,
              height: 24,
            ),
          ),
          title: Text(course.name.toString()),
          subtitle: subtitle,
          onTap: () {
            var id = course.id;
            if (id == sentinel || id == null) {
              // TODO: Show something.
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) {
                  return CoursePage(id: id);
                },
              ),
            );
          },
        );
      },
      separatorBuilder: (context, index) => Divider(),
      itemCount: _coursesLength ?? courses.values.length + 1,
    );
  }
}
