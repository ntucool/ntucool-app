import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:ntucool_app/syllabus.dart';
import 'package:provider/provider.dart';

import 'client.dart';

const sentinel = ntucool.sentinel;

const tabIcons = {
  'announcements': Icon(Icons.announcement),
  'assignments': Icon(Icons.assignment),
  'discussions': Icon(Icons.forum),
  'files': Icon(Icons.folder),
  'grades': Icon(Icons.grade),
  'home': Icon(Icons.home),
  'modules': Icon(Icons.segment),
  'pages': Icon(Icons.pages),
  'people': Icon(Icons.people),
  'quizzes': Icon(Icons.quiz),
  'syllabus': Icon(Icons.summarize),
};

class CoursePage extends StatefulWidget {
  CoursePage({
    Key? key,
    required this.id,
  }) : super(key: key);

  final Object id;

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  Widget? _body;
  ntucool.Course? _course;
  var _customColors;
  List<ntucool.Tab>? _tabs;
  int? _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _toTab();
    var client = Provider.of<AppClient>(context, listen: false);
    (() async {
      var course = await client.api.courses
          .getCourse(id: widget.id, include: ['course_image']);
      // course.attributes.forEach((key, value) {
      //   print([key, value]);
      // });
      if (!mounted) {
        return;
      }
      setState(() {
        _course = course;
        _toTab();
      });
    })();
    (() async {
      var tabs =
          await client.api.courses.getAvailableTabs(id: widget.id).toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _tabs = tabs;
      });
    })();
    (() async {
      var customColors = await client.api.users.getCustomColors(id: 'self');
      if (!mounted) {
        return;
      }
      setState(() {
        _customColors = customColors;
      });
    })();
  }

  void _toTab([ntucool.Tab? tab, int? index]) {
    if (index != null) {
      _selectedTabIndex = index;
    }
    if (tab == null) {
      var course = _course;
      if (course == null) {
        _body = Center(
          child: CircularProgressIndicator(),
        );
      } else {
        _body = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 240,
              ),
            ],
          ),
        );
      }
    } else {
      var id = tab.id;
      switch (id) {
        case 'syllabus':
          _body = Syllabus(
            courseId: widget.id,
          );
          break;
        default:
          _body = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 240,
                ),
                SizedBox(height: 12),
                Text('${tab.label} is not supported.'),
              ],
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var course = _course;

    Text? title;
    String? assetString;
    void Function(ntucool.Tab tab, int? index)? onTap;
    if (course != null) {
      title = Text(course.courseCode.toString());
      var id = course.id;
      if (id != sentinel) {
        assetString = 'course_$id';
      }
      onTap = (ntucool.Tab tab, int? index) {
        print(['defaultView', course.defaultView]);
        _toTab(tab, index);
        setState(() {
          Navigator.of(context).pop();
        });
      };
    }

    var scaffold = Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: title,
      ),
      body: _body,
      endDrawer: CourseDrawer(
        course: course,
        tabs: _tabs,
        onTap: onTap,
        selectedTabIndex: _selectedTabIndex,
      ),
    );

    var tmp = _customColors;
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
            return Theme(
                data: Theme.of(context).copyWith(primaryColor: Color(value)),
                child: scaffold);
          }
        }
      }
    }

    return scaffold;
  }
}

class CourseDrawer extends StatelessWidget {
  CourseDrawer({
    Key? key,
    this.course,
    this.customColors,
    this.tabs,
    this.onTap,
    this.selectedTabIndex,
  }) : super(key: key);

  final ntucool.Course? course;
  final customColors;
  final List<ntucool.Tab>? tabs;
  final void Function(ntucool.Tab tab, int? index)? onTap;
  final int? selectedTabIndex;

  @override
  Widget build(BuildContext context) {
    var course = this.course;
    var imageDownloadUrl = course?.imageDownloadUrl;
    BoxDecoration decoration = BoxDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.5),
    );
    if (imageDownloadUrl is String) {
      decoration = BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageDownloadUrl),
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.dstATop,
          ),
          fit: BoxFit.cover,
        ),
      );
    } else {}
    var data = course?.courseCode.toString();
    Align? drawHeaderChild;
    if (data != null) {
      drawHeaderChild = Align(
        alignment: Alignment.bottomLeft,
        child: Text(data),
      );
    }
    var children = <Widget>[
      DrawerHeader(
        decoration: decoration,
        padding: EdgeInsets.all(16),
        child: drawHeaderChild,
      ),
    ];
    var tabs = this.tabs;
    if (tabs != null) {
      var onTap = this.onTap;
      for (var index = 0; index < tabs.length; index++) {
        var tab = tabs[index];
        children.add(ListTile(
          leading: tabIcons[tab.id] ?? const Icon(Icons.circle),
          title: Text(tab.label.toString()),
          onTap: () {
            if (onTap != null) {
              onTap(tab, index);
            }
          },
          selected: selectedTabIndex == index,
        ));
      }
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }
}
