import 'package:flutter/material.dart';
import 'package:ntucool_app/courses.dart';
import 'package:ntucool_app/dashboard.dart';

class CoolScaffold extends StatefulWidget {
  const CoolScaffold({
    Key? key,
    this.leading,
    this.title,
    this.body,
    this.currentIndex = 0,
  }) : super(key: key);

  final Widget? leading;
  final Widget? title;
  final Widget? body;
  final int currentIndex;

  @override
  _CoolScaffoldState createState() => _CoolScaffoldState();
}

class _CoolScaffoldState extends State<CoolScaffold> {
  Widget? _leading;
  Widget? _title;
  Widget? _body;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _leading = widget.leading;
    _title = widget.title;
    _body = widget.body;
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    var body = _body;
    if (body == null) {
      switch (_currentIndex) {
        case 0:
          body = Dashboard();
          break;
        case 1:
          body = Courses();
          break;
        default:
          body = Dashboard();
      }
    } else {
      _body = null;
    }
    var title = _title;
    if (title == null) {
      switch (_currentIndex) {
        case 0:
          title = Text('Dashboard');
          break;
        case 1:
          title = Text('All Courses');
          break;
        default:
          title = Text('Dashboard');
      }
    } else {
      _title = null;
    }
    return Scaffold(
      appBar: AppBar(
        leading: _leading,
        automaticallyImplyLeading: false,
        title: title,
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
      ),
    );
  }
}
