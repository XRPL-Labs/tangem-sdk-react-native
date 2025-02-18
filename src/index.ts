import {
    Platform,
    NativeModules,
    DeviceEventEmitter,
    EmitterSubscription,
} from "react-native";

import {RNTangemSdkModule, EventCallback, Events} from "./types";


/* Native Module ==================================================================== */
const isTurboModuleEnabled = (global as any).__turboModuleProxy != null;

let NativeModule = isTurboModuleEnabled
    ? require('./specs/NativeTangemSdkModule').default
    : NativeModules.RNTangemSdk;

/* Override Methods ==================================================================== */
const TangemModuleProxy = {
    startSession: NativeModule.startSession,
    stopSession: NativeModule.stopSession,
    getNFCStatus: NativeModule.getNFCStatus,
    createWallet: NativeModule.createWallet,
    purgeWallet: NativeModule.purgeWallet,
    setAccessCode: NativeModule.setAccessCode,
    setPasscode: NativeModule.setPasscode,
    resetUserCodes: NativeModule.resetUserCodes,
    // looks like TurboModule does not go well with optional args :\
    scanCard: (options = {}) => {
        return NativeModule.scanCard(options)
    },
    // let do some double-check
    sign: (options) => {
        // hdPath is deprecated since version 2.0.4
        if (Object.prototype.hasOwnProperty.call(options, "hdPath")) {
            console.warn(
                `'hdPath' has been deprecated, please use 'derivationPath' instead!`
            );
            delete Object.assign(options, {["derivationPath"]: options["hdPath"]})[
                "hdPath"
                ];
        }

        return NativeModule.sign(options);
    },
    addListener: (
        eventName: Events,
        handler: (state: EventCallback) => void
    ): EmitterSubscription | undefined => {
        if (Platform.OS === "android") {
            return DeviceEventEmitter.addListener(eventName, handler);
        }
        return undefined;
    }

} as RNTangemSdkModule;


/* Export ==================================================================== */
export * from "./types";
export default TangemModuleProxy;
