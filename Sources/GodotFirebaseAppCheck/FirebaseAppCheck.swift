@preconcurrency import SwiftGodotRuntime
import Foundation
import FirebaseAppCheck
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
        var factory: AppCheckProviderFactory? = nil
        let type = providerType.lowercased()
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
        #endif
    }

    @Callable
    func getAppCheckToken(forceRefresh: Bool) {
        AppCheck.appCheck().token(forcingRefresh: forceRefresh) { [weak self] token, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error { self.token_failed.emit(error.localizedDescription) }
                else if let token { self.token_success.emit(token.token) }
                else { self.token_failed.emit("Unknown App Check error") }
            }
        }
    }
}
