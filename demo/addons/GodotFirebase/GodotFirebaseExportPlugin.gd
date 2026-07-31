@tool
extends EditorPlugin

var export_plugin: AndroidExportPlugin

func _enter_tree() -> void:
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null

class AndroidExportPlugin extends EditorExportPlugin:
	var _plugin_name := "GodotFirebase"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		if debug:
			return PackedStringArray(["GodotFirebase/bin/android/debug/GodotFirebase-debug.aar"])
		return PackedStringArray(["GodotFirebase/bin/android/release/GodotFirebase-release.aar"])

	func _get_name() -> String:
		return _plugin_name
