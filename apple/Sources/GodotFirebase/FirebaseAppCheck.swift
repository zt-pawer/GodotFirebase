@preconcurrency import SwiftGodotRuntime
import Foundation
import FirebaseCore
import FirebaseAppCheck
#if os(iOS)
import DeviceCheck
#endif

@Godot
class GodotFirebaseAppCheck: Object, @unchecked Sendable {
    @Signal var token_success: SignalWithArguments<String>
    @Signal var token_failed: SignalWithArguments<String>

    // Must be called BEFORE GodotFirebaseAuth.configure() so the factory is
    // registered before FirebaseApp.configure() initialises AppCheck.appCheck().
    @Callable
    func configureAppCheck(providerType: String) {
        #if os(iOS)
        let factory: (any AppCheckProviderFactory)?
        switch providerType.lowercased() {
        case "debug":
            factory = AppCheckDebugProviderFactory()
        case "devicecheck":
            factory = DeviceCheckProviderFactory()
        case "appattest":
            #if targetEnvironment(simulator)
            factory = nil
            #else
            factory = AppAttestProviderFactory()
            #endif
        default:
            factory = nil
        }
        if let factory { AppCheck.setAppCheckProviderFactory(factory) }
        #endif
    }

    @Callable
    func getAppCheckToken(forceRefresh: Bool) {
        guard FirebaseApp.app() != nil else {
            token_failed.emit("Firebase not configured — call GodotFirebaseAuth.configure() first")
            return
        }
        AppCheck.appCheck().token(forcingRefresh: forceRefresh) { [weak self] token, error in
            let tokenString = token?.token
            let errorMessage = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let errorMessage { self.token_failed.emit(errorMessage) }
                else if let tokenString { self.token_success.emit(tokenString) }
                else { self.token_failed.emit("Unknown App Check error") }
            }
        }
    }
}
