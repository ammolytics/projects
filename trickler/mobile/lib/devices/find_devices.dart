part of 'index.dart';

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
