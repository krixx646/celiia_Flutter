package eu.thefit.celia

import eu.thefit.celia.avatar.CeliaAvatarViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "eu.thefit.celia/vrm_avatar_view",
                CeliaAvatarViewFactory(flutterEngine.dartExecutor.binaryMessenger),
            )
    }
}
