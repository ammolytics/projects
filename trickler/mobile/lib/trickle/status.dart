part of 'index.dart';

Widget getStatusRow(AppState appState) {
  double weight = getValue(getChar(appState, WEIGHT_CHAR_UUID), 0.0);
  String unit = UNIT_LIST[getInt(getChar(appState, UNIT_CHAR_UUID), 0)];
  String stability = STABILITY_LIST[getInt(getChar(appState, STABLE_CHAR_UUID), 5)];
  return Padding(
    padding: EdgeInsets.only(top: 20),
    child: Row(
      mainAxisAlignment:  MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text('$weight $unit',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold
          )
        ),
        Text(stability,
          style: TextStyle(
            fontSize: 15,
            color: Color.fromARGB(150, 0, 0, 0)
          )
        ),
        getStatusIcon(appState)
      ],
    ),
  );
}

Widget getStatusIcon(AppState appState) {
  double weight = getValue(getChar(appState, WEIGHT_CHAR_UUID), 0.0);
  double target = getValue(getChar(appState, TARGET_WEIGHT_CHAR_UUID), 0.0);
  return weight == target ?
    Text('=', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)) :
    Icon(weight > target ? Icons.arrow_forward_ios : Icons.arrow_back_ios);
}