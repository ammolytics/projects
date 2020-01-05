import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class PairedDevices extends StatefulWidget {
  final Function setIndex;

  PairedDevices({Key key, this.setIndex});

  @override
  _PairedDevicesState createState() => _PairedDevicesState();
}

class _PairedDevicesState extends State<PairedDevices> {
  void _addADevice() {
    widget.setIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Text('Paired Devices',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold
            )
          ),
        ),
        RaisedButton(
          onPressed: _addADevice,
          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
          child: Text('Add a Device')
        ),
      ],
    );
  }
}

class FindDevices extends StatefulWidget {
  FindDevices({Key key}) : super(key: key);

  @override
  _FindDevicesState createState() => _FindDevicesState();
}

class _FindDevicesState extends State<FindDevices> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<ScanResult> _scanResults = [];

  void initState() {
    super.initState();
    _scanDevices();
  }

  void _scanDevices() {
    print('Start Scanning...');
    _flutterBlue.startScan(timeout: Duration(seconds: 4));

    _flutterBlue.scanResults.listen((scanResults) {
        scanResults.forEach((sr) {
          if (sr.device.name.length > 0 && _scanResults.indexOf(sr) == -1) {
            print('Found: ${sr.device.name}, rssi: ${sr.rssi}');
            setState(() {
              _scanResults.add(sr);
            });
          }
        });
    });

    _flutterBlue.stopScan();
  }

  List<Widget> _getResults() {
    List<Widget> results = [];
    _scanResults.forEach((sr) {
      results.add(Text(sr.device.name));
    });
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Text('Available Devices',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold
            )
          ),
        ),
      ] + _getResults(),
    );
  }
}

class DevicesTab extends StatefulWidget {
  @override
  _DevicesTabState createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  int _screenIndex = 0;

  Widget _getScreen(Function setIndex) {
    final List<Widget> _screens = [
      PairedDevices(setIndex: setIndex),
      FindDevices(),
    ];
    return _screens[_screenIndex];
  }

  void _setScreenIndex(int i) {
      setState(() {
        _screenIndex = i;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _getScreen((int i) => _setScreenIndex(i))
    );
  }
}