package com.tangem.RNTangemSdk

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NfcAdapter
import android.os.Handler
import android.os.Looper
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter

import com.tangem.TangemSdk
import com.tangem.Message
import com.tangem.common.hdWallet.DerivationPath
import com.tangem.common.card.EllipticCurve
import com.tangem.common.core.TangemSdkError
import com.tangem.common.core.Config
import com.tangem.common.json.MoshiJsonConverter
import com.tangem.common.services.secure.SecureStorage
import com.tangem.common.CompletionResult
import com.tangem.common.extensions.hexToBytes
import com.tangem.tangem_sdk_new.DefaultSessionViewDelegate
import com.tangem.tangem_sdk_new.extensions.localizedDescription
import com.tangem.tangem_sdk_new.nfc.NfcManager
import com.tangem.tangem_sdk_new.storage.create

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.lang.ref.WeakReference



class RNTangemSdkModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), LifecycleEventListener {
    private lateinit var nfcManager: NfcManager
    private lateinit var sdk: TangemSdk
    private val handler = Handler(Looper.getMainLooper())
    private val converter = MoshiJsonConverter.INSTANCE

    private var sessionStarted = false

    override fun getName(): String {
        return "RNTangemSdk"
    }

    override fun initialize() {
        super.initialize()

        val activity = currentActivity
        wActivity = WeakReference(currentActivity)

        activity ?: let {
            return
        }

        nfcManager = NfcManager().apply { setCurrentActivity(activity) }
        val cardManagerDelegate = DefaultSessionViewDelegate(nfcManager, nfcManager.reader).apply { this.activity = activity }
        val keyStorage = SecureStorage.create(activity)

        sdk = TangemSdk(nfcManager.reader, cardManagerDelegate, keyStorage, Config())
    }

    override fun onHostResume() {
        if (::nfcManager.isInitialized) {
            // check if activity is destroyed
            val activity = wActivity.get()
            activity ?: let {
                return
            }
            // if activity destroyed initialize again
            if (activity.isDestroyed() || activity.isFinishing()) {
                initialize()
            } else {
                if (sessionStarted) {
                    nfcManager.onStart()
                }
            }
        }
    }

    override fun onHostPause() {
        if (::nfcManager.isInitialized) {
            if (sessionStarted) {
                nfcManager.onStop()
            }
        }
    }

    override fun onHostDestroy() {
        if (::nfcManager.isInitialized) {
            nfcManager.onDestroy()
        }
    }


    @ReactMethod
    fun startSession(promise: Promise) {
        try {
            if (!sessionStarted) {
                if (::nfcManager.isInitialized) {
                    nfcManager.onStart()

                    sessionStarted = true

                    promise.resolve(null)
                } else {
                    promise.reject("NOT_INITIALIZED", "nfcManager is not initialized", null)
                }
            } else {
                // session already started
                promise.resolve(null)
            }
        } catch (ex: Exception) {
            promise.reject(ex)
        }
    }

    @ReactMethod
    fun stopSession(promise: Promise) {
        try {
            if (sessionStarted) {
                if (::nfcManager.isInitialized) {
                    nfcManager.onStop()

                    sessionStarted = false

                    promise.resolve(null)
                } else {
                    promise.reject("NOT_INITIALIZED", "nfcManager is not initialized", null)
                }
            } else {
                // session already stopped
                promise.resolve(null)
            }
        } catch (ex: Exception) {
            promise.reject(ex)
        }
    }


