import Foundation
import SwiftGodotRuntime

@Godot
class GodotFirebaseAppCheck: RefCounted {
    @Signal var token_success: SignalWithArguments<String>
    @Signal var token_failed: SignalWithArguments<String>

    private let service = FirebaseAppCheckService()

    @Callable
    func configureAppCheck(providerType: String) {
        service.configureAppCheck(providerType: providerType)
    }

    @Callable
    func getAppCheckToken(forceRefresh: Bool) {
        service.getAppCheckToken(forceRefresh: forceRefresh) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let token): self.token_success.emit(token)
                case .failure(let error): self.token_failed.emit(error.localizedDescription)
                }
            }
        }
    }
}
