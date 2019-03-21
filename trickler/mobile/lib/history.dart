import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'model.dart';

import 'header.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({ Key key }) : super(key: key);

  final String title = 'Measurement History';

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  AppState _state;
  @override
  Widget build(BuildContext context) {
    setState(() {
      _state = StoreProvider.of<AppState>(context).state;
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
            Text('Target Weight ${_state.currentMeasurement.targetWeight}'),
          ],
        ),
      ),
    );
  }
}