import 'dart:math';
import 'package:flutter/material.dart';
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

  void _submit(Function dispatch) {
    if (_inputFocus.hasFocus) {
      _inputFocus.unfocus();
    }
    _capCounterValue();
    _roundCounterValue();

    Measurement measure = Measurement(_unit, _counter, 0.0, false);
    dispatch(SetCurrentMeasurement(measure));
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
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _controller,
                onChanged: _updateCounter,
                focusNode: _inputFocus,
                textAlign: TextAlign.center,
                key: Key('WeightInput'),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  // prefix is to center the value
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
      floatingActionButton: StoreConnector<AppState, Function>(
        converter: (store) {
          return (action) => store.dispatch(action);
        },
        builder: (context, dispatch) {
          return FloatingActionButton(
            heroTag: 'SubmitBtn',
            onPressed: () => _submit(dispatch),
            tooltip: 'Toggle Unit',
            backgroundColor: Color.fromARGB(255, 11, 145, 227),
            child: Icon(Icons.check),
          );
        },
      ),
    );
  }
}