import SwiftGodotRuntime

private func makeGodotFirebaseAppCheckTypes() -> [ExtensionInitializationLevel: [Object.Type]] {
    do {
        return try [
            GodotFirebaseAppCheck.self,
        ].prepareForRegistration()
    } catch {
        fatalError("Failed to prepare GodotFirebaseAppCheck registrations: \(error)")
    }
}

private let godotFirebaseAppCheckTypes = makeGodotFirebaseAppCheckTypes()

public let godotFirebaseAppCheckMinimumInitializationLevel = minimumInitializationLevel(
    for: godotFirebaseAppCheckTypes
)

public func godotFirebaseAppCheckInitialize(level: ExtensionInitializationLevel) {
    godotFirebaseAppCheckTypes[level]?.forEach(register)
}

public func godotFirebaseAppCheckDeinitialize(level: ExtensionInitializationLevel) {
    godotFirebaseAppCheckTypes[level]?.reversed().forEach(unregister)
}

@_cdecl("godot_firebase_app_check_start")
public func godotFirebaseAppCheckStart(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
    guard let interface, let library, let `extension` else {
        print("Error: Not all parameters were initialized.")
        return 0
    }
    initializeSwiftModule(
        interface, library, `extension`,
        initHook: godotFirebaseAppCheckInitialize,
        deInitHook: godotFirebaseAppCheckDeinitialize,
        minimumInitializationLevel: godotFirebaseAppCheckMinimumInitializationLevel
    )
    return 1
}
