extends AudioStreamPlayer

func _ready() -> void:
	Globals.volume_changed.connect(func(v: float): volume_db = v)
