/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
part of 'index.dart';

class TricklerChars {
  List<StreamSubscription> subscriptions;
  bool autoMode;
  double actualWeight;
  double targetWeight;
  String stability;
  String unit;

  TricklerChars(
    this.subscriptions,
    this.autoMode,
    this.actualWeight,
    this.targetWeight,
    this.stability,
    this.unit,
  );

  TricklerChars.initialState()
  : subscriptions = [],
    autoMode = false,
    actualWeight = 0.0,
    targetWeight = 0.0,
    stability = UNSTABLE,
    unit = GRAINS;

  addSubscription(StreamSubscription subscription) {
    this.subscriptions.add(subscription);
  }

  clearSubscriptions() {
    this.subscriptions = [];
  }

  setCharacteristic(Guid uuid, List value) {
    switch(uuid.toString()) {
      case AUTO_MODE_CHAR_UUID:
        this.autoMode = value[0] != 0;
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