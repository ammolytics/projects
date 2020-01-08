part of 'index.dart';

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

