import 'package:opentrickler/appstate.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert' show utf8;

List<int> getChar(AppState appState, String uuid) => appState.tricklerChars[Guid(uuid)];
int getInt(List<int> char, int def) => char != null ? char[0] : def;
double getValue(List<int> char, double def) => char != null ? double.parse(utf8.decode(char)) : def;
