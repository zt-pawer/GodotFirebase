import SwiftGodotRuntime

private func makeGodotFirebaseCoreTypes() -> [ExtensionInitializationLevel: [Object.Type]] {
    do {
        return try [
            GodotFirebase.self,
        ].prepareForRegistration()
    } catch {
        fatalError("Failed to prepare GodotFirebaseCore registrations: \(error)")
    }
}

private let godotFirebaseCoreTypes = makeGodotFirebaseCoreTypes()

public let godotFirebaseCoreMinimumInitializationLevel = minimumInitializationLevel(
    for: godotFirebaseCoreTypes
)

public func godotFirebaseCoreInitialize(level: ExtensionInitializationLevel) {
    godotFirebaseCoreTypes[level]?.forEach(register)
}

public func godotFirebaseCoreDeinitialize(level: ExtensionInitializationLevel) {
    godotFirebaseCoreTypes[level]?.reversed().forEach(unregister)
}

@_cdecl("godot_firebase_core_start")
public func godotFirebaseCoreStart(interface: OpaquePointer?, library: OpaquePointer?, extension: OpaquePointer?) -> UInt8 {
    guard let interface, let library, let `extension` else {
        print("Error: Not all parameters were initialized.")
        return 0
    }
    initializeSwiftModule(
        interface, library, `extension`,
        initHook: godotFirebaseCoreInitialize,
        deInitHook: godotFirebaseCoreDeinitialize,
        minimumInitializationLevel: godotFirebaseCoreMinimumInitializationLevel
    )
    return 1
}
