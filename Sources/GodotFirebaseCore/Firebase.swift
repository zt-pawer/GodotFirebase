import Foundation
import SwiftGodotRuntime

@Godot
class GodotFirebase: RefCounted, @unchecked Sendable {
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
