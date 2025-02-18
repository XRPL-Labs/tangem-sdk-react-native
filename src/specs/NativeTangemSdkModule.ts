import {TurboModule, TurboModuleRegistry} from 'react-native';
import type {UnsafeObject} from 'react-native/Libraries/Types/CodegenTypes';

export interface Spec extends TurboModule {
    startSession(options: UnsafeObject): Promise<void>;

    stopSession(): Promise<void>;

    scanCard(options?: UnsafeObject | null | undefined): Promise<UnsafeObject>;

    createWallet(options: UnsafeObject): Promise<UnsafeObject>;

    purgeWallet(options: UnsafeObject): Promise<UnsafeObject>;

    sign(options: UnsafeObject): Promise<UnsafeObject>;

    setAccessCode(options: UnsafeObject): Promise<UnsafeObject>;

    setPasscode(options: UnsafeObject): Promise<UnsafeObject>;

    resetUserCodes(options: UnsafeObject): Promise<UnsafeObject>;

    getNFCStatus(): Promise<UnsafeObject>;

}

export default TurboModuleRegistry.getEnforcing<Spec>('RNTangemSdk');
