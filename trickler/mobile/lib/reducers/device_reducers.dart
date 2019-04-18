/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

part of 'index.dart';

/// deviceStateReducer is the reducer that handles all actions related to the global deviceState data.

DeviceState deviceStateReducer(DeviceState state, dynamic action) {
  if (action is ResetDeviceState) {
    return new DeviceState.initialState();
  } else if (action is SetDevice) {
    state.setDevice(action.device);
  } else if (action is SetDeviceConnection) {
    state.setDeviceConnection(action.deviceConnection);
  } else if (action is SetConnectionStatus) {
    state.setConnectionStatus(action.connectionStatus);
  } else if (action is SetService) {
    state.setService(action.service);
  } else if (action is SetCharacteristic) {
    state.setCharacteristic(action.uuid, action.characteristic);
  } else if (action is AddSubscription) {
    state.characteristics.addSubscription(action.subscription);
  } else if (action is ClearSubscriptions) {
    state.characteristics.clearSubscriptions();
  }
  return state;
}
