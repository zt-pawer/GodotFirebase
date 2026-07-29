package org.godotengine.plugin.godotfirebase

import android.content.Context
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.auth.FacebookAuthProvider
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot
import org.json.JSONObject

private const val TAG = "GodotFirebaseAuth"

// google-services.json is read directly at runtime (mirroring how the iOS
// side parses GoogleService-Info.plist directly via FirebaseOptions(contentsOfFile:))
// instead of relying on the com.google.gms.google-services Gradle plugin,
// which only applies to application modules -- this is a library module,
// and Godot's exported Android app project doesn't exist at plugin-build
// time. Place the file at res://android/build/assets/google-services.json
// in the Godot project so Godot's custom build export copies it into the
// exported app's assets/.
private fun readFirebaseOptions(context: Context): FirebaseOptions? {
    val json = try {
        context.assets.open("google-services.json").bufferedReader().use { it.readText() }
    } catch (e: java.io.IOException) {
        Log.w(TAG, "assets/google-services.json not found: ${e.message}")
        return null
    }
    return try {
        val root = JSONObject(json)
        val projectInfo = root.getJSONObject("project_info")
        val clients = root.getJSONArray("client")
        var client = clients.getJSONObject(0)
        for (i in 0 until clients.length()) {
            val candidate = clients.getJSONObject(i)
            val packageName = candidate.getJSONObject("client_info")
                .getJSONObject("android_client_info")
                .optString("package_name")
            if (packageName == context.packageName) {
                client = candidate
                break
            }
        }
        val apiKey = client.getJSONArray("api_key").getJSONObject(0).getString("current_key")
        val builder = FirebaseOptions.Builder()
            .setProjectId(projectInfo.getString("project_id"))
            .setApplicationId(client.getJSONObject("client_info").getString("mobilesdk_app_id"))
            .setApiKey(apiKey)
            .setGcmSenderId(projectInfo.getString("project_number"))
        val storageBucket = projectInfo.optString("storage_bucket", "")
        if (storageBucket.isNotEmpty()) builder.setStorageBucket(storageBucket)
        builder.build()
    } catch (e: Exception) {
        Log.w(TAG, "Failed to parse google-services.json: ${e.message}")
        null
    }
}

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

    private var _isConfigured = false

    private fun isFirebaseConfigured(): Boolean = try {
        FirebaseApp.getInstance()
        true
    } catch (e: IllegalStateException) {
        false
    }

    @UsedByGodot
    fun configure() {
        if (_isConfigured) return
        val context = getActivity()?.applicationContext ?: return
        val options = readFirebaseOptions(context)
        if (options != null) {
            FirebaseApp.initializeApp(context, options)
        } else {
            FirebaseApp.initializeApp(context)
        }
        _isConfigured = true
    }

    @UsedByGodot
    fun isConfigured(): Boolean = _isConfigured

    @UsedByGodot
    fun isUserSignedIn(): Boolean {
        if (!isFirebaseConfigured()) return false
        return FirebaseAuth.getInstance().currentUser != null
    }

    @UsedByGodot
    fun getCurrentUserUid(): String {
        if (!isFirebaseConfigured()) return ""
        return FirebaseAuth.getInstance().currentUser?.uid ?: ""
    }

    @UsedByGodot
    fun signInAnonymously() {
        if (!isFirebaseConfigured()) {
            emitSignal("sign_in_failed", "Firebase not configured")
            return
        }
        FirebaseAuth.getInstance().signInAnonymously().addOnCompleteListener { task ->
            if (task.isSuccessful) {
                emitSignal("sign_in_success", task.result?.user?.uid ?: "")
            } else {
                emitSignal("sign_in_failed", task.exception?.message ?: "Unknown error")
            }
        }
    }

    @UsedByGodot
    fun signOut() {
        if (!isFirebaseConfigured()) {
            emitSignal("sign_out_failed", "Firebase not configured")
            return
        }
        FirebaseAuth.getInstance().signOut()
        emitSignal("sign_out_success")
    }

    @UsedByGodot
    fun signInWithCustomToken(customToken: String) {
        if (!isFirebaseConfigured()) {
            emitSignal("custom_token_sign_in_failed", "Firebase not configured")
            return
        }
        FirebaseAuth.getInstance().signInWithCustomToken(customToken).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                emitSignal("custom_token_sign_in_success", task.result?.user?.uid ?: "")
            } else {
                emitSignal("custom_token_sign_in_failed", task.exception?.message ?: "Unknown error")
            }
        }
    }

    @UsedByGodot
    fun getIdToken(forceRefresh: Boolean) {
        if (!isFirebaseConfigured()) {
            emitSignal("id_token_failed", "Firebase not configured")
            return
        }
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            emitSignal("id_token_failed", "No user signed in")
            return
        }
        user.getIdToken(forceRefresh).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                emitSignal("id_token_success", task.result?.token ?: "")
            } else {
                emitSignal("id_token_failed", task.exception?.message ?: "Unknown error")
            }
        }
    }

    @UsedByGodot
    fun signInWithApple(idToken: String, rawNonce: String) {
        emitSignal("sign_in_failed", "Apple sign-in is not available on Android")
    }

    @UsedByGodot
    fun linkWithApple(idToken: String, rawNonce: String) {
        emitSignal("link_failed", "Apple sign-in is not available on Android")
    }

    @UsedByGodot
    fun signInWithGoogle(idToken: String, accessToken: String) {
        if (!isFirebaseConfigured()) {
            emitSignal("sign_in_failed", "Firebase not configured")
            return
        }
        val credential = GoogleAuthProvider.getCredential(idToken, accessToken)
        FirebaseAuth.getInstance().signInWithCredential(credential).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                emitSignal("sign_in_success", task.result?.user?.uid ?: "")
            } else {
                emitSignal("sign_in_failed", task.exception?.message ?: "Unknown error")
            }
        }
    }

    @UsedByGodot
    fun linkWithGoogle(idToken: String, accessToken: String) {
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            emitSignal("link_failed", "No user signed in")
            return
        }
        val credential = GoogleAuthProvider.getCredential(idToken, accessToken)
        user.linkWithCredential(credential).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                emitSignal("link_success", task.result?.user?.uid ?: "")
            } else {
                emitSignal("link_failed", task.exception?.message ?: "Unknown error")
            }
        }
    }

    @UsedByGodot
    fun signInWithFacebook(accessToken: String) {
        if (!isFirebaseConfigured()) {
            emitSignal("sign_in_failed", "Firebase not configured")
            return
        }
        val credential = FacebookAuthProvider.getCredential(accessToken)
        FirebaseAuth.getInstance().signInWithCredential(credential).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                emitSignal("sign_in_success", task.result?.user?.uid ?: "")
            } else {
                emitSignal("sign_in_failed", task.exception?.message ?: "Unknown error")
            }
        }
    }

    @UsedByGodot
    fun linkWithFacebook(accessToken: String) {
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            emitSignal("link_failed", "No user signed in")
            return
        }
        val credential = FacebookAuthProvider.getCredential(accessToken)
        user.linkWithCredential(credential).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                emitSignal("link_success", task.result?.user?.uid ?: "")
            } else {
                emitSignal("link_failed", task.exception?.message ?: "Unknown error")
            }
        }
    }

    @UsedByGodot
    fun signInWithGameCenter() {
        emitSignal("sign_in_failed", "Game Center sign-in is not available on Android")
    }

    @UsedByGodot
    fun linkWithGameCenter() {
        emitSignal("link_failed", "Game Center sign-in is not available on Android")
    }
}
