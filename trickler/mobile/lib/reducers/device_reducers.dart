/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

part of 'index.dart';

/// deviceStateReducer is the reducer that handles all actions related to the global deviceState data.

DeviceState deviceStateReducer(DeviceState state, dynamic action) {
  switch(action) {
    case ResetDeviceState:
      return new DeviceState.initialState();
      break;

    case SetDevice:
      state.setDevice(action.device);
      break;

    case SetDeviceConnection:
      state.setDeviceConnection(action.deviceConnection);
      break;

    case SetConnectionStatus:
      state.setConnectionStatus(action.connectionStatus);
      break;

    case SetService:
      state.setService(action.service);
      break;

    case SetCharacteristic:
      state.setCharacteristic(action.uuid, action.characteristic);
      break;

    case AddSubscription:
      state.characteristics.addSubscription(action.subscription);
      break;

    case ClearSubscriptions:
      state.characteristics.clearSubscriptions();
      break;
  }

  return state;
}
