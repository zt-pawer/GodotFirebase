package org.godotengine.plugin.godotfirebase

import android.util.Log
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

private const val TAG = "GodotFirebaseAppCheck"

// Walking skeleton: every method below is a stub (log + emit the matching
// `_failed` signal) that proves the Kotlin GodotPlugin is reachable via
// Engine.get_singleton("GodotFirebaseAppCheck") through the full
// native-shim + AAR path. Real Play Integrity/debug provider logic is a
// follow-up PR.
class GodotFirebaseAppCheck(godot: Godot) : GodotPlugin(godot) {

    companion object {
        init {
            System.loadLibrary("GodotFirebase")
        }
    }

    override fun getPluginName() = "GodotFirebaseAppCheck"

    override fun getPluginGDExtensionLibrariesPaths() =
        setOf("res://addons/GodotFirebase/godot_firebase.gdextension")

    override fun getPluginSignals(): MutableSet<SignalInfo> = mutableSetOf(
        SignalInfo("token_success", String::class.java),
        SignalInfo("token_failed", String::class.java),
    )

    private fun stub(method: String) {
        Log.w(TAG, "$method() is a stub on Android — real App Check logic lands in a follow-up PR")
    }

    @UsedByGodot
    fun configureAppCheck(providerType: String) {
        stub("configureAppCheck")
    }

    @UsedByGodot
    fun getAppCheckToken(forceRefresh: Boolean) {
        stub("getAppCheckToken")
        emitSignal("token_failed", "Android App Check not implemented yet")
    }
}
