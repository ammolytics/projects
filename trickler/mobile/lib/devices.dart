import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:opentrickler/appstate.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  List<Widget> _buildDevices(devices) {
    List<Widget> devWidgets = [];
    devices.forEach((dev) {
      devWidgets.add(Text(dev.name));
    });
    return devWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) =>
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
              child: Text('Paired Devices',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ] + _buildDevices(appState.devices) + [
            RaisedButton(
              onPressed: _addADevice,
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
              child: Text('Add a Device')
            ),
          ],
        ),  
    );
  }
}

class FindDevices extends StatefulWidget {
  final Function setIndex;

  FindDevices({Key key, this.setIndex});

  @override
  _FindDevicesState createState() => _FindDevicesState();
}

class _FindDevicesState extends State<FindDevices> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<ScanResult> _scanResults = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  Future _scanDevices() async {
    var sub = _flutterBlue.scanResults.listen((scanResults) {
        scanResults.forEach((sr) {
          if (sr.device.name.length > 0 && _scanResults.indexOf(sr) == -1) {
            print('Found: ${sr.device.name}, rssi: ${sr.rssi}');
            setState(() {
              _scanResults.add(sr);
            });
          }
        });
    });

    print('Start Scanning...');
    await _flutterBlue.startScan(timeout: Duration(seconds: 4));
    print('Stop Scanning...');
    _flutterBlue.stopScan();
    sub.cancel();
    return;
  }

  void _onRefresh() async {
    print('Refreshing...');
    await _scanDevices();
    _refreshController.refreshCompleted();
  }

  void _addDevice(BluetoothDevice device, AppState appState, Function callback) {
    if (appState.devices.indexOf(device) == -1) {
      appState.devices.add(device);
      callback();
    }
  }

  Widget _buildResults(BuildContext ctxt, int i, AppState appState, Function setIndex) {
    return i == 0 ?
      Padding(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
        child: Text('Available Devices',
        textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          )
        ),
      ) : GestureDetector(
        onTap: () => _addDevice(_scanResults[i - 1].device, appState, () => setIndex(0)),
        child: Card(
          child: Text(_scanResults[i - 1].device.name),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) =>
        SmartRefresher(
          enablePullDown: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: _scanResults.length + 1,
            itemBuilder: (c, i) => _buildResults(c, i, appState, widget.setIndex),
          ),
        ),
    );
  }
}

class DevicesTab extends StatefulWidget {
  @override
  _DevicesTabState createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  int _screenIndex = 0;

  void _setScreenIndex(int i) {
      setState(() {
        _screenIndex = i;
      });
  }

  Widget _getScreen(Function setIndex,) {
    final List<Widget> _screens = [
      PairedDevices(setIndex: setIndex),
      FindDevices(setIndex: setIndex),
    ];
    return _screens[_screenIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _getScreen((int i) => _setScreenIndex(i))
    );
  }
}