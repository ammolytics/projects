import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:opentrickler/appstate.dart';
import 'package:opentrickler/devices/index.dart';
import 'package:opentrickler/history.dart';
import 'package:opentrickler/settings.dart';
import 'package:opentrickler/trickle.dart';
import 'package:opentrickler/globals.dart';

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
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _navIndex = NAV_INDEX.indexOf(TABS.DEVICES);

  void _handleNav(int i) {
    setState(() {
      _navIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If this list is changed the NAV_INDEX values in lib/globals.dart should be updated to reflect the new list.
    final List<Widget> _tabs = [
      SettingsTab(),
      DevicesTab(nav: (TABS t) => _handleNav(NAV_INDEX.indexOf(t))),
      TrickleTab(),
      HistoryTab()
    ];
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Scaffold(
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
      ),
    );
  }
}
