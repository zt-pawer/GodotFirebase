@preconcurrency import SwiftGodotRuntime
import Foundation
import FirebaseAppCheck
import FirebaseCore
#if os(iOS)
import DeviceCheck
#endif

@Godot
class GodotFirebaseAppCheck: RefCounted, @unchecked Sendable {
    @Signal var token_success: SignalWithArguments<String>
    @Signal var token_failed: SignalWithArguments<String>

    @Callable
    func configureAppCheck(providerType: String) {
        #if os(iOS)
        // Firebase is statically linked into this xcframework separately from GodotFirebaseAuth.
        // Must set the provider factory BEFORE configure(), then configure this copy independently.
        let type = providerType.lowercased()
        var factory: AppCheckProviderFactory?
        if type == "debug" {
            factory = AppCheckDebugProviderFactory()
        } else if type == "devicecheck" {
            factory = DeviceCheckProviderFactory()
        } else if type == "appattest" {
            #if !targetEnvironment(simulator)
            if let cls = NSClassFromString("FIRAppAttestProviderFactory") as? NSObject.Type {
                factory = cls.init() as? AppCheckProviderFactory
            }
            #endif
        }
        if let factory { AppCheck.setAppCheckProviderFactory(factory) }

        if FirebaseApp.app() == nil {
            let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
            if let plistPath, let options = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: options)
            } else {
                FirebaseApp.configure()
            }
        }
        #endif
    }

    @Callable
    func getAppCheckToken(forceRefresh: Bool) {
        guard FirebaseApp.app() != nil else {
            token_failed.emit("Firebase not configured — call configureAppCheck() first")
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
