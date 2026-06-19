@preconcurrency import SwiftGodotRuntime
import Foundation
import FirebaseCore
import FirebaseAppCheck
#if os(iOS)
import DeviceCheck
#endif

@Godot
class GodotFirebaseAppCheck: RefCounted, @unchecked Sendable {
    @Signal var token_success: SignalWithArguments<String>
    @Signal var token_failed: SignalWithArguments<String>

    private var _providerType: String = ""

    // Store the provider type. Firebase.configure() (in GodotFirebaseAuth) must be
    // called before getAppCheckToken — the duplicate-symbol warnings are expected
    // (Firebase is statically linked in both frameworks) but harmless here since we
    // bypass AppCheck.appCheck() and instantiate the provider directly.
    @Callable
    func configureAppCheck(providerType: String) {
        _providerType = providerType.lowercased()
    }

    @Callable
    func getAppCheckToken(forceRefresh: Bool) {
        // FirebaseApp.app() uses the ObjC-deduplicated FIRApp class, so it returns
        // the instance configured by GodotFirebaseAuth.configure() regardless of
        // which static copy of Firebase is active in this framework.
        guard let app = FirebaseApp.app() else {
            token_failed.emit("Firebase not configured — call GodotFirebaseAuth.configure() first")
            return
        }
        #if os(iOS)
        let provider: (any AppCheckProvider)?
        switch _providerType {
        case "debug":
            provider = AppCheckDebugProvider(app: app)
        case "devicecheck":
            guard let p = DeviceCheckProvider(app: app) else {
                token_failed.emit("DeviceCheck not available on this device")
                return
            }
            provider = p
        case "appattest":
            #if targetEnvironment(simulator)
            token_failed.emit("AppAttest not available on simulator")
            return
            #else
            provider = AppAttestProvider(app: app)
            #endif
        default:
            token_failed.emit("Unknown App Check provider: \(_providerType)")
            return
        }
        provider?.getToken(forcingRefresh: forceRefresh) { [weak self] token, error in
            let tokenString = token?.token
            let errorMessage = error?.localizedDescription
            DispatchQueue.main.async {
                guard let self else { return }
                if let errorMessage { self.token_failed.emit(errorMessage) }
                else if let tokenString { self.token_success.emit(tokenString) }
                else { self.token_failed.emit("Unknown App Check error") }
            }
        }
        #endif
    }
}
