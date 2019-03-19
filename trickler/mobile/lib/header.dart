import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'model.dart';

class Header extends StatelessWidget {
  Header({ Key key, this.title, this.iconColor, this.onClick }) : super(key: key);

  final String title;
  final Color iconColor;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(this.title),
      backgroundColor: Color.fromARGB(255, 56, 56, 56),
      actions: <Widget>[
        StoreConnector<AppState, List>(
          converter: (store) => [store.state.getStatusIcon(), store.state.getStatusColor()],
          builder: (context, status) {
            return SizedBox(
              width: 80.0,
              height: 60.0,
              child: Icon(status[0], color: status[1]),
            );
          }
        ),
      ],
    );
  }
}