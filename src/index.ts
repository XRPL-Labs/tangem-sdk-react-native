import { Platform, NativeModules, DeviceEventEmitter } from "react-native";

import { RNTangemSdkModule, EventCallback, Events } from "./types";

const { RNTangemSdk } = NativeModules;

/**
 * Listen for available events (Android)
 * @param  {String} eventName Name of event NFCStateChange
 * @param  {Function} handler Event handler
 */
RNTangemSdk.on = (
  eventName: Events,
  handler: (state: EventCallback) => void
) => {
  if (Platform.OS === "android") {
    DeviceEventEmitter.addListener(eventName, handler);
  }
};

/**
 * Stop listening for event (Android)
 * @param  {String} eventName Name of event NFCStateChange
 * @param  {Function} handler Event handler
 */
RNTangemSdk.removeListener = (
  eventName: Events,
  handler: (state: EventCallback) => void
) => {
  if (Platform.OS === "android") {
    DeviceEventEmitter.removeListener(eventName, handler);
  }
};

// export all types
export * from "./types";

// export module
export default RNTangemSdk as RNTangemSdkModule;
