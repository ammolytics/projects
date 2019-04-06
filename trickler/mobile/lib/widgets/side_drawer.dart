import 'package:flutter/material.dart';

import '../pages/devices.dart';
import '../pages/history.dart';
import '../example/example.dart';

class SideDrawer extends StatelessWidget {
  final Function connectToDevice;
  final Function disconnect;
  SideDrawer({ Key key, this.connectToDevice, this.disconnect }) : super(key: key);

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
                  builder: (context) => DevicesPage(
                    key: Key('DevicesPage'),
                    connectToDevice: this.connectToDevice,
                    disconnect: this.disconnect,
                  ),
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
              'Flutter_blue example',
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
                  builder: (context) => FlutterBlueApp(key: Key('ExampleApp')),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
