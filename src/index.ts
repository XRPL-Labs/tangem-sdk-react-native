import { Platform, NativeModules, DeviceEventEmitter } from "react-native";

import { RNTangemSdkModule, EventCallback, Events } from "./types";

const { RNTangemSdk } = NativeModules;

const TangemModuleProxy = {} as RNTangemSdkModule;
/* Methods ==================================================================== */
/**
 * Listen for available events
 * #### (Android specific)
 * @param  {String} eventName Name of event NFCStateChange
 * @param  {Function} handler Event handler
 */
TangemModuleProxy.on = (
  eventName: Events,
  handler: (state: EventCallback) => void
) => {
  if (Platform.OS === "android") {
    DeviceEventEmitter.addListener(eventName, handler);
  }
};

/**
 * Stop listening for event
 * #### (Android specific)
 * @param  {String} eventName Name of event NFCStateChange
 * @param  {Function} handler Event handler
 */
TangemModuleProxy.removeListener = (
  eventName: Events,
  handler: (state: EventCallback) => void
) => {
  if (Platform.OS === "android") {
    DeviceEventEmitter.removeListener(eventName, handler);
  }
};

/**
 * Start Session/NFC Manager and it's recommended to be called before any other command.
 * #### (Android specific)
 */
TangemModuleProxy.startSession = () => {
  if (Platform.OS === "android") {
    return RNTangemSdk.startSession();
  }
  return Promise.resolve(null);
};
/**
 * Stop Session/NFC Manager and it's recommended to be called to stop the session.
 * #### (Android specific)
 */
TangemModuleProxy.stopSession = () => {
  if (Platform.OS === "android") {
    return RNTangemSdk.stopSession();
  }
  return Promise.resolve(null);
};

/**
 * Return current NFC Status
 */
TangemModuleProxy.getNFCStatus = () => {
  return RNTangemSdk.getNFCStatus();
};
/**
 * Scan & obtain information from the Tangem card.
 */
TangemModuleProxy.scanCard = (options = {}) => {
  return RNTangemSdk.scanCard(options);
};
/**
 * create a new wallet on the card
 */
TangemModuleProxy.createWallet = (options = {}) => {
  return RNTangemSdk.createWallet(options);
};
/**
 * delete all wallet data on the card.
 */
TangemModuleProxy.purgeWallet = (options = {}) => {
  return RNTangemSdk.purgeWallet(options);
};
/**
 * Sign one or multiple hashes
 */
TangemModuleProxy.sign = (hashes, options = {}) => {
  if (!hashes) {
    throw new Error("hashes argument is required.");
  }
  if (!(hashes instanceof Array)) {
    throw new Error("hashes argument should be array of string!");
  }
  return RNTangemSdk.sign(hashes, options);
};
/**
 * change Pin1 on the card
 */
TangemModuleProxy.changePin1 = (options = {}) => {
  return RNTangemSdk.changePin1(options);
};
/**
 * change Pin2 on the card
 */
TangemModuleProxy.changePin2 = (options = {}) => {
  return RNTangemSdk.changePin2(options);
};

/* Export ==================================================================== */
// export all types
export * from "./types";

// export module
export default TangemModuleProxy;
