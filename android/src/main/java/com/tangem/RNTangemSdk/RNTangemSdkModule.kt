package com.tangem.RNTangemSdk

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter

import android.os.Handler
import android.os.Looper
import android.nfc.NfcAdapter

import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter

import com.google.gson.JsonSyntaxException
import com.squareup.sqldelight.android.AndroidSqliteDriver

import com.tangem.TangemSdk
import com.tangem.CardFilter
import com.tangem.Config
import com.tangem.Database
import com.tangem.Message
import com.tangem.TangemSdkError
import com.tangem.commands.WalletIndex
import com.tangem.commands.common.ResponseConverter
import com.tangem.common.CardValuesDbStorage
import com.tangem.common.CompletionResult
import com.tangem.common.extensions.calculateSha256
import com.tangem.common.extensions.hexToBytes
import com.tangem.commands.common.card.FirmwareType
import com.tangem.tangem_sdk_new.DefaultSessionViewDelegate
import com.tangem.tangem_sdk_new.TerminalKeysStorage
import com.tangem.tangem_sdk_new.extensions.localizedDescription
import com.tangem.tangem_sdk_new.nfc.NfcManager

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

import java.lang.ref.WeakReference
import java.util.EnumSet

class RNTangemSdkModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), LifecycleEventListener {
    private lateinit var nfcManager: NfcManager
    private lateinit var cardManagerDelegate: DefaultSessionViewDelegate
    private lateinit var sdk: TangemSdk
    private val handler = Handler(Looper.getMainLooper())
    private val converter = ResponseConverter()

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

        nfcManager = NfcManager().apply {
            setCurrentActivity(activity)
        }
        cardManagerDelegate = DefaultSessionViewDelegate(nfcManager, nfcManager.reader).apply { this.activity = activity }
        val config = Config(cardFilter = CardFilter(EnumSet.of(FirmwareType.Release)))

        val valueStorage = CardValuesDbStorage(AndroidSqliteDriver(Database.Schema, activity.applicationContext,
                "rn_cards.db"))

        val keyStorage = TerminalKeysStorage(activity.application)

        sdk = TangemSdk(nfcManager.reader, cardManagerDelegate, config, valueStorage, keyStorage)
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
            val args = options.toHashMap()
            sdk.scanCard(
                    walletIndex = this.getArg("walletIndex", args) as WalletIndex?,
                    initialMessage = this.getArg("initialMessage", args) as Message?
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun createWallet(options: ReadableMap, promise: Promise) {
        try {
            val args = options.toHashMap()
            sdk.createWallet(
                    cardId = this.getArg("cardId", args) as String?,
                    walletIndex = this.getArg("walletIndex", args) as Int?,
                    initialMessage = this.getArg("initialMessage", args) as Message?
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun purgeWallet(options: ReadableMap, promise: Promise) {
        try {
            val args = options.toHashMap()
            sdk.purgeWallet(
                    cardId = this.getArg("cardId", args) as String?,
                    walletIndex = WalletIndex.Index(this.getArg("walletIndex", args, 0) as Int) as WalletIndex,
                    initialMessage = this.getArg("initialMessage", args) as Message?
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun sign(hashes: ReadableArray, options: ReadableMap, promise: Promise) {
        try {
            val args = options.toHashMap()
            val hexHashes = hashes.toArrayList().map { it.toString().hexToBytes() }.toTypedArray()
            sdk.sign(
                    hashes = hexHashes,
                    cardId = this.getArg("cardId", args) as String?,
                    walletIndex = WalletIndex.Index(this.getArg("walletIndex", args, 0) as Int) as WalletIndex,
                    initialMessage = this.getArg("initialMessage", args) as Message?
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }


    @ReactMethod
    fun changePin1(options: ReadableMap, promise: Promise) {
        try {
            val args = options.toHashMap()
            val pin = this.getArg("pin", args, "") as String
            sdk.changePin1(
                    cardId = this.getArg("cardId", args) as String?,
                    pin = if (pin.isBlank()) null else pin.calculateSha256(),
                    initialMessage = this.getArg("initialMessage", args) as Message?
            ) { handleResult(it, promise) }
        } catch (ex: Exception) {
            handleException(ex, promise)
        }
    }

    @ReactMethod
    fun changePin2(options: ReadableMap, promise: Promise) {
        try {
            val args = options.toHashMap()
            val pin = this.getArg("pin", args, "") as String
            sdk.changePin2(
                    cardId = this.getArg("cardId", args) as String?,
                    pin = if (pin.isBlank()) null else pin.calculateSha256(),
                    initialMessage = this.getArg("initialMessage", args) as Message?
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
        reactContext.getJSModule(RCTDeviceEventEmitter::class.java).emit(event, payload)
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


    private fun getArg(key: String, args: HashMap<String, Any>, defaultValue: Any? = null): Any? {
        if (args.containsKey(key)) {
            if (key === "initialMessage") {
                if (args[key] !is HashMap<*, *>) {
                    return null
                }
                val message = args["initialMessage"] as HashMap<*, *>
                return Message(
                        header = message["header"] as String?,
                        body = message["body"] as String?
                )
            }
            return args[key]
        }
        return defaultValue
    }


    private fun normalizeResponse(resp: Any?): WritableMap {
        val jsonString = converter.gson.toJson(resp)
        val jsonObject = JSONObject(jsonString)
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
            val localizedDescription: String = if (ex is JsonSyntaxException) ex.cause.toString() else ex.toString()
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
