import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/index.dart';
import '../actions.dart';
import '../globals.dart' as globals;

import '../widgets/header.dart';
import '../widgets/side_drawer.dart';

class HomePage extends StatefulWidget {
  final Function connectToDevice;
  final Function disconnect;
  HomePage({ Key key, this.connectToDevice, this.disconnect }) : super(key: key);

  final String title = 'Trickler';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppState _state;
  Function _dispatch;

  FocusNode _inputFocus = FocusNode();
  TextEditingController _controller = TextEditingController(text: '0.0');

  void _toggleUnit() {
    double weight = _state.currentMeasurement.targetWeight;
    String unit = _state.currentMeasurement.unit;
    if (unit == globals.grams) {
      weight *= 15.4324;
      _dispatch(SetUnit(globals.grains));
      _dispatch(SetTargetWeight(weight));
      _updatePeripheralUnit(globals.grains);
    } else if (unit == globals.grains) {
      weight /= 15.4324;
      _dispatch(SetUnit(globals.grams));
      _dispatch(SetTargetWeight(weight));
      _updatePeripheralUnit(globals.grams);
    }
    _syncTextField();
  }

  void _updatePeripheralUnit(unit) {
    BluetoothDevice device = _state.deviceState.device;
    BluetoothService service = _state.deviceState.service;

    if (
      service?.characteristics != null &&
      service.characteristics.length > 2 &&
      service.characteristics[2].properties.write
    ) {
      // Write to trickler unit characteristic
      device.writeCharacteristic(service.characteristics[2],
        unit == globals.grains ? [0] : [1]).then((value) {
          // Check unit characteristic was changed to the right value
          device.readCharacteristic(service.characteristics[2]).then((readChar) {
            if (readChar.toString() == (unit == globals.grains ? '[0]' : '[1]')) {
              // Update unit characteristic in global state
              print('\n\n\nREAD CHAR: $readChar\n\n\n');
            }
          });
        });
    }
  }

  void _updateCounter(text) {
    var newWeight = double.parse(text);
    _dispatch(SetTargetWeight(newWeight));
  }

  void _submit() {
    BluetoothDevice device = _state.deviceState.device;
    double targetWeight = _state.currentMeasurement.targetWeight;

    if (_inputFocus.hasFocus) {
      _inputFocus.unfocus();
    }

    _syncTextField();

    print('Sending $targetWeight to ${device.name}');
  }

  void _syncTextField() {
    double targetWeight = _state.currentMeasurement.targetWeight;
    setState(() {
      _controller.text = '$targetWeight';
    });
  }

  String _getUnit() {
    String unit = _state.currentMeasurement.unit;
    List<String> abbr = ['gr', 'g'];
    int i = globals.unitsList.indexOf(unit);
    return abbr[i];
  }

  Widget _getConnection() {
    BluetoothDevice device = _state.deviceState.device;
    if (device.id != DeviceIdentifier('000')) {
      return Text("You are connected to: ${device.name}");
    }
    return Text('You are not connected to a device!');
  }

  @override
  Widget build(BuildContext context) {
    _dispatch = (action) => StoreProvider.of<AppState>(context).dispatch(action);
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        _state = state;
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: Header(
              key: Key('Header'),
              title: widget.title,
            ),
          ),
          drawer: SideDrawer(
            key: Key('SideDrawer'),
            connectToDevice: widget.connectToDevice,
            disconnect: widget.disconnect,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _getConnection(),
                Padding(
                  padding:EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: _controller,
                    onChanged: _updateCounter,
                    focusNode: _inputFocus,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    key: Key('WeightInput'),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      // prefix centers the value
                      prefix: SizedBox(
                        width: 57.0,
                        height: 40.0,
                        child: Text(''),
                      ),
                      suffix: SizedBox(
                        width: 57.0,
                        height: 40.0,
                        child: OutlineButton(
                          onPressed: _toggleUnit,
                          child: Text(
                            "${_getUnit()}",
                            key: Key('CurrentUnit'),
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          splashColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'SubmitBtn',
            onPressed: _submit,
            tooltip: 'Toggle Unit',
            backgroundColor: Color.fromARGB(255, 11, 145, 227),
            child: Icon(Icons.check),
          ),
        );
      },
    );
  }
}