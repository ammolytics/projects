import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'model.dart';
import 'actions.dart';
import 'globals.dart' as globals;
import 'header.dart';

class DevicesPage extends StatefulWidget {
  DevicesPage({ Key key }) : super(key: key);

  final String title = 'Bluetooth Devices';

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  String _btDeviceName = 'PizzaSquat';

  FlutterBlue _flutterBlue = FlutterBlue.instance;

  dynamic _scanSubscription;
  Map<DeviceIdentifier, ScanResult> _scanResults = Map();

  dynamic _deviceConnection;

  void _scanDevices(Function dispatch) {
    try {
      dispatch(SetConnectionStatus(globals.connecting));
      _scanSubscription = _flutterBlue.scan(timeout: const Duration(seconds: 5)).listen((scanResult) {
        print("\n\n\n\nlocalName: ${scanResult.advertisementData.localName}");
        print("manufacturerData: ${scanResult.advertisementData.manufacturerData}");
        print("serviceData: ${scanResult.advertisementData.serviceData}\n\n\n");
        setState(() {
          _scanResults[scanResult.device.id] = scanResult;
        });
      }, onDone: () => _stopScan(dispatch));
    } catch (e) {
      print(e.toString());
    }
  }

  void _stopScan(Function dispatch) {
    print('\n\n\n\nStopping...\n\n\n\n');
    _scanSubscription?.cancel();
    _scanSubscription = null;
    bool foundDevice = false;
    _scanResults.forEach((key, value) {
      print('\n\n\n$key');
      if (value.advertisementData.localName == _btDeviceName && !foundDevice) {
        foundDevice = true;
        _connectToDevice(value.device, dispatch);
      }
    });
    if (!foundDevice) {
      dispatch(SetConnectionStatus(globals.disconnected));
    }
  }

  void _connectToDevice(device, Function dispatch) async {
    _deviceConnection = _flutterBlue
      .connect(device, timeout: Duration(seconds: 4))
      .listen((s) {
        if (s == BluetoothDeviceState.connected) {
          print('\n\n\nCONNECTED!!!!!\n\n\n\n');
          dispatch(SetConnectionStatus(globals.connected));
        }
      }, onDone: () => _disconnect(dispatch));
  }

  void _disconnect(Function dispatch) {
    _deviceConnection?.cancel();
    print('\n\n\nDisconnecting...\n\n');
    dispatch(SetConnectionStatus(globals.disconnected));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
          child: Header(
          key: Key('Header'),
          title: widget.title,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('These are your devices!'),
          ],
        ),
      ),
      floatingActionButton: StoreConnector<AppState, Function>(
        converter: (state) {
          return (action) => state.dispatch(action);
        },
        builder: (context, dispatch) {
          return FloatingActionButton(
            heroTag: 'ScanBTDevices',
            onPressed: () => _scanDevices(dispatch),
            tooltip: 'Scan for Devices',
            backgroundColor: Colors.green,
            child: Icon(Icons.bluetooth_searching),
          );
        },
      ),
    );
  }
}