package app.cineprimeott.app

import android.os.Bundle
import android.view.WindowManager.LayoutParams
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        allowScreenshots()
    }

    override fun onResume() {
        super.onResume()
        allowScreenshots()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        allowScreenshots()
    }

    private fun allowScreenshots() {
        window.clearFlags(LayoutParams.FLAG_SECURE)
    }
}
