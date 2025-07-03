package com.example.vietmap_tracking_plugin

import android.content.Context
import android.content.SharedPreferences
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** VietmapTrackingPlugin */
class VietmapTrackingPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var preferences: SharedPreferences
  
  companion object {
    private const val PREFS_NAME = "vietmap_tracking_prefs"
    private const val KEY_API_KEY = "api_key"
    private const val KEY_ENDPOINT = "endpoint"
    private const val KEY_IS_INITIALIZED = "is_initialized"
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vietmap_tracking_plugin")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "initialize" -> {
        handleInitialize(call, result)
      }
      "setApiKey" -> {
        handleSetApiKey(call, result)
      }
      "setEndpoint" -> {
        handleSetEndpoint(call, result)
      }
      "getConfiguration" -> {
        handleGetConfiguration(result)
      }
      "isInitialized" -> {
        result.success(preferences.getBoolean(KEY_IS_INITIALIZED, false))
      }
      else -> {
        result.notImplemented()
      }
    }
  }
  
  private fun handleInitialize(call: MethodCall, result: Result) {
    try {
      val apiKey = call.argument<String>("apiKey")
      val endpoint = call.argument<String>("endpoint")
      val additionalConfig = call.argument<Map<String, Any>>("additionalConfig")
      
      if (apiKey == null || endpoint == null) {
        result.error("INVALID_ARGUMENTS", "apiKey and endpoint are required", null)
        return
      }
      
      preferences.edit()
        .putString(KEY_API_KEY, apiKey)
        .putString(KEY_ENDPOINT, endpoint)
        .putBoolean(KEY_IS_INITIALIZED, true)
        .apply()
      
      result.success(null)
    } catch (e: Exception) {
      result.error("INITIALIZATION_ERROR", e.message, null)
    }
  }
  
  private fun handleSetApiKey(call: MethodCall, result: Result) {
    try {
      val apiKey = call.argument<String>("apiKey")
      if (apiKey == null) {
        result.error("INVALID_ARGUMENTS", "apiKey is required", null)
        return
      }
      
      preferences.edit()
        .putString(KEY_API_KEY, apiKey)
        .apply()
      
      result.success(null)
    } catch (e: Exception) {
      result.error("SET_API_KEY_ERROR", e.message, null)
    }
  }
  
  private fun handleSetEndpoint(call: MethodCall, result: Result) {
    try {
      val endpoint = call.argument<String>("endpoint")
      if (endpoint == null) {
        result.error("INVALID_ARGUMENTS", "endpoint is required", null)
        return
      }
      
      preferences.edit()
        .putString(KEY_ENDPOINT, endpoint)
        .apply()
      
      result.success(null)
    } catch (e: Exception) {
      result.error("SET_ENDPOINT_ERROR", e.message, null)
    }
  }
  
  private fun handleGetConfiguration(result: Result) {
    try {
      val apiKey = preferences.getString(KEY_API_KEY, null)
      val endpoint = preferences.getString(KEY_ENDPOINT, null)
      val isInitialized = preferences.getBoolean(KEY_IS_INITIALIZED, false)
      
      if (!isInitialized || apiKey == null || endpoint == null) {
        result.success(null)
        return
      }
      
      val config = mapOf(
        "apiKey" to apiKey,
        "endpoint" to endpoint,
        "isInitialized" to isInitialized
      )
      
      result.success(config)
    } catch (e: Exception) {
      result.error("GET_CONFIG_ERROR", e.message, null)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
