package org.godotengine.plugin.godotfirebase

import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

// Must be called BEFORE GodotFirebaseAuth.configure() so the factory is
// installed before FirebaseApp.initializeApp() initialises App Check,
// mirroring the ordering constraint in FirebaseAppCheck.swift.
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

    @UsedByGodot
    fun configureAppCheck(providerType: String) {
        val factory = when (providerType.lowercase()) {
            "debug" -> DebugAppCheckProviderFactory.getInstance()
            "playintegrity" -> PlayIntegrityAppCheckProviderFactory.getInstance()
            else -> return
        }
        FirebaseAppCheck.getInstance().installAppCheckProviderFactory(factory)
    }

    @UsedByGodot
    fun getAppCheckToken(forceRefresh: Boolean) {
        try {
            FirebaseApp.getInstance()
        } catch (e: IllegalStateException) {
            emitSignal("token_failed", "Firebase not configured — call GodotFirebaseAuth.configure() first")
            return
        }
        FirebaseAppCheck.getInstance().getAppCheckToken(forceRefresh).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                emitSignal("token_success", task.result?.token ?: "")
            } else {
                emitSignal("token_failed", task.exception?.message ?: "Unknown App Check error")
            }
        }
    }
}
