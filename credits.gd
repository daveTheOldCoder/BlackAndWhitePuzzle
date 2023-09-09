extends RichTextLabel

const VERSION_SCRIPT_PATH: String = "res://addons/export_version/version.gd"


func _ready() -> void:

	var engine_version_info: String = Engine.get_version_info()['string']
	var export_date_time: String

	if ResourceLoader.exists(VERSION_SCRIPT_PATH):
		var resource: Resource = ResourceLoader.load(VERSION_SCRIPT_PATH)
		if resource != null:
			export_date_time = resource.VERSION
		else:
			export_date_time = "Failed to load resource: %s" % VERSION_SCRIPT_PATH
	else:
		export_date_time = "Resource does not exist: %s" % VERSION_SCRIPT_PATH

	bbcode_enabled = true
	
	# This text does not use clickable URLs, since the UI is simplistic and the
	# the text is displayed on the game screen. Clicking on a URL would be
	# indistinguishable from a game action.
	# However, if the URLs were to made clickable, this text could be used:
	# 	[url=http://godotengine.org/license]Godot Engine[/url]
	# 	[url=http://www.soundimage.org]www.soundimage.org[/url]
	text ="[b]Black and White Puzzle[/b] by DaveTheCoder\n"\
		+ "Version: %s\n" % export_date_time\
		+ "Godot Engine (godotengine.org/license): %s\n" % engine_version_info\
		+ "Music by Eric Matyas  www.soundimage.org"

	#meta_clicked.connect(func(url: String): OS.shell_open(url))
