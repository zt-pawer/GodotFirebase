import Foundation
import SwiftGodotRuntime

private func makeGodotFirebaseTypes() -> [ExtensionInitializationLevel: [Object.Type]] {
    do {
        return try [
            GodotFirebase.self,
            GodotFirebaseAuth.self,
            GodotFirebaseAppCheck.self,
        ].prepareForRegistration()
    } catch {
        fatalError("Failed to prepare Firebase registrations: \(error)")
    }
}

private let godotFirebaseTypes = makeGodotFirebaseTypes()

public let godotFirebaseMinimumInitializationLevel = minimumInitializationLevel(
    for: godotFirebaseTypes
)

public func godotFirebaseInitialize(level: ExtensionInitializationLevel) {
    godotFirebaseTypes[level]?.forEach(register)
}

public func godotFirebaseDeinitialize(level: ExtensionInitializationLevel) {
    godotFirebaseTypes[level]?.reversed().forEach(unregister)
}

@_cdecl("godot_firebase_start")
public func godotFirebaseStart(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
    guard let interface, let library, let `extension` else {
        print("Error: Not all parameters were initialized.")
        return 0
    }
    initializeSwiftModule(
        interface,
        library,
        `extension`,
        initHook: godotFirebaseInitialize,
        deInitHook: godotFirebaseDeinitialize,
        minimumInitializationLevel: godotFirebaseMinimumInitializationLevel
    )
    return 1
}

@Godot
class GodotFirebase: RefCounted {
    static var shared: GodotFirebase?
    private let service = FirebaseService.shared

    @Callable
    func configure() {
        GodotFirebase.shared = self
        service.configure()
    }

    @Callable
    func isConfigured() -> Bool {
        return service.isConfigured()
    }
}
