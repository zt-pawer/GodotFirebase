import Foundation
import SwiftGodotRuntime

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

    private let authService = FirebaseAuthService()
    private let firebaseService = FirebaseService.shared

    @Callable
    func configure() {
        firebaseService.configure()
    }

    @Callable
    func isConfigured() -> Bool {
        return firebaseService.isConfigured()
    }

    @Callable
    func signInAnonymously() {
        authService.signInAnonymously { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.sign_in_success.emit(uid)
                case .failure(let error): self.sign_in_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func signOut() {
        authService.signOut { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.sign_out_failed.emit(error.localizedDescription)
                } else {
                    self.sign_out_success.emit()
                }
            }
        }
    }

    @Callable
    func isUserSignedIn() -> Bool {
        return authService.isUserSignedIn()
    }

    @Callable
    func getCurrentUserUid() -> String {
        return authService.getCurrentUserUid()
    }

    @Callable
    func signInWithCustomToken(customToken: String) {
        authService.signInWithCustomToken(customToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.custom_token_sign_in_success.emit(uid)
                case .failure(let error): self.custom_token_sign_in_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func getIdToken(forceRefresh: Bool) {
        authService.getIdToken(forceRefresh: forceRefresh) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let token): self.id_token_success.emit(token)
                case .failure(let error): self.id_token_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func signInWithGameCenter() {
        authService.signInWithGameCenter { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.sign_in_success.emit(uid)
                case .failure(let error): self.sign_in_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func linkWithGameCenter() {
        authService.linkWithGameCenter { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.link_success.emit(uid)
                case .failure(let error): self.link_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func signInWithApple(idToken: String, rawNonce: String) {
        authService.signInWithApple(idToken: idToken, rawNonce: rawNonce) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.sign_in_success.emit(uid)
                case .failure(let error): self.sign_in_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func linkWithApple(idToken: String, rawNonce: String) {
        authService.linkWithApple(idToken: idToken, rawNonce: rawNonce) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.link_success.emit(uid)
                case .failure(let error): self.link_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func signInWithGoogle(idToken: String, accessToken: String) {
        authService.signInWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.sign_in_success.emit(uid)
                case .failure(let error): self.sign_in_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func linkWithGoogle(idToken: String, accessToken: String) {
        authService.linkWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.link_success.emit(uid)
                case .failure(let error): self.link_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func signInWithFacebook(accessToken: String) {
        authService.signInWithFacebook(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.sign_in_success.emit(uid)
                case .failure(let error): self.sign_in_failed.emit(error.localizedDescription)
                }
            }
        }
    }

    @Callable
    func linkWithFacebook(accessToken: String) {
        authService.linkWithFacebook(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let uid): self.link_success.emit(uid)
                case .failure(let error): self.link_failed.emit(error.localizedDescription)
                }
            }
        }
    }
}
