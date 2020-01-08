import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:opentrickler/appstate.dart';
import 'package:opentrickler/globals.dart';
import 'package:opentrickler/bluetooth.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PairedDevices extends StatefulWidget {
  final Function setIndex;
  final Function nav;

  PairedDevices({Key key, this.setIndex, this.nav}) : super(key: key);

  @override
  _PairedDevicesState createState() => _PairedDevicesState();
}

class _PairedDevicesState extends State<PairedDevices> {
  void _addADevice() {
    widget.setIndex(1);
  }

  void _goToTrickle() {
    widget.nav(TABS.TRICKLE);
  }

  @override
  void initState() {
    super.initState();
    AppState appState = Provider.of<AppState>(context, listen: false);
    if (appState.autoConnectDevice != null) {
      print('Running auto connect...');
      // The following line is a work around to prevent a setState during build exception:
      // Another exception was thrown: setState() or markNeedsBuild() called during build.
      // https://stackoverflow.com/questions/45409565/flutter-setstate-or-markneedsbuild-called-when-widget-tree-was-locked
      Future.delayed(Duration.zero, () { // Work around
        connectToDevice(appState.autoConnectDevice, appState, _goToTrickle);
        appState.autoConnectDevice = null;
      });
    }
  }

  void _handleTap(BluetoothDevice device, AppState appState) {
    if (appState.connectedDevice == device) {
      disconnectFromDevice(appState);
    } else {
      connectToDevice(device, appState, _goToTrickle);
    }
  }

  String _getConnectionState(dev, connectedDevice, isConnecting) {
    if (connectedDevice == dev) {
      return isConnecting ? 'Connecting...' : 'Connected';
    }
    return 'Disconnected';
  }

  List<Widget> _buildDevices(AppState appState) {
    List<Widget> devWidgets = [];
    appState.devices.forEach((dev) {
      devWidgets.add(Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => _handleTap(dev, appState),
          child: Card(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(dev.name),
                    Text(_getConnectionState(dev, appState.connectedDevice, appState.isConnecting),
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
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
          ] + _buildDevices(appState) + [
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

  FindDevices({Key key, this.setIndex}) : super(key: key);

  @override
  _FindDevicesState createState() => _FindDevicesState();
}

class _FindDevicesState extends State<FindDevices> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<ScanResult> _scanResults = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  var _sub;

  Future _scanDevices() async {
    _sub = _flutterBlue.scanResults.listen((scanResults) {
        scanResults.forEach((sr) {
          if (sr.device.name.length > 0) {
            // Note: device.id is not unique to a physical device, but instead the local instance of that BluetoothDevice.
            // The duplicate device issues is still present, the only solution I can think of at the moment is checking by
            // device.name, but that would rule out the possibilty of listing two unique devices with the same name.
            var repeatDevice = _scanResults.singleWhere((s) => s.device.id == sr.device.id, orElse: () => null);
            if (repeatDevice == null) {
              print('Found: ${sr.device.name}, rssi: ${sr.rssi}');
              setState(() {
                _scanResults.add(sr);
              });
            } else {
              int i = _scanResults.indexOf(repeatDevice);
              setState(() {
                _scanResults[i] = sr;
              });
            }
          }
        });
    });

    print('Start Scanning...');
    await _flutterBlue.startScan(timeout: Duration(seconds: 4));
    print('Stop Scanning...');
    _flutterBlue.stopScan();
    _sub.cancel();
    _sub = null;
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
      appState.autoConnectDevice = device;
    }
    callback();
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
      ) : Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: GestureDetector(
          onTap: () => _addDevice(_scanResults[i - 1].device, appState, () => setIndex(0)),
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_scanResults[i - 1].device.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text("RSSI: ${_scanResults[i - 1].rssi}, Paired: ${appState.devices.indexOf(_scanResults[i - 1].device) == -1 ? 'FALSE' : 'TRUE'}",
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                ],
              )
            ),
          ),
        )
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
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class DevicesTab extends StatefulWidget {
  final Function nav;

  DevicesTab({Key key, this.nav}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    AppState appState = Provider.of<AppState>(context, listen: false);
    if (appState.devices.length == 0) {
      print('Running auto scan...');
      _setScreenIndex(1);
    }
  }

  Widget _getScreen({Function setIndex, Function nav}) {
    final List<Widget> _screens = [
      PairedDevices(setIndex: setIndex, nav: nav),
      FindDevices(setIndex: setIndex),
    ];
    return _screens[_screenIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _getScreen(
        setIndex: (int i) => _setScreenIndex(i),
        nav: widget.nav
      ),
    );
  }
}