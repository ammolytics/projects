import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'model.dart';
import 'actions.dart';
import 'globals.dart' as globals;

import 'header.dart';
import 'sideDrawer.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  final String title = 'Trickler';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _counter = 0.0;
  String _unit = globals.grams;
  FocusNode _inputFocus = FocusNode();
  TextEditingController _controller = TextEditingController(text: '0.0');

  void _toggleUnit() {
    setState(() {
      if (_unit == globals.grams) {
        _counter *= 15.4324;
        _unit = globals.grains;
      } else if (_unit == globals.grains) {
        _counter /= 15.4324;
        _unit = globals.grams;
      }
    });
    _capCounterValue();
    _roundCounterValue();
  }

  void _updateCounter(text) {
    var newCount = double.parse(text);
    setState(() {
      _counter = newCount;
    });
  }

  void _roundCounterValue() {
    double value = double.parse(_counter.toStringAsFixed(4));
    int decimals = _unit == globals.grams ? 3 : 2;
    decimals = pow(10, decimals);
    value *= decimals;
    value = value.round() / decimals;
    setState(() {
      _counter = value;
      _controller.text = '$_counter';
    });
  }

  void _capCounterValue() {
    setState(() {
      if (_counter >= 1000.0) {
        _counter = 999.99;
      } else if (_counter < 0.0) {
        _counter = 0.0;
      }
    });
  }

  void _submit(List state) {
    Function dispatch = state.length > 0 ? state[0] : () => {};
    BluetoothDevice device = state.length > 1 ? state[1] : BluetoothDevice(id:DeviceIdentifier('000'));
    BluetoothService service = state.length > 2 ? state[2] : null;
    if (_inputFocus.hasFocus) {
      _inputFocus.unfocus();
    }
    _capCounterValue();
    _roundCounterValue();
    
    // Update global state with new measurement
    Measurement measure = Measurement(_unit, _counter, 0.0, false);
    dispatch(SetCurrentMeasurement(measure));

    print('Sending $_counter to ${device.name}');

    if (
      service?.characteristics != null &&
      service.characteristics.length > 2 &&
      service.characteristics[2].properties.write
    ) {
      // Write to trickler unit characteristic
      device.writeCharacteristic(service.characteristics[2],
        _unit == globals.grains ? [0] : [1]).then((value) {
          // Check unit characteristic was changed to the right value
          device.readCharacteristic(service.characteristics[2]).then((readChar) {
            print("\n\n\nUpdated Unit is ${readChar.toString() == (_unit == globals.grains ? '[0]' : '[1]')} - ${readChar.toString()}\n\n\n");
          });
        });
    }
  }

  String _getUnit() {
    return _unit == globals.grams ? 'g' : 'gr';
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
      drawer: SideDrawer(key: Key('SideDrawer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StoreConnector<AppState, BluetoothDevice>(
              converter: (store) => store.state.device,
              builder: (context, device) {
                if (device.id != DeviceIdentifier('000')) {
                  return Text("You are connected to: ${device.name}");
                }
                return Text('You are not connected to a device!');
              },
            ),
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
      floatingActionButton: StoreConnector<AppState, List>(
        converter: (store) {
          return [
            (action) => store.dispatch(action),
            store.state.device,
            store.state.service,
          ];
        },
        builder: (context, state) {
          return FloatingActionButton(
            heroTag: 'SubmitBtn',
            onPressed: () => _submit(state),
            tooltip: 'Toggle Unit',
            backgroundColor: Color.fromARGB(255, 11, 145, 227),
            child: Icon(Icons.check),
          );
        },
      ),
    );
  }
}