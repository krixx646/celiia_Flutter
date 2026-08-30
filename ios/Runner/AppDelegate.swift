import Flutter
import FirebaseCore
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    GeneratedPluginRegistrant.register(with: self)

    let registrar = self.registrar(forPlugin: "CeliaAvatarPlugin")
    if let messenger = registrar?.messenger() {
      registrar?.register(
        CeliaAvatarViewFactory(messenger: messenger),
        withId: "eu.thefit.celia/vrm_avatar_view"
      )
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
