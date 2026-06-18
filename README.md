# GodotFirebase

Native Firebase plugin for Godot 4 on iOS and macOS, built with Swift and [SwiftGodotRuntime](https://github.com/migueldeicaza/SwiftGodot).

Download a ready-to-use build from the [GitHub Releases](https://github.com/zt-pawer/GodotFirebase/releases) tab. Drag the `addons/GodotFirebase/` folder into your project's `addons/` directory, alongside [GodotApplePlugins](https://github.com/migueldeicaza/GodotApplePlugins) (required as the shared runtime).

---

## Requirements

- iOS 17.0 / macOS 14.0
- Godot 4.2+
- [GodotApplePlugins](https://github.com/migueldeicaza/GodotApplePlugins) installed — provides the shared `SwiftGodotRuntime` the plugin links against

The plugin also ships empty stubs for Linux and Windows so your project compiles without errors on those platforms.

---

## Installation

1. Download the latest release zip from [Releases](https://github.com/zt-pawer/GodotFirebase/releases)
2. Unzip and copy `addons/GodotFirebase/` into your Godot project's `addons/`
3. Ensure `addons/GodotApplePluginsRuntime/` is also present (from GodotApplePlugins)
4. Add `GoogleService-Info.plist` to your iOS export resources

---

## API

All classes are guarded with `ClassDB.class_exists("ClassName")` — they only exist on iOS/macOS. On other platforms the guard simply skips instantiation.

### `GodotFirebase`

Configures the Firebase app. Call `configure()` once before any other Firebase API.

```gdscript
if ClassDB.class_exists("GodotFirebase"):
    var firebase = ClassDB.instantiate("GodotFirebase")
    firebase.configure()
```

| Method | Description |
|--------|-------------|
| `configure()` | Initialises Firebase from `GoogleService-Info.plist` |
| `isConfigured() -> bool` | Returns true if already configured |

---

### `GodotFirebaseAuth`

Firebase Authentication — anonymous, custom token, provider linking and ID token retrieval.

```gdscript
if ClassDB.class_exists("GodotFirebaseAuth"):
    var auth = ClassDB.instantiate("GodotFirebaseAuth")
    auth.custom_token_sign_in_success.connect(_on_token_success)
    auth.signInWithCustomToken(my_token)
```

**Signals**

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `sign_in_success` | `uid: String` | Any sign-in succeeded |
| `sign_in_failed` | `error: String` | Any sign-in failed |
| `sign_out_success` | — | Sign-out succeeded |
| `sign_out_failed` | `error: String` | Sign-out failed |
| `link_success` | `uid: String` | Provider linked |
| `link_failed` | `error: String` | Link failed (check for `"already-linked"` / `"credential-already-in-use"`) |
| `custom_token_sign_in_success` | `uid: String` | Custom token sign-in succeeded |
| `custom_token_sign_in_failed` | `error: String` | Custom token sign-in failed |
| `id_token_success` | `token: String` | ID token retrieved |
| `id_token_failed` | `error: String` | ID token retrieval failed |

**Methods**

| Method | Description |
|--------|-------------|
| `signInAnonymously()` | Sign in as anonymous user |
| `signOut()` | Sign out current user |
| `isUserSignedIn() -> bool` | Whether a user is currently signed in |
| `getCurrentUserUid() -> String` | UID of current user or `""` |
| `signInWithCustomToken(customToken: String)` | Sign in with backend-issued custom token |
| `getIdToken(forceRefresh: Bool)` | Get Firebase ID token for the current user |
| `signInWithGameCenter()` | Sign in using Game Center credential |
| `linkWithGameCenter()` | Link Game Center to current Firebase user |
| `signInWithApple(idToken: String, rawNonce: String)` | Sign in with Apple |
| `linkWithApple(idToken: String, rawNonce: String)` | Link Apple to current Firebase user |
| `signInWithGoogle(idToken: String, accessToken: String)` | Sign in with Google |
| `linkWithGoogle(idToken: String, accessToken: String)` | Link Google |
| `signInWithFacebook(accessToken: String)` | Sign in with Facebook |
| `linkWithFacebook(accessToken: String)` | Link Facebook |

---

### `GodotFirebaseAppCheck`

Firebase App Check — device integrity attestation.

```gdscript
if ClassDB.class_exists("GodotFirebaseAppCheck"):
    var app_check = ClassDB.instantiate("GodotFirebaseAppCheck")
    app_check.token_success.connect(_on_token)
    app_check.configureAppCheck("appattest")
    app_check.getAppCheckToken(false)
```

**Signals**

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `token_success` | `token: String` | Token retrieved |
| `token_failed` | `error: String` | Token retrieval failed |

**Methods**

| Method | Description |
|--------|-------------|
| `configureAppCheck(providerType: String)` | Configure before `GodotFirebase.configure()`. Values: `"debug"`, `"devicecheck"`, `"appattest"` |
| `getAppCheckToken(forceRefresh: Bool)` | Request current App Check token |

---

## Building from Source

The plugin requires a macOS machine with Xcode to build the Swift xcframework. The CI workflow (`build-and-release.yml`) does this automatically on push using a self-hosted macOS runner.

### CI (recommended)

1. Set up a self-hosted macOS Actions runner on your machine (same runner as used by GodotApplePlugins)
2. Add these secrets to the repo if you want code-signed + notarised releases:
   - `MACOS_CERTIFICATE`, `MACOS_CERTIFICATE_PASSWORD`, `KEYCHAIN_PASSWORD`
   - `APPLE_ID`, `APPLE_ID_PASSWORD`, `APPLE_TEAM_ID`
3. Push to `main` — the workflow builds iOS/macOS xcframework + Linux/Windows stubs, then publishes a release zip

### Local build

```bash
# 1. Resolve packages
swift build

# 2. Build for each destination (Release config)
DERIVED=".xcodebuild"
WORKSPACE=".swiftpm/xcode/package.xcworkspace"
SCHEME="GodotFirebase"

xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Release \
  -destination "generic/platform=iOS" -derivedDataPath "$DERIVED" build

xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Release \
  -destination "generic/platform=iOS Simulator" -derivedDataPath "${DERIVED}simulator" build

xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Release \
  -destination "platform=macOS,arch=arm64" -derivedDataPath "${DERIVED}arm64" build

# x86_64 — run via Rosetta on Apple Silicon:
arch -x86_64 xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Release \
  -destination "platform=macOS,arch=x86_64" -derivedDataPath "${DERIVED}x86_64" build

# 3. Assemble xcframework
mkdir -p addons/GodotFirebase/bin
xcodebuild -create-xcframework \
  -framework "$DERIVED/Build/Products/Release-iphoneos/PackageFrameworks/GodotFirebase.framework" \
  -framework "${DERIVED}simulator/Build/Products/Release-iphonesimulator/PackageFrameworks/GodotFirebase.framework" \
  -output addons/GodotFirebase/bin/GodotFirebase.xcframework

# Copy macOS frameworks
rsync -a "${DERIVED}arm64/Build/Products/Release/PackageFrameworks/GodotFirebase.framework/" \
  addons/GodotFirebase/bin/GodotFirebase.framework

rsync -a "${DERIVED}x86_64/Build/Products/Release/PackageFrameworks/GodotFirebase.framework/" \
  addons/GodotFirebase/bin/GodotFirebase_x64.framework
```

After building, copy `addons/GodotFirebase/` into your Godot project and remove the old `firebase.gdextension`/`libGodotFirebase.dylib` if migrating from SwiftGodotIosPlugins.

---

## SwiftGodot Version

This plugin is pinned to SwiftGodot revision `f528ba67accbe3cca06c1d401c8f9d7c17022f63` — the same revision as [GodotApplePlugins](https://github.com/migueldeicaza/GodotApplePlugins). Both must stay in sync to share the `SwiftGodotRuntime.xcframework` without ABI skew.

---

## License

MIT — see [LICENSE](LICENSE)
