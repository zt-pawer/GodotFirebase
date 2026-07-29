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
    if level == .scene {
        Engine.registerSingleton(name: StringName("GodotFirebaseAuth"), instance: GodotFirebaseAuth())
        Engine.registerSingleton(name: StringName("GodotFirebaseAppCheck"), instance: GodotFirebaseAppCheck())
    }
}

public func godotFirebaseDeinitialize(level: ExtensionInitializationLevel) {
    if level == .scene {
        for name in ["GodotFirebaseAuth", "GodotFirebaseAppCheck"] {
            if let instance = Engine.getSingleton(name: StringName(name)) {
                Engine.unregisterSingleton(name: StringName(name))
                instance.free()
            }
        }
    }
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
