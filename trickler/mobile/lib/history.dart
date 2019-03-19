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
            StoreConnector<AppState, String>(
              converter: (store) => store.state.currentMeasurement.targetWeight.toString(),
              builder: (context, weight) {
                return Text('Target Weight $weight');
              },
            ),
          ],
        ),
      ),
    );
  }
}