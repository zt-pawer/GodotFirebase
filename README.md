# GodotFirebase

[![Godot](https://img.shields.io/badge/Godot%20Engine-4.2+-blue.svg)](https://github.com/godotengine/godot/)
[![SwiftGodot](https://img.shields.io/badge/SwiftGodot-pinned-blue.svg)](https://github.com/migueldeicaza/SwiftGodot/)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-333333.svg?style=flat)
![iOS](https://img.shields.io/badge/iOS-17+-green.svg?style=flat)
![macOS](https://img.shields.io/badge/macOS-14+-green.svg?style=flat)
[![Swift](https://img.shields.io/badge/Swift-6-blue.svg)](https://www.swift.org/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

Native Firebase plugin for Godot 4 on iOS and macOS, built with Swift and [SwiftGodotRuntime](https://github.com/migueldeicaza/SwiftGodot). Provides Firebase Auth and Firebase App Check as standalone GDExtension classes with no service layer — signals go directly to your GDScript.

---

## Requirements

- iOS 17.0 / macOS 14.0
- Godot 4.2+
- [GodotApplePlugins](https://github.com/zt-pawer/GodotApplePlugins) installed — provides the shared `SwiftGodotRuntime` the plugin links against

The plugin also ships empty stubs for Linux and Windows so your project compiles on those platforms without errors.

---

## Installation

1. Download the latest release zip from [Releases](https://github.com/zt-pawer/GodotFirebase/releases)
2. Unzip and copy `addons/GodotFirebaseAuth/` and `addons/GodotFirebaseAppCheck/` into your Godot project's `addons/`
3. Ensure `addons/GodotApplePluginsRuntime/` is also present (from [GodotApplePlugins](https://github.com/zt-pawer/GodotApplePlugins))
4. Add `GoogleService-Info.plist` to your iOS export resources in the Godot export settings

---

## API

Both classes are registered as Engine singletons — guard access with `Engine.has_singleton("ClassName")`; they only exist on iOS/macOS. On other platforms the guard simply skips access.

---

### `GodotFirebaseAuth`

Firebase Authentication — anonymous sign-in, custom token, social provider sign-in and linking, ID token retrieval.

#### Quick start

```gdscript
extends Node

var _auth: Object

func _ready() -> void:
    if not Engine.has_singleton("GodotFirebaseAuth"):
        return
    _auth = Engine.get_singleton("GodotFirebaseAuth")
    _auth.sign_in_success.connect(_on_sign_in_success)
    _auth.sign_in_failed.connect(_on_sign_in_failed)
    _auth.configure()
    _auth.signInAnonymously()

func _on_sign_in_success(uid: String) -> void:
    print("Signed in: ", uid)

func _on_sign_in_failed(error: String) -> void:
    print("Sign in failed: ", error)
```

#### Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `sign_in_success` | `uid: String` | Any sign-in succeeded |
| `sign_in_failed` | `error: String` | Any sign-in failed |
| `sign_out_success` | — | Sign-out succeeded |
| `sign_out_failed` | `error: String` | Sign-out failed |
| `link_success` | `uid: String` | Provider linked successfully |
| `link_failed` | `error: String` | Link failed — inspect for `"already-linked"` or `"credential-already-in-use"` |
| `custom_token_sign_in_success` | `uid: String` | Custom token sign-in succeeded |
| `custom_token_sign_in_failed` | `error: String` | Custom token sign-in failed |
| `id_token_success` | `token: String` | Firebase ID token retrieved |
| `id_token_failed` | `error: String` | ID token retrieval failed |

#### Methods

| Method | Description |
|--------|-------------|
| `configure()` | Initialise Firebase from `GoogleService-Info.plist`. Call once before any other method |
| `isConfigured() -> bool` | Returns `true` if already configured |
| `isUserSignedIn() -> bool` | Whether a Firebase user is currently signed in |
| `getCurrentUserUid() -> String` | UID of the current user, or `""` if not signed in |
| `signInAnonymously()` | Sign in as an anonymous user |
| `signOut()` | Sign out the current user |
| `signInWithCustomToken(customToken: String)` | Sign in with a backend-issued custom token |
| `getIdToken(forceRefresh: Bool)` | Retrieve the Firebase ID token for the current user |
| `signInWithApple(idToken: String, rawNonce: String)` | Sign in with Apple credential |
| `linkWithApple(idToken: String, rawNonce: String)` | Link Apple to the current Firebase user |
| `signInWithGoogle(idToken: String, accessToken: String)` | Sign in with Google credential |
| `linkWithGoogle(idToken: String, accessToken: String)` | Link Google to the current Firebase user |
| `signInWithFacebook(accessToken: String)` | Sign in with Facebook credential |
| `linkWithFacebook(accessToken: String)` | Link Facebook to the current Firebase user |
| `signInWithGameCenter()` | Sign in with Game Center credential |
| `linkWithGameCenter()` | Link Game Center to the current Firebase user |

---

### `GodotFirebaseAppCheck`

Firebase App Check — device integrity attestation to protect your backend from abuse.

#### Quick start

```gdscript
extends Node

var _app_check: Object

func _ready() -> void:
    if not Engine.has_singleton("GodotFirebaseAppCheck"):
        return
    _app_check = Engine.get_singleton("GodotFirebaseAppCheck")
    _app_check.token_success.connect(_on_token_success)
    _app_check.token_failed.connect(_on_token_failed)
    # Configure before GodotFirebaseAuth.configure()
    _app_check.configureAppCheck("appattest")  # or "devicecheck" / "debug"
    _app_check.getAppCheckToken(false)

func _on_token_success(token: String) -> void:
    print("App Check token: ", token)

func _on_token_failed(error: String) -> void:
    print("App Check failed: ", error)
```

#### Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `token_success` | `token: String` | App Check token retrieved |
| `token_failed` | `error: String` | Token retrieval failed |

#### Methods

| Method | Description |
|--------|-------------|
| `configureAppCheck(providerType: String)` | Configure the attestation provider. Call before `GodotFirebaseAuth.configure()`. Values: `"appattest"` (real device only), `"devicecheck"`, `"debug"` (simulator/testing) |
| `getAppCheckToken(forceRefresh: Bool)` | Request the current App Check token |

---

## Building from Source

Requires Xcode on macOS. Before building, open the package in Xcode and share the scheme (**Product → Manage Schemes → Shared**) so `xcodebuild` can find it.

```bash
make build
make dist
```

`make build` compiles xcframeworks for iOS, iOS Simulator, and macOS. `make dist` assembles the `addons/` folder ready to drop into your Godot project.

---

## SwiftGodot Version

This plugin is pinned to SwiftGodot revision `f528ba67accbe3cca06c1d401c8f9d7c17022f63` — the same revision used by [GodotApplePlugins](https://github.com/zt-pawer/GodotApplePlugins). Both must stay in sync to share `SwiftGodotRuntime.xcframework` without ABI skew.

---

## Contributing

Have a bug fix or feature request? Contributions are welcome!

[How to contribute](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project)

---

## Donate and support

[![Buy me a coffee](.github/bmc-button.png)](https://buymeacoffee.com/ztpawer)

[![Become a patreon](.github/patreon-button.png)](https://patreon.com/ztpawer)

---

## Games using it

[![Pang in Time](.github/pit.webp)](https://apps.apple.com/us/app/pang-in-time/id6499503406)

[![Jupiter Escape](.github/je.webp)](https://apps.apple.com/us/app/jupiter-escape/id6476010007)

---

## License

MIT — see [LICENSE](LICENSE)
