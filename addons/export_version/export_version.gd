@tool
extends EditorPlugin

# Adapted from:
# 	Auto Export Version 1.0
#	https://godotengine.org/asset-library/asset/1173
#	https://github.com/KoBeWi/Godot-Auto-Export-Version

# The following error message appears during an export. I don't know what it
# means. It doesn't have any apparent effect.
#
# editor/export/editor_export_plugin.h:133 - Required virtual method
# EditorExportPlugin::_get_name must be overridden before calling.


const VERSION_SCRIPT_PATH: String = "res://addons/export_version/version.gd"

var exporter: AEVExporter


func _enter_tree() -> void:
	print_debug("export_plugin.gd/_enter_tree(), version='%s'" % version_string())
	exporter = AEVExporter.new()
	exporter.plugin = self
	add_export_plugin(exporter)


func _exit_tree() -> void:
	print_debug("export_plugin.gd/_exit_tree()")
	remove_export_plugin(exporter)


# Return version as a String.
func version_string() -> String:
	return current_datetime_string()


# Make datetime string "YYYY-MM-DD hh:mm:ss Sxxyy".
# 	YYYY = year, MM = month (01-12), DD = day of month (01-31)
# 	hh = hour (00-23), mm = minute (00-59), ss = second (00-59)
# 	Sxxyy = time zone offset from UTC. S = "+" or "-", xx = hours (00-23),
# 	yy = minutes (00-59)
# Example: "2021-06-20 14:52:13 +0100"

func current_datetime_string() -> String:

	var date_time: Dictionary = Time.get_datetime_dict_from_system()
	var time_zone: Dictionary = Time.get_time_zone_from_system()
	var bias_hours: int = time_zone['bias'] / 60
	var bias_minutes: int = time_zone['bias'] % 60

	return "%4d-%02d-%02d %02d:%02d:%02d %+03d%02d"\
			% [date_time["year"], date_time["month"], date_time['day'],\
			date_time['hour'], date_time['minute'], date_time['second'],\
			bias_hours, bias_minutes]


class AEVExporter extends EditorExportPlugin:

	var plugin: EditorPlugin


	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		print_debug("export_plugin.gd/_export_begin()")
		print_debug("features='%s', is_debug='%s', path='%s', flags='%s'" % [features, is_debug, path, flags])
#		push_error("foobar") # testing push_error()
		store_version(plugin.version_string())


	func _export_end() -> void:
		print_debug("export_plugin.gd/_export_end()")
	

	# Store the version as a String resource in a file.
	# The current date/time is used as the version, but that could be replaced or supplemented by
	# other information.
	func store_version(version: String) -> void:
		var script: GDScript = GDScript.new()
		script.source_code = 'extends RefCounted\nconst VERSION: String = "%s"\n' % version
		if ResourceSaver.save(script, VERSION_SCRIPT_PATH) != OK:
			push_error("Failed to save version file. Make sure the path is valid.")
