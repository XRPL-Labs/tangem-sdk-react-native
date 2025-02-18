package com.tangem.RNTangemSdk


import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class RNTangemSdkPackage : BaseReactPackage() {
    override fun getModule(
        name: String,
        reactContext: ReactApplicationContext
    ): NativeModule? {
        when (name) {
            RNTangemSdkModule.REACT_CLASS -> return RNTangemSdkModule(reactContext)
        }
        return null
    }


    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
        return ReactModuleInfoProvider {
            val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
            val isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
            moduleInfos[RNTangemSdkModule.REACT_CLASS] = ReactModuleInfo(
                RNTangemSdkModule.REACT_CLASS,
                RNTangemSdkModule.REACT_CLASS,
                false,  // canOverrideExistingModule
                false,  // needsEagerInit
                false,  // isCxxModule
                isTurboModule // isTurboModule
            )
            moduleInfos
        }
    }
}
