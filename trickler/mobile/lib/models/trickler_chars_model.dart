part of 'index.dart';

class TricklerChars {
  bool autoMode;
  double actualWeight;
  double targetWeight;
  String stability;
  String unit;

  TricklerChars(
    this.autoMode,
    this.actualWeight,
    this.targetWeight,
    this.stability,
    this.unit,
  );

  TricklerChars.initialState()
  : autoMode = false,
    actualWeight = 0.0,
    targetWeight = 0.0,
    stability = UNSTABLE,
    unit = GRAINS;

  setCharacteristic(Guid uuid, List value) {
    switch(uuid.toString()) {
      case AUTO_MODE_CHAR_UUID:
        this.autoMode = value.length > 0;
        break;
      case WEIGHT_CHAR_UUID:
        this.actualWeight = double.parse(utf8.decode(value));
        break;
      case TARGET_WEIGHT_CHAR_UUID:
        this.targetWeight = double.parse(utf8.decode(value));
        break;
      case STABLE_CHAR_UUID:
        this.stability = STABILITY_LIST[value[0]];
        break;
      case UNIT_CHAR_UUID:
        this.unit = UNIT_LIST[value[0]];
        break;
      default:
        break;
    }
  }
}