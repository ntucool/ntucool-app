import 'package:flutter/material.dart';
import 'package:ntucool/ntucool.dart' as ntucool;
import 'package:ntucool_app/announcements.dart';
import 'package:ntucool_app/modules.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'pages.dart';
import 'people.dart';
import 'syllabus.dart';

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

    // Try to go to home tab.
    _toHome();

    var client = Provider.of<AppClient>(context, listen: false);

    // Get course info.
    (() async {
      var course = await client.api.courses
          .getCourse(id: widget.id, include: ['course_image']);
      if (!mounted) {
        return;
      }

      _course = course;

      // If not navigated yet, try to navigate to home.
      if (_selectedTabIndex == null) {
        _toHome();
      }

      setState(() {});
    })();

    // Get course tab info.
    (() async {
      var tabs =
          await client.api.courses.getAvailableTabs(id: widget.id).toList();
      if (!mounted) {
        return;
      }

      _tabs = tabs;

      // If not navigated yet, try to navigate to home.
      if (_selectedTabIndex == null) {
        _toHome();
      }

      setState(() {});
    })();

    // Get custom colors.
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

  /// Navigate to [tab]. Set [_selectedTabIndex] to [index].
  void _toTab(ntucool.Tab tab, int index) {
    _selectedTabIndex = index;
    var courseId = widget.id;
    var tabId = tab.id;
    switch (tabId) {
      case 'announcements':
        _body = Announcements(courseId: courseId);
        break;
      case 'home':
        _toHome(tab, index);
        break;
      case 'modules':
        _body = Modules(courseId: courseId);
        break;
      case 'pages':
        _body = Pages(courseId: courseId);
        break;
      case 'people':
        _body = People(courseId: courseId);
        break;
      case 'syllabus':
        _body = Syllabus(courseId: courseId);
        break;
      default:
        _body = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 240,
              ),
              const SizedBox(height: 12),
              Text('${tab.label} is not supported.'),
            ],
          ),
        );
    }
  }

  void _toHome([ntucool.Tab? tab, int? index]) {
    var courseId = widget.id;
    var course = _course;
    var tabs = _tabs;

    var homeTab = tab;
    var homeTabIndex = index;

    // If home tab is not provided, try to find home tab from tabs if tabs are
    // available.
    if ((homeTab == null || homeTabIndex == null) && tabs != null) {
      for (var i = 0; i < tabs.length; i++) {
        var tab = tabs[i];
        if (tab.id == 'home') {
          homeTab ??= tab;
          homeTabIndex ??= i;
          break;
        }
      }
    }

    if (course == null) {
      _body = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      _selectedTabIndex = homeTabIndex;

      var defaultView = course.defaultView;
      print(['defaultView', defaultView]);
      switch (defaultView) {
        case 'modules':
          _body = Modules(
            courseId: courseId,
          );
          break;
        case 'syllabus':
          _body = Syllabus(
            courseId: courseId,
          );
          break;
        default:
          var children = <Widget>[
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 240,
            ),
          ];
          if (homeTab != null) {
            children.addAll(
              [
                SizedBox(height: 12),
                Text('${homeTab.label} is not supported.'),
              ],
            );
          }
          _body = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
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
    void Function(ntucool.Tab tab, int index)? onTap;
    if (course != null) {
      title = Text(course.courseCode.toString());
      var id = course.id;
      if (id != sentinel) {
        assetString = 'course_$id';
      }
      onTap = (ntucool.Tab tab, int index) {
        _toTab(tab, index);
        setState(() {
          Navigator.of(context).pop();
        });
      };
    }

    var body = _body;

    var scaffold = Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: title,
      ),
      body: body,
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
              child: scaffold,
            );
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
    this.tabs,
    this.onTap,
    this.selectedTabIndex,
  }) : super(key: key);

  final ntucool.Course? course;
  final List<ntucool.Tab>? tabs;
  final void Function(ntucool.Tab tab, int index)? onTap;
  final int? selectedTabIndex;

  @override
  Widget build(BuildContext context) {
    var course = this.course;

    Object? imageDownloadUrl;
    String? data;
    if (course != null) {
      imageDownloadUrl = course.imageDownloadUrl;
      data = course.courseCode.toString();
    }

    BoxDecoration decoration;
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
    } else {
      decoration = BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      );
    }

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
    if (tabs == null) {
      children.add(
        ListTile(
          title: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
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
