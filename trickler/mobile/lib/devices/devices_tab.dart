part of 'index.dart';

class DevicesTab extends StatefulWidget {
  final Function nav;

  DevicesTab({Key key, this.nav}) : super(key: key);

  @override
  _DevicesTabState createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  int _screenIndex = 0;

  void _setScreenIndex(int i) {
      setState(() {
        _screenIndex = i;
      });
  }

  @override
  void initState() {
    super.initState();
    AppState appState = Provider.of<AppState>(context, listen: false);
    subToBTState(appState);
    if (appState.devices.length == 0) {
      print('Running auto scan...');
      _setScreenIndex(1);
    }
  }

  @override
  void dispose() {
    AppState appState = Provider.of<AppState>(context, listen: false);
    unsubToBTState(appState);
    super.dispose();
  }


  Widget _getScreen({Function setIndex, Function nav}) {
    final List<Widget> _screens = [
      PairedDevices(setIndex: setIndex, nav: nav),
      FindDevices(setIndex: setIndex),
    ];
    return _screens[_screenIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _getScreen(
        setIndex: (int i) => _setScreenIndex(i),
        nav: widget.nav
      ),
    );
  }
}