import 'package:flutter/material.dart';

class PairedDevices extends StatefulWidget {
  final Function setIndex;

  PairedDevices({Key key, this.setIndex});

  @override
  _PairedDevicesState createState() => _PairedDevicesState();
}

class _PairedDevicesState extends State<PairedDevices> {
  void _addADevice() {
    widget.setIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Text('Paired Devices',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold
            )
          ),
        ),
        RaisedButton(
          onPressed: _addADevice,
          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
          child: Text('Add a Device')
        ),
      ],
    );
  }
}

class FindDevices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('Find Devices...'),
      ],
    );
  }
}

class DevicesTab extends StatefulWidget {
  @override
  _DevicesTabState createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  int _screenIndex = 0;

  Widget _getScreen(Function setIndex) {
    final List<Widget> _screens = [
      PairedDevices(setIndex: setIndex),
      FindDevices(),
    ];
    return _screens[_screenIndex];
  }

  void _setScreenIndex(int i) {
      setState(() {
        _screenIndex = i;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _getScreen((int i) => _setScreenIndex(i))
    );
  }
}