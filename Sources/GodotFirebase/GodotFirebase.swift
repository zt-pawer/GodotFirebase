import SwiftGodotRuntime

private func makeTypes() -> [ExtensionInitializationLevel: [Object.Type]] {
    do {
        return try [
            GodotFirebaseAuth.self,
            GodotFirebaseAppCheck.self,
        ].prepareForRegistration()
    } catch {
        fatalError("Failed to prepare GodotFirebase registrations: \(error)")
    }
}

private let godotFirebaseTypes = makeTypes()

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
        interface, library, `extension`,
        initHook: godotFirebaseInitialize,
        deInitHook: godotFirebaseDeinitialize,
        minimumInitializationLevel: godotFirebaseMinimumInitializationLevel
    )
    return 1
}
