@preconcurrency import SwiftGodotRuntime
import Foundation
import FirebaseCore
import FirebaseAuth

@Godot
class GodotFirebaseAuth: RefCounted, @unchecked Sendable {
    @Signal var sign_in_success: SignalWithArguments<String>
    @Signal var sign_in_failed: SignalWithArguments<String>
    @Signal var sign_out_success: SimpleSignal
    @Signal var sign_out_failed: SignalWithArguments<String>
    @Signal var link_success: SignalWithArguments<String>
    @Signal var link_failed: SignalWithArguments<String>
    @Signal var custom_token_sign_in_success: SignalWithArguments<String>
    @Signal var custom_token_sign_in_failed: SignalWithArguments<String>
    @Signal var id_token_success: SignalWithArguments<String>
    @Signal var id_token_failed: SignalWithArguments<String>

    private var _isConfigured = false

    @Callable
    func configure() {
        guard !_isConfigured else { return }
        let mainBundle = Bundle.main
        let frameworkBundle = Bundle(for: GodotFirebaseAuth.self)
        let plistPath = mainBundle.path(forResource: "GoogleService-Info", ofType: "plist")
                     ?? frameworkBundle.path(forResource: "GoogleService-Info", ofType: "plist")
        if let plistPath, let options = FirebaseOptions(contentsOfFile: plistPath) {
            FirebaseApp.configure(options: options)
        } else {
            FirebaseApp.configure()
        }
        _isConfigured = true
    }

    @Callable
    func isConfigured() -> Bool { return _isConfigured }

    @Callable
    func isUserSignedIn() -> Bool {
        guard FirebaseApp.app() != nil else { return false }
        return Auth.auth().currentUser != nil
    }

    @Callable
    func getCurrentUserUid() -> String {
        guard FirebaseApp.app() != nil else { return "" }
        return Auth.auth().currentUser?.uid ?? ""
    }

    @Callable
    func signInAnonymously() {
        guard FirebaseApp.app() != nil else { sign_in_failed.emit("Firebase not configured"); return }
        Auth.auth().signInAnonymously { [weak self] result, error in
            let uid = result?.user.uid
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.sign_in_failed.emit(msg) }
                else if let uid { self.sign_in_success.emit(uid) }
                else { self.sign_in_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func signOut() {
        guard FirebaseApp.app() != nil else { sign_out_failed.emit("Firebase not configured"); return }
        do {
            try Auth.auth().signOut()
            sign_out_success.emit()
        } catch {
            sign_out_failed.emit(error.localizedDescription)
        }
    }

    @Callable
    func signInWithCustomToken(customToken: String) {
        guard FirebaseApp.app() != nil else { custom_token_sign_in_failed.emit("Firebase not configured"); return }
        Auth.auth().signIn(withCustomToken: customToken) { [weak self] result, error in
            let uid = result?.user.uid
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.custom_token_sign_in_failed.emit(msg) }
                else if let uid { self.custom_token_sign_in_success.emit(uid) }
                else { self.custom_token_sign_in_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func getIdToken(forceRefresh: Bool) {
        guard FirebaseApp.app() != nil else { id_token_failed.emit("Firebase not configured"); return }
        guard let user = Auth.auth().currentUser else { id_token_failed.emit("No user signed in"); return }
        user.getIDTokenForcingRefresh(forceRefresh) { [weak self] token, error in
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.id_token_failed.emit(msg) }
                else if let token { self.id_token_success.emit(token) }
                else { self.id_token_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func signInWithApple(idToken: String, rawNonce: String) {
        guard FirebaseApp.app() != nil else { sign_in_failed.emit("Firebase not configured"); return }
        let credential = OAuthProvider.credential(providerID: .apple, idToken: idToken, rawNonce: rawNonce)
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            let uid = result?.user.uid
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.sign_in_failed.emit(msg) }
                else if let uid { self.sign_in_success.emit(uid) }
                else { self.sign_in_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func linkWithApple(idToken: String, rawNonce: String) {
        guard let currentUser = Auth.auth().currentUser else { link_failed.emit("No user signed in"); return }
        let credential = OAuthProvider.credential(providerID: .apple, idToken: idToken, rawNonce: rawNonce)
        currentUser.link(with: credential) { [weak self] result, error in
            let uid = result?.user.uid
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.link_failed.emit(msg) }
                else if let uid { self.link_success.emit(uid) }
                else { self.link_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func signInWithGoogle(idToken: String, accessToken: String) {
        guard FirebaseApp.app() != nil else { sign_in_failed.emit("Firebase not configured"); return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            let uid = result?.user.uid
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.sign_in_failed.emit(msg) }
                else if let uid { self.sign_in_success.emit(uid) }
                else { self.sign_in_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func linkWithGoogle(idToken: String, accessToken: String) {
        guard let currentUser = Auth.auth().currentUser else { link_failed.emit("No user signed in"); return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        currentUser.link(with: credential) { [weak self] result, error in
            let uid = result?.user.uid
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.link_failed.emit(msg) }
                else if let uid { self.link_success.emit(uid) }
                else { self.link_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func signInWithFacebook(accessToken: String) {
        guard FirebaseApp.app() != nil else { sign_in_failed.emit("Firebase not configured"); return }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            let uid = result?.user.uid
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.sign_in_failed.emit(msg) }
                else if let uid { self.sign_in_success.emit(uid) }
                else { self.sign_in_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func linkWithFacebook(accessToken: String) {
        guard let currentUser = Auth.auth().currentUser else { link_failed.emit("No user signed in"); return }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        currentUser.link(with: credential) { [weak self] result, error in
            let uid = result?.user.uid
            let msg = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let msg { self.link_failed.emit(msg) }
                else if let uid { self.link_success.emit(uid) }
                else { self.link_failed.emit("Unknown error") }
            }
        }
    }

    @Callable
    func signInWithGameCenter() {
        guard FirebaseApp.app() != nil else { sign_in_failed.emit("Firebase not configured"); return }
        GameCenterAuthProvider.getCredential { [weak self] credential, error in
            let credentialMsg = error?.localizedDescription
            guard let credential else {
                let msg = credentialMsg ?? "Failed to retrieve Game Center credential"
                DispatchQueue.main.async { self?.sign_in_failed.emit(msg) }
                return
            }
            Auth.auth().signIn(with: credential) { result, error in
                let uid = result?.user.uid
                let msg = error?.localizedDescription
                DispatchQueue.main.async {
                    guard let self else { return }
                    if let msg { self.sign_in_failed.emit(msg) }
                    else if let uid { self.sign_in_success.emit(uid) }
                    else { self.sign_in_failed.emit("Unknown error") }
                }
            }
        }
    }

    @Callable
    func linkWithGameCenter() {
        guard let currentUser = Auth.auth().currentUser else { link_failed.emit("No user signed in"); return }
        GameCenterAuthProvider.getCredential { [weak self] credential, error in
            let credentialMsg = error?.localizedDescription
            guard let credential else {
                let msg = credentialMsg ?? "Failed to retrieve Game Center credential"
                DispatchQueue.main.async { self?.link_failed.emit(msg) }
                return
            }
            currentUser.link(with: credential) { result, error in
                let uid = result?.user.uid
                let msg = error?.localizedDescription
                DispatchQueue.main.async {
                    guard let self else { return }
                    if let msg { self.link_failed.emit(msg) }
                    else if let uid { self.link_success.emit(uid) }
                    else { self.link_failed.emit("Unknown error") }
                }
            }
        }
    }
}
