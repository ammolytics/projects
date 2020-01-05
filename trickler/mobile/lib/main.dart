import 'package:flutter/material.dart';
import 'package:opentrickler/devices.dart';
import 'package:opentrickler/history.dart';
import 'package:opentrickler/settings.dart';
import 'package:opentrickler/trickle.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int startIndex;

  MainScreen({Key key, this.startIndex}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _navIndex = 1;
  final List<Widget> _tabs = [
    SettingsTab(),
    DevicesTab(),
    TrickleTab(),
    HistoryTab()
  ];

  void _handleNav(int i) {
    setState(() {
      _navIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Trickler'),
      ),
      body: _tabs[_navIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _navIndex,
        onTap: _handleNav,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.settings),
            title: new Text('Settings'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.devices_other),
            title: new Text('Devices'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            title: Text('Trickle')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            title: Text('History')
          )
        ],
      ),
    );
  }
}
