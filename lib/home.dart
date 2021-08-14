import 'package:flutter/material.dart';

import 'courses.dart';
import 'dashboard.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.body,
    this.drawer,
    this.currentIndex = 0,
  }) : super(key: key);

  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? title;
  final Widget? body;
  final Widget? drawer;
  final int currentIndex;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget? _leading;
  bool _automaticallyImplyLeading = true;
  Widget? _title;
  Widget? _body;
  Widget? _drawer;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _leading = widget.leading;
    _automaticallyImplyLeading = widget.automaticallyImplyLeading;
    _title = widget.title;
    _body = widget.body;
    _drawer = widget.drawer;
    _currentIndex = widget.currentIndex;
    if (_body == null) {
      _bottomNavigate();
    }
  }

  void _bottomNavigate() {
    _leading = null;
    _automaticallyImplyLeading = false;
    _drawer = null;
    switch (_currentIndex) {
      case 0:
        _title = Text('Dashboard');
        _body = Dashboard();
        break;
      case 1:
        _title = Text('All Courses');
        _body = Courses();
        break;
      default:
        _title = Text('Dashboard');
        _body = Dashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _leading,
        automaticallyImplyLeading: _automaticallyImplyLeading,
        title: _title,
      ),
      body: _body,
      drawer: _drawer,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _bottomNavigate();
          });
        },
        currentIndex: _currentIndex,
      ),
    );
  }
}
