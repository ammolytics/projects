import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/index.dart';
import '../actions.dart';
import '../globals.dart' as globals;
import '../widgets/header.dart';

class DevicesPage extends StatefulWidget {
  DevicesPage({ Key key }) : super(key: key);

  final String title = 'Bluetooth Devices';

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  AppState _state;
  Function _dispatch;
  String _btDeviceName = 'Trickler';

  FlutterBlue _flutterBlue = FlutterBlue.instance;

  dynamic _scanSubscription;
  Map<DeviceIdentifier, ScanResult> _scanResults = Map();

  void _scanDevices() {
    try {
      bool foundPeripheral = false;
      _dispatch(SetConnectionStatus(globals.connecting));
      // Listen for BT Devices for 5 seconds
      _scanSubscription = _flutterBlue.scan(timeout: const Duration(seconds: 5)).listen((scanResult) {
        // Save all results to local state
        setState(() {
          _scanResults[scanResult.device.id] = scanResult;
        });
        if (scanResult.advertisementData.localName == _btDeviceName && !foundPeripheral) {
          // Connect before 5 second timeout
          foundPeripheral = true;
          _connectToDevice(scanResult.device);
        }
      }, onDone: () => _stopScan(foundPeripheral));
    } catch (e) {
      print(e.toString());
    }
  }

  void _stopScan(bool foundPeripheral) {
    // Stop scanning...
    _scanSubscription?.cancel();
    _scanSubscription = null;
    bool foundDevice = foundPeripheral;
    if (!foundDevice) {
      // 
      // If we didn't connect before 5 second timeout:
      // loop through results and double check.
      // 
      // TODO: Turn all results into selectable devices
      // to allow for connection to non-trickler devices
      // 
      _scanResults.forEach((key, value) {
        if (value.advertisementData.localName == _btDeviceName) {
          foundDevice = true;
          _connectToDevice(value.device);
        }
      });
      _dispatch(SetConnectionStatus(globals.disconnected));
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    // Stop the scan before 5 second timeout
    _stopScan(true);
    dynamic deviceConnection = _flutterBlue
      .connect(device, timeout: Duration(seconds: 4))
      .listen((s) {
        // Connect to device and listen for data
        if (s == BluetoothDeviceState.connected) {
          print('\n\n\nConnected!\n\n\n\n');
          _dispatch(SetConnectionStatus(globals.connected));
          _dispatch(SetDevice(device));
          setState(() {});
          _getServices(device);
        } else if (s == BluetoothDeviceState.disconnected) {
          _disconnect();
        }
      }, onDone: _disconnect);
    _dispatch(SetDeviceConnection(deviceConnection));
  }

  void _disconnect() {
    _state.deviceConnection?.cancel();
    print('\n\n\nDisconnecting...\n\n\n\n');
    _dispatch(SetConnectionStatus(globals.disconnected));
    _dispatch(SetDevice(BluetoothDevice(id:DeviceIdentifier('000'))));
    // Reset all characteristics in global state
    _dispatch(UpdateCharacteristic(0, [])); // Stability
    _dispatch(UpdateCharacteristic(1, [])); // Weight
    _dispatch(UpdateCharacteristic(2, [])); // Unit
    setState(() {});
  }

  void _getServices(BluetoothDevice device) {
    // Discover all advertised trickler services
    device.discoverServices().then((services) {
      List<BluetoothCharacteristic> chars = [];
      services.forEach((service) {
        // Find the service we need for data readout
        if (service.uuid.toString() == globals.tricklerServiceId) {
          _dispatch(SetService(service));
          service.characteristics.forEach((char) {
            chars.add(char);
          });
        }
      });
      // Read all provided characteristics
      _readCharacteristics(device, chars, 0);
    });
  }

  dynamic _readCharacteristics(BluetoothDevice device, List<BluetoothCharacteristic> chars, int i) {
    // Rucursively read characteristics one at a time
    List<String> charNames = ['STABLITY', 'WEIGHT', 'UNIT'];

    BluetoothCharacteristic char = chars[i];
    if (char.properties.read) {
      print('\n\n\nREADING ${charNames[i]}...\n\n\n');
      device.readCharacteristic(char).then((readChar) {
        print('\n\n${charNames[i]} PROPERTIES');
        print('NOTIFY: ${char.properties.notify}');
        print('READ: ${char.properties.read}');
        print('WRITE: ${char.properties.write}\n\n');
        print('${charNames[i]}: ${char.value}\n\n');
        // Update global state to reflect characteristics
        _dispatch(UpdateCharacteristic(i, readChar));
        setState(() {});
        if (i + 1 >= 3) {
          // Only loop through the first 3 characteristics.
          // This prevents index out of range error if
          // additional characteristics are available.
          return [readChar];
        }
        return List.from([readChar])..addAll(_readCharacteristics(device, chars, i + 1));
      });
    } else {
      print('\n\n\nCAN\'T READ ${charNames[i]}');
      print('\n\n${charNames[i]} PROPERTIES');
      print('NOTIFY: ${char.properties.notify}');
      print('READ: ${char.properties.read}');
      print('WRITE: ${char.properties.write}\n\n');
    }
  }

  String _getStability() {
    return _state.characteristics[0].length > 0 ?
      globals.stabilityList[_state.characteristics[0][0]] : '';
  }
  String _getWeight() {
    // TODO: convert data to double
    return _state.characteristics[1].toString();
  }

  String _getUnit() {
    return _state.characteristics[2].length > 0 ?
      globals.unitsList[_state.characteristics[2][0]] : '';
  }

  Widget _getDeviceInfo() {
    BluetoothDevice device = _state.device;
    if (device.id != DeviceIdentifier('000')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text("Connected to: ${device.name}",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding:EdgeInsets.only(bottom: 8.0),
            child: Text("Stability: ${_getStability()}",
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Padding(
            padding:EdgeInsets.only(bottom: 8.0),
            child: Text("Weight: ${_getWeight()}",
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Padding(
            padding:EdgeInsets.only(bottom: 8.0),
            child: Text("Unit: ${_getUnit()}",
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      );
    }
    return Text('You are not connected to a device!',
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  _getActionButton() {
    BluetoothDevice device = _state.device;
    if (device.id != DeviceIdentifier('000')) {
      return FloatingActionButton(
        heroTag: 'Disconnect',
        onPressed: _disconnect,
        tooltip: 'Disconnect',
        backgroundColor: Colors.red,
        child: Icon(Icons.bluetooth_disabled),
      );
    }
    return FloatingActionButton(
      heroTag: 'ScanBTDevices',
      onPressed: _scanDevices,
      tooltip: 'Scan for Devices',
      backgroundColor: Colors.green,
      child: Icon(Icons.bluetooth_searching),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _state = StoreProvider.of<AppState>(context).state;
      _dispatch = (action) => StoreProvider.of<AppState>(context).dispatch(action);
    });
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
            _getDeviceInfo(),
          ],
        ),
      ),
      floatingActionButton: _getActionButton(),
    );
  }
}