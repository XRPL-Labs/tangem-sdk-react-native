import {
  Platform,
  NativeModules,
  DeviceEventEmitter,
  EmitterSubscription,
} from "react-native";

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
TangemModuleProxy.addListener = (
  eventName: Events,
  handler: (state: EventCallback) => void
): EmitterSubscription | undefined => {
  if (Platform.OS === "android") {
    return DeviceEventEmitter.addListener(eventName, handler);
  }
  return undefined;
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
 * Create a new wallet on the card
 */
TangemModuleProxy.createWallet = (options) => {
  return RNTangemSdk.createWallet(options);
};
/**
 * Delete all wallet data on the card.
 */
TangemModuleProxy.purgeWallet = (options) => {
  return RNTangemSdk.purgeWallet(options);
};
/**
 * Sign one or multiple hashes
 */
TangemModuleProxy.sign = (options) => {
  // hdPath is deprecated since version 2.0.4
  if (Object.prototype.hasOwnProperty.call(options, "hdPath")) {
    console.warn(
      `'hdPath' has been deprecated, please use 'derivationPath' instead!`
    );
    delete Object.assign(options, { ["derivationPath"]: options["hdPath"] })[
      "hdPath"
    ];
  }

  return RNTangemSdk.sign(options);
};
/**
 * Change/set accessCode on the card
 */
TangemModuleProxy.setAccessCode = (options) => {
  return RNTangemSdk.setAccessCode(options);
};
/**
 * Change/set passCode on the card
 */
TangemModuleProxy.setPasscode = (options) => {
  return RNTangemSdk.setPasscode(options);
};
/**
 * Reset all user codes on the card
 */
TangemModuleProxy.resetUserCodes = (options) => {
  return RNTangemSdk.resetUserCodes(options);
};

/* Export ==================================================================== */
// export all types
export * from "./types";

// export module
export default TangemModuleProxy;
