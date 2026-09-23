import Flutter
import UIKit
import GoogleSignIn
import app_links
import FBSDKCoreKit


@main
@objc class AppDelegate: FlutterAppDelegate {

    var eventSink: FlutterEventSink?

    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)

      // Setup FlutterEventChannel for screen recording detection.
      if let controller = window?.rootViewController as? FlutterViewController {
        let screenRecordingChannel = FlutterEventChannel(name: "screen_recording", binaryMessenger: controller.binaryMessenger)
        screenRecordingChannel.setStreamHandler(self)
      }

      if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
        AppLinks.shared.handleLink(url: url)
        return true
      }

      ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
      _ app: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
      if url.scheme == "butterfly" {
        AppLinks.shared.handleLink(url: url)
        return true
      }
      return GIDSignIn.sharedInstance.handle(url)
    }

    // This method is triggered when the screen capture state changes.
    @objc func screenCaptureChanged(notification: Notification) {
      let isCaptured = UIScreen.main.isCaptured
      eventSink?(isCaptured)
      print("Screen recording detected: \(isCaptured)")
    }
}

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    // Observe for screen capture state changes.
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(screenCaptureChanged(notification:)),
                                           name: UIScreen.capturedDidChangeNotification,
                                           object: nil)
    // Send the initial capture state.
    events(UIScreen.main.isCaptured)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    NotificationCenter.default.removeObserver(self,
                                              name: UIScreen.capturedDidChangeNotification,
                                              object: nil)
    return nil
  }
}
