/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter_blue/flutter_blue.dart';
import 'models/index.dart';
import 'dart:async';

/// Actions are a way to send data from a widget to a reducer via the dispatch method.
/// Each action class is used to identify the type of action, and the data member/s of
/// each class are used to represent the data being sent.

class SetCurrentMeasurement {
  final Measurement measurement;
  SetCurrentMeasurement(this.measurement);
}

class SetUnit {
  final String unit;
  SetUnit(this.unit);
}

class SetTargetWeight {
  final double weight;
  SetTargetWeight(this.weight);
}

class SetActualWeight {
  final double weight;
  SetActualWeight(this.weight);
}

class SetIsMeasuring {
  final bool isMeasuring;
  SetIsMeasuring(this.isMeasuring);
}

class SetBluetoothState {
  final BluetoothState bluetoothState;
  SetBluetoothState(this.bluetoothState);
}

class SetStateSubscription {
  final StreamSubscription btStateSubscription;
  SetStateSubscription(this.btStateSubscription);
}


class ResetDeviceState {
  ResetDeviceState();
}

class SetDevice {
  final BluetoothDevice device;
  SetDevice(this.device);
}

class SetDeviceConnection {
  final dynamic deviceConnection;
  SetDeviceConnection(this.deviceConnection);
}

class SetConnectionStatus {
  final BluetoothDeviceState connectionStatus;
  SetConnectionStatus(this.connectionStatus);
}

class SetService {
  final BluetoothService service;
  SetService(this.service);
}

class SetCharacteristic {
  final Guid uuid;
  final List characteristic;
  SetCharacteristic(this.uuid, this.characteristic);
}

class AddSubscription {
  final StreamSubscription subscription;
  AddSubscription(this.subscription);
}

class ClearSubscriptions {
  ClearSubscriptions();
}
