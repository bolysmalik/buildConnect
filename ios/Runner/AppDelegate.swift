import UIKit
import Flutter
//import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

   // FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    DispatchQueue.main.async {
      if let controller = self.window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "valhalla_channel", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { call, result in
          ValhallaRoutingService.handle(call, result: result)
        }
      } else {
        print("❌ FlutterViewController not ready")
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
