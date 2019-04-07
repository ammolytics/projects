import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/index.dart';
import '../actions.dart';
import '../globals.dart';

import '../widgets/header.dart';
import '../widgets/side_drawer.dart';
import '../widgets/dial.dart';

class HomePage extends StatefulWidget {
  final Function connectToDevice;
  final Function disconnect;
  HomePage({ Key key, this.connectToDevice, this.disconnect }) : super(key: key);

  final String title = 'Trickler';
  final dialKey = new GlobalKey<DialState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppState _state;
  Function _dispatch;

  FocusNode _inputFocus = FocusNode();
  TextEditingController _controller = TextEditingController(text: '');

  void _toggleUnit() {
    double weight = _state.currentMeasurement.targetWeight;
    String unit = _state.currentMeasurement.unit;
    if (unit == GRAMS) {
      weight *= 15.4324;
      _dispatch(SetUnit(GRAINS));
      _dispatch(SetTargetWeight(weight));
      _updatePeripheralUnit(GRAINS);
    } else if (unit == GRAINS) {
      weight /= 15.4324;
      _dispatch(SetUnit(GRAMS));
      _dispatch(SetTargetWeight(weight));
      _updatePeripheralUnit(GRAMS);
    }
    _syncTextField();
    _syncDialState();
  }

  void _updatePeripheralUnit(unit) {
    BluetoothDevice device = _state.deviceState.device;
    BluetoothService service = _state.deviceState.service;
    BluetoothCharacteristic unitChar = service.characteristics
      .where((char) => char.uuid.toString() == UNIT_CHAR_UUID).single;

    if (
      unitChar != null &&
      unitChar.properties.write
    ) {
      // Write to trickler unit characteristic
      device.writeCharacteristic(
        unitChar,
        unit == GRAINS ? [0x00] : [0x01],
        type: CharacteristicWriteType.withResponse);
    }
  }

  void _updateWeight(double weight) {
    _updateCounter(weight.toString());
    _syncTextField();
    _syncDialState();
  }

  void _updateCounter(text) {
    var newWeight = double.parse(text);
    _dispatch(SetTargetWeight(newWeight));
    _syncDialState();
  }

  void _handleIncrement(bool shouldIncrement) {
    double weight = _state.currentMeasurement.targetWeight;
    double diff = _state.currentMeasurement.unit == GRAMS ? 0.001 : 0.02;
    weight = shouldIncrement ? weight + diff : weight - diff;
    _updateWeight(weight);
  }

  void _submit() {
    BluetoothDevice device = _state.deviceState.device;
    double targetWeight = _state.currentMeasurement.targetWeight;
    _syncTextField();
    _syncDialState();
    print('Sending $targetWeight to ${device.name}');
  }

  void _syncTextField() {
    double targetWeight = _state.currentMeasurement.targetWeight;
    setState(() {
      _controller.text = '$targetWeight';
      if (_inputFocus.hasFocus) {
        _inputFocus.unfocus();
      }
    });
  }

  void _syncDialState() {
    double targetWeight = _state.currentMeasurement.targetWeight;
    setState(() {
      widget.dialKey.currentState.setAngleFromValue(targetWeight);
    });
  }

  String _getUnit() {
    String unit = _state.currentMeasurement.unit;
    List<String> abbr = ['gr', 'g'];
    int i = UNIT_LIST.indexOf(unit);
    return abbr[i];
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
            child: Dial(
              key: widget.dialKey,
              updateWeight: _updateWeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(50.0, 60.0, 50.0, 20.0),
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                      controller: _controller,
                      onChanged: _updateCounter,
                      onEditingComplete: _syncTextField,
                      focusNode: _inputFocus,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      key: Key('WeightInput'),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.0',
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
                  Container(
                    width: 200.0,
                    height: 60.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: 'RemoveBtn',
                          onPressed: () => _handleIncrement(false),
                          tooltip: "Remove ${_state.currentMeasurement.unit == GRAMS ? '0.001g' : '0.02gr'}",
                          child: Icon(Icons.remove),
                          backgroundColor: Colors.redAccent,
                        ),
                        FloatingActionButton(
                          heroTag: 'AddBtn',
                          onPressed: () => _handleIncrement(true),
                          tooltip: "Add ${_state.currentMeasurement.unit == GRAMS ? '0.001g' : '0.02gr'}",
                          child: Icon(Icons.add),
                          backgroundColor: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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