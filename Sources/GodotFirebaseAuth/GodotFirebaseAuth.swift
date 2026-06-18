import SwiftGodotRuntime

private func makeGodotFirebaseAuthTypes() -> [ExtensionInitializationLevel: [Object.Type]] {
    do {
        return try [
            GodotFirebaseAuth.self,
        ].prepareForRegistration()
    } catch {
        fatalError("Failed to prepare GodotFirebaseAuth registrations: \(error)")
    }
}

private let godotFirebaseAuthTypes = makeGodotFirebaseAuthTypes()

public let godotFirebaseAuthMinimumInitializationLevel = minimumInitializationLevel(
    for: godotFirebaseAuthTypes
)

public func godotFirebaseAuthInitialize(level: ExtensionInitializationLevel) {
    godotFirebaseAuthTypes[level]?.forEach(register)
}

public func godotFirebaseAuthDeinitialize(level: ExtensionInitializationLevel) {
    godotFirebaseAuthTypes[level]?.reversed().forEach(unregister)
}

@_cdecl("godot_firebase_auth_start")
public func godotFirebaseAuthStart(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
    guard let interface, let library, let `extension` else {
        print("Error: Not all parameters were initialized.")
        return 0
    }
    initializeSwiftModule(
        interface, library, `extension`,
        initHook: godotFirebaseAuthInitialize,
        deInitHook: godotFirebaseAuthDeinitialize,
        minimumInitializationLevel: godotFirebaseAuthMinimumInitializationLevel
    )
    return 1
}
