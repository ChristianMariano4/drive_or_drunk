import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Set up method channel to receive API key from Flutter
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "google_api_key", binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler { (call, result) in
            if call.method == "setApiKey" {
                if let apiKey = call.arguments as? String {
                    GMSServices.provideAPIKey(apiKey)
                    result("success")
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "API key is required", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}