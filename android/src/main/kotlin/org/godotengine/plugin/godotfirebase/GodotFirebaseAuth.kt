package org.godotengine.plugin.godotfirebase

import android.util.Log
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

private const val TAG = "GodotFirebaseAuth"

// Walking skeleton: every method below is a stub (log + emit the matching
// `_failed` signal, or a safe default for getters) that proves the Kotlin
// GodotPlugin is reachable via Engine.get_singleton("GodotFirebaseAuth")
// through the full native-shim + AAR path. Real Firebase Auth SDK logic is
// a follow-up PR.
class GodotFirebaseAuth(godot: Godot) : GodotPlugin(godot) {

    companion object {
        init {
            System.loadLibrary("GodotFirebase")
        }
    }

    override fun getPluginName() = "GodotFirebaseAuth"

    override fun getPluginGDExtensionLibrariesPaths() =
        setOf("res://addons/GodotFirebase/godot_firebase.gdextension")

    override fun getPluginSignals(): MutableSet<SignalInfo> = mutableSetOf(
        SignalInfo("sign_in_success", String::class.java),
        SignalInfo("sign_in_failed", String::class.java),
        SignalInfo("sign_out_success"),
        SignalInfo("sign_out_failed", String::class.java),
        SignalInfo("link_success", String::class.java),
        SignalInfo("link_failed", String::class.java),
        SignalInfo("custom_token_sign_in_success", String::class.java),
        SignalInfo("custom_token_sign_in_failed", String::class.java),
        SignalInfo("id_token_success", String::class.java),
        SignalInfo("id_token_failed", String::class.java),
    )

    private fun stub(method: String) {
        Log.w(TAG, "$method() is a stub on Android — real auth logic lands in a follow-up PR")
    }

    @UsedByGodot
    fun configure() {
        stub("configure")
    }

    @UsedByGodot
    fun isConfigured(): Boolean {
        stub("isConfigured")
        return false
    }

    @UsedByGodot
    fun isUserSignedIn(): Boolean {
        stub("isUserSignedIn")
        return false
    }

    @UsedByGodot
    fun getCurrentUserUid(): String {
        stub("getCurrentUserUid")
        return ""
    }

    @UsedByGodot
    fun signInAnonymously() {
        stub("signInAnonymously")
        emitSignal("sign_in_failed", "Android auth not implemented yet")
    }

    @UsedByGodot
    fun signOut() {
        stub("signOut")
        emitSignal("sign_out_failed", "Android auth not implemented yet")
    }

    @UsedByGodot
    fun signInWithCustomToken(customToken: String) {
        stub("signInWithCustomToken")
        emitSignal("custom_token_sign_in_failed", "Android auth not implemented yet")
    }

    @UsedByGodot
    fun getIdToken(forceRefresh: Boolean) {
        stub("getIdToken")
        emitSignal("id_token_failed", "Android auth not implemented yet")
    }

    @UsedByGodot
    fun signInWithApple(idToken: String, rawNonce: String) {
        stub("signInWithApple")
        emitSignal("sign_in_failed", "Apple sign-in is not available on Android")
    }

    @UsedByGodot
    fun linkWithApple(idToken: String, rawNonce: String) {
        stub("linkWithApple")
        emitSignal("link_failed", "Apple sign-in is not available on Android")
    }

    @UsedByGodot
    fun signInWithGoogle(idToken: String, accessToken: String) {
        stub("signInWithGoogle")
        emitSignal("sign_in_failed", "Android auth not implemented yet")
    }

    @UsedByGodot
    fun linkWithGoogle(idToken: String, accessToken: String) {
        stub("linkWithGoogle")
        emitSignal("link_failed", "Android auth not implemented yet")
    }

    @UsedByGodot
    fun signInWithFacebook(accessToken: String) {
        stub("signInWithFacebook")
        emitSignal("sign_in_failed", "Android auth not implemented yet")
    }

    @UsedByGodot
    fun linkWithFacebook(accessToken: String) {
        stub("linkWithFacebook")
        emitSignal("link_failed", "Android auth not implemented yet")
    }

    @UsedByGodot
    fun signInWithGameCenter() {
        stub("signInWithGameCenter")
        emitSignal("sign_in_failed", "Game Center sign-in is not available on Android")
    }

    @UsedByGodot
    fun linkWithGameCenter() {
        stub("linkWithGameCenter")
        emitSignal("link_failed", "Game Center sign-in is not available on Android")
    }
}
