import 'dart:convert' show utf8;
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
      _updatePeripheralChar(UNIT_CHAR_UUID, [0x00]).then((_) {
        _updatePeripheralChar(TARGET_WEIGHT_CHAR_UUID, utf8.encode('${_state.currentMeasurement.targetWeight}'));
      });
    } else if (unit == GRAINS) {
      weight /= 15.4324;
      _dispatch(SetUnit(GRAMS));
      _dispatch(SetTargetWeight(weight));
      _updatePeripheralChar(UNIT_CHAR_UUID, [0x01]).then((_) {
        _updatePeripheralChar(TARGET_WEIGHT_CHAR_UUID, utf8.encode('${_state.currentMeasurement.targetWeight}'));
      });
    }
    _sync();
  }

  Future _updatePeripheralChar(String uuid, dynamic value) {
    BluetoothDevice device = _state.deviceState.device;
    BluetoothService service = _state.deviceState.service;
    dynamic characteristic = service?.characteristics != null ?
      service.characteristics.where((char) => char.uuid.toString() == uuid).single : null;

    if (characteristic != null && characteristic.properties.write) {
      return device.writeCharacteristic(characteristic, value,
        type: CharacteristicWriteType.withResponse);
    }
    return Future(() {});
  }

  void _updateWeight(double weight) {
    _updateCounter(weight.toString());
    _sync();
  }

  void _updateCounter(text) {
    var newWeight = text.length > 0 ?
      double.parse(text) : 0.0;
    _dispatch(SetTargetWeight(newWeight));
    _syncDialState();
  }

  void _handleIncrement(bool shouldIncrement) {
    double weight = _state.currentMeasurement.targetWeight;
    double diff = _state.currentMeasurement.unit == GRAMS ? 0.001 : 0.02;
    weight = shouldIncrement ? weight + diff : weight - diff;
    _updateWeight(weight);
  }

  void _toggleAutoMode() {
    bool autoMode = _state.deviceState.characteristics.autoMode;
    _updatePeripheralChar(AUTO_MODE_CHAR_UUID, autoMode ? [0x00] : [0x01]);
  }

  void _sync() {
    _syncTextField();
    _syncDialState();
    double weight = _state.currentMeasurement.targetWeight;
    if (_state.deviceState.characteristics.targetWeight != weight) {
      _updatePeripheralChar(TARGET_WEIGHT_CHAR_UUID, utf8.encode('$weight'));
    }
  }

  void _syncTextField() {
    double targetWeight = _state.currentMeasurement.targetWeight;
    String unit = _state.currentMeasurement.unit;
    setState(() {
      _controller.text = targetWeight == 0.0 ? '' : targetWeight.toStringAsFixed(unit == GRAINS ? 2 : 3);
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
    return _getAbbrFromUnit(['gr', 'g']);
  }

  String _getAbbrFromUnit(List<String> abbr) {
    String unit = _state.currentMeasurement.unit;
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
                      onEditingComplete: _sync,
                      focusNode: () {
                        _inputFocus.addListener(() { setState(() {}); });
                        return _inputFocus;
                      }(),
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      key: Key('WeightInput'),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: _getAbbrFromUnit(['0.00', '0.000']),
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
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _inputFocus.hasFocus ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: FloatingActionButton(
                  heroTag: 'closeKeyboard',
                  onPressed: _sync,
                  tooltip: 'Close Keyboard',
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.keyboard_hide),
                  mini: true,
                ),
              ) : _state.deviceState.characteristics.autoMode ?
              FloatingActionButton(
                heroTag: 'turnAutoModeOff',
                onPressed: _toggleAutoMode,
                tooltip: 'Turn Off Auto Mode',
                backgroundColor: Colors.red,
                child: Icon(Icons.pause),
              ) : FloatingActionButton(
                heroTag: 'turnAutoModeOn',
                onPressed: _toggleAutoMode,
                tooltip: 'Turn On Auto Mode',
                backgroundColor: Colors.blue,
                child: Icon(Icons.play_arrow),
              ),
            ],
          ),
        );
      },
    );
  }
}