    @ReactMethod
    fun scanCard(options: ReadableMap, promise: Promise) {
        try {
            val optionsParser = OptionsParser(options)
            sdk.scanCard(
                    initialMessage = optionsParser.getInitialMessage()
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun createWallet(options: ReadableMap, promise: Promise) {
        try {
            val optionsParser = OptionsParser(options)
            sdk.createWallet(
                    curve = optionsParser.getCurve(),
                    cardId = optionsParser.getCardId(),
                    initialMessage = optionsParser.getInitialMessage()
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun purgeWallet(options: ReadableMap, promise: Promise) {
        try {
            val optionsParser = OptionsParser(options)
            sdk.purgeWallet(
                    walletPublicKey = optionsParser.getWalletPublicKey(),
                    cardId = optionsParser.getCardId(),
                    initialMessage = optionsParser.getInitialMessage()
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun sign(options: ReadableMap, promise: Promise) {
        try {
            val optionsParser = OptionsParser(options)
            sdk.sign(
                    hashes = optionsParser.getHashes(),
                    walletPublicKey = optionsParser.getWalletPublicKey(),
                    cardId = optionsParser.getCardId(),
                    hdPath = optionsParser.getHdPath(),
                    initialMessage = optionsParser.getInitialMessage()
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }


    @ReactMethod
    fun setAccessCode(options: ReadableMap, promise: Promise) {
        try {
            val optionsParser = OptionsParser(options)
            sdk.setAccessCode(
                    accessCode = optionsParser.getAccessCode(),
                    cardId = optionsParser.getCardId(),
                    initialMessage = optionsParser.getInitialMessage()
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun setPasscode(options: ReadableMap, promise: Promise) {
        try {
            val optionsParser = OptionsParser(options)
            sdk.setPasscode(
                    passcode = optionsParser.getPasscode(),
                    cardId = optionsParser.getCardId(),
                    initialMessage = optionsParser.getInitialMessage()
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun resetUserCodes(options: ReadableMap, promise: Promise) {
        try {
            val optionsParser = OptionsParser(options)
            sdk.resetUserCodes(
                    cardId = optionsParser.getCardId(),
                    initialMessage = optionsParser.getInitialMessage()
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }


    @ReactMethod
    fun getNFCStatus(promise: Promise) {
        val nfcAdapter = NfcAdapter.getDefaultAdapter(reactContext)

        val payload = Arguments.createMap()

        if (nfcAdapter != null) {
            payload.putBoolean("support", true)
            if (nfcAdapter.isEnabled) {
                payload.putBoolean("enabled", true)
            } else {
                payload.putBoolean("enabled", false)
            }
        } else {
            payload.putBoolean("support", false)
            payload.putBoolean("enabled", false)
        }

        return promise.resolve(payload)
    }

    private fun sendEvent(event: String, payload: WritableMap) {
        if (reactContext.hasActiveCatalystInstance()) {
            reactContext.getJSModule(RCTDeviceEventEmitter::class.java).emit(event, payload)
        }
    }

    private val mReceiver: BroadcastReceiver =
            object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent) {
                    val action = intent.action
                    if (action == NfcAdapter.ACTION_ADAPTER_STATE_CHANGED) {
                        val state = intent.getIntExtra(
                                NfcAdapter.EXTRA_ADAPTER_STATE, NfcAdapter.STATE_OFF
                        )
                        val payload = Arguments.createMap()
                        when (state) {
                            NfcAdapter.STATE_OFF -> {
                                payload.putBoolean("enabled", false)
                                sendEvent("NFCStateChange", payload)
                            }
                            NfcAdapter.STATE_ON -> {
                                payload.putBoolean("enabled", true)
                                sendEvent("NFCStateChange", payload)
                            }
                        }
                    }
                }
            }


    @Throws(JSONException::class)
    fun toWritableMap(jsonObject: JSONObject): WritableMap {
        val writableMap = Arguments.createMap()
        val iterator = jsonObject.keys()
        while (iterator.hasNext()) {
            val key = iterator.next() as String
            val value = jsonObject.get(key)
            if (value is Float || value is Double) {
                writableMap.putDouble(key, jsonObject.getDouble(key))
            } else if (value is Number) {
                writableMap.putInt(key, jsonObject.getInt(key))
            } else if (value is String) {
                writableMap.putString(key, jsonObject.getString(key))
            } else if (value is Boolean) {
                writableMap.putBoolean(key, jsonObject.getBoolean(key))
            } else if (value is JSONObject) {
                writableMap.putMap(key, toWritableMap(jsonObject.getJSONObject(key)))
            } else if (value is JSONArray) {
                writableMap.putArray(key, toWritableMap(jsonObject.getJSONArray(key)))
            } else if (value === JSONObject.NULL) {
                writableMap.putNull(key)
            }
        }

        return writableMap
    }

    @Throws(JSONException::class)
    fun toWritableMap(jsonArray: JSONArray): WritableArray {
        val writableArray = Arguments.createArray()
        for (i in 0 until jsonArray.length()) {
            val value = jsonArray.get(i)
            if (value is Float || value is Double) {
                writableArray.pushDouble(jsonArray.getDouble(i))
            } else if (value is Number) {
                writableArray.pushInt(jsonArray.getInt(i))
            } else if (value is String) {
                writableArray.pushString(jsonArray.getString(i))
            } else if (value is Boolean) {
                writableArray.pushBoolean(jsonArray.getBoolean(i))
            } else if (value is JSONObject) {
                writableArray.pushMap(toWritableMap(jsonArray.getJSONObject(i)))
            } else if (value is JSONArray) {
                writableArray.pushArray(toWritableMap(jsonArray.getJSONArray(i)))
            } else if (value === JSONObject.NULL) {
                writableArray.pushNull()
            }
        }
        return writableArray
    }

    private fun normalizeResponse(resp: Any?): WritableMap {
        val jsonObject = when (resp) {
            is String -> JSONObject(resp)
            else -> JSONObject(converter.toJson(resp))
        }
        return toWritableMap(jsonObject)
    }


    private fun handleResult(completionResult: CompletionResult<*>, promise: Promise) {
        when (completionResult) {
            is CompletionResult.Success<*> -> {
                handler.post { promise.resolve(normalizeResponse(completionResult.data)) }
            }
            is CompletionResult.Failure<*> -> {
                val error = completionResult.error
                val errorMessage = if (error is TangemSdkError) {
                    val activity = wActivity.get()
                    if (activity == null) error.customMessage else error.localizedDescription(activity)
                } else {
                    error.customMessage
                }
                handler.post {
                    promise.reject("${error.code}", errorMessage, null)
                }
            }
        }
    }

    private fun handleException(ex: Exception, promise: Promise) {
        handler.post {
            val code = 9999
            val localizedDescription: String = ex.toString()
            promise.reject("$code", localizedDescription, null)
        }
    }

    init {
        reactContext.addLifecycleEventListener(this)
        val filter = IntentFilter(NfcAdapter.ACTION_ADAPTER_STATE_CHANGED)
        reactContext.registerReceiver(mReceiver, filter)
    }


    companion object {
        lateinit var wActivity: WeakReference<Activity?>
    }
}


class RquiredArgumentException(arg: String) : Exception(arg)


class OptionsParser(options: ReadableMap) {
    val options: ReadableMap = options

    fun getInitialMessage(): Message? {
        if (!options.hasKey("initialMessage")) return null

        if (options.getMap("initialMessage") !is ReadableMap) {
            return null
        }
        val message = options.getMap("initialMessage") as ReadableMap

        val header = if (message.hasKey("header")) message.getString("header") else ""
        val body = if (message.hasKey("body")) message.getString("body") else ""
        return Message(
                header,
                body
        )
    }

    fun getWalletPublicKey(): ByteArray {
        val walletPublicKey = options.getString("walletPublicKey")
        if (walletPublicKey.isNullOrEmpty()) {
            throw RquiredArgumentException("walletPublicKey is required")
        }
        return walletPublicKey.hexToBytes()
    }

    fun getCardId(): String {
        val cardId = options.getString("cardId")
        if (cardId.isNullOrEmpty()) {
            throw RquiredArgumentException("cardId is required")
        }
        return cardId
    }


    fun getCurve(): EllipticCurve {
        return when (options.getString("curve")) {
            "ed25519" -> EllipticCurve.Ed25519
            "secp256k1" -> EllipticCurve.Secp256k1
            "secp256r1" -> EllipticCurve.Secp256r1
            else -> {
                EllipticCurve.Secp256k1
            }
        }
    }

    fun getHashes(): Array<ByteArray> {
        val hashes = options.getArray("hashes")
        if (hashes === null || hashes.size() === 0) {
            throw RquiredArgumentException("hashes is required")
        }
        return hashes.toArrayList().map { it.toString().hexToBytes() }.toTypedArray()
    }


    fun getHdPath(): DerivationPath? {
        val hdPath = options.getString("hdPath")
        if (hdPath.isNullOrEmpty()) {
            return null;
        }
        return DerivationPath(rawPath = hdPath)
    }


    fun getAccessCode(): String? {
        val accessCode = options.getString("accessCode")
        if (accessCode.isNullOrEmpty()) {
            return null
        }
        return accessCode
    }

    fun getPasscode(): String? {
        val passcode = options.getString("passcode")
        if (passcode.isNullOrEmpty()) {
            return null
        }
        return passcode
    }


}
