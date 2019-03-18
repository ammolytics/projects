import 'package:flutter/material.dart';

import 'devices.dart';
import 'history.dart';

import 'testBlue.dart';

class SideDrawer extends StatefulWidget {
  SideDrawer({ Key key }) : super(key: key);

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.only(top: 60),
            child: Text(
              'Trickler',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text(
              'Bluetooth Devices',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DevicesPage(key: Key('DevicesPage')),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              'Measurement History',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(key: Key('HistoryPage')),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              'Test Bluetooth',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlutterBlueApp(key: Key('BluetoothPage')),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
