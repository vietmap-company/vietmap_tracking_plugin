import Flutter
import UIKit

public class VietmapTrackingPlugin: NSObject, FlutterPlugin {
  
  private static let userDefaultsKey = "vietmap_tracking_config"
  private static let apiKeyKey = "api_key"
  private static let endpointKey = "endpoint"
  private static let isInitializedKey = "is_initialized"
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "vietmap_tracking_plugin", binaryMessenger: registrar.messenger())
    let instance = VietmapTrackingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initialize":
      handleInitialize(call: call, result: result)
    case "setApiKey":
      handleSetApiKey(call: call, result: result)
    case "setEndpoint":
      handleSetEndpoint(call: call, result: result)
    case "getConfiguration":
      handleGetConfiguration(result: result)
    case "isInitialized":
      result(UserDefaults.standard.bool(forKey: VietmapTrackingPlugin.isInitializedKey))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let apiKey = args["apiKey"] as? String,
          let endpoint = args["endpoint"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "apiKey and endpoint are required", details: nil))
      return
    }
    
    let userDefaults = UserDefaults.standard
    userDefaults.set(apiKey, forKey: VietmapTrackingPlugin.apiKeyKey)
    userDefaults.set(endpoint, forKey: VietmapTrackingPlugin.endpointKey)
    userDefaults.set(true, forKey: VietmapTrackingPlugin.isInitializedKey)
    userDefaults.synchronize()
    
    result(nil)
  }
  
  private func handleSetApiKey(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let apiKey = args["apiKey"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "apiKey is required", details: nil))
      return
    }
    
    UserDefaults.standard.set(apiKey, forKey: VietmapTrackingPlugin.apiKeyKey)
    UserDefaults.standard.synchronize()
    result(nil)
  }
  
  private func handleSetEndpoint(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let endpoint = args["endpoint"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "endpoint is required", details: nil))
      return
    }
    
    UserDefaults.standard.set(endpoint, forKey: VietmapTrackingPlugin.endpointKey)
    UserDefaults.standard.synchronize()
    result(nil)
  }
  
  private func handleGetConfiguration(result: @escaping FlutterResult) {
    let userDefaults = UserDefaults.standard
    let isInitialized = userDefaults.bool(forKey: VietmapTrackingPlugin.isInitializedKey)
    
    guard isInitialized,
          let apiKey = userDefaults.string(forKey: VietmapTrackingPlugin.apiKeyKey),
          let endpoint = userDefaults.string(forKey: VietmapTrackingPlugin.endpointKey) else {
      result(nil)
      return
    }
    
    let config: [String: Any] = [
      "apiKey": apiKey,
      "endpoint": endpoint,
      "isInitialized": isInitialized
    ]
    
    result(config)
  }
}
