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

    private let service = FirebaseAuthService()

    @Callable
    func signInAnonymously() {
        service.signInAnonymously { [weak self] result in
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
        service.signOut { [weak self] error in
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
        return service.isUserSignedIn()
    }

    @Callable
    func getCurrentUserUid() -> String {
        return service.getCurrentUserUid()
    }

    @Callable
    func signInWithCustomToken(customToken: String) {
        service.signInWithCustomToken(customToken) { [weak self] result in
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
        service.getIdToken(forceRefresh: forceRefresh) { [weak self] result in
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
        service.signInWithGameCenter { [weak self] result in
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
        service.linkWithGameCenter { [weak self] result in
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
        service.signInWithApple(idToken: idToken, rawNonce: rawNonce) { [weak self] result in
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
        service.linkWithApple(idToken: idToken, rawNonce: rawNonce) { [weak self] result in
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
        service.signInWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
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
        service.linkWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
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
        service.signInWithFacebook(accessToken: accessToken) { [weak self] result in
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
        service.linkWithFacebook(accessToken: accessToken) { [weak self] result in
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
