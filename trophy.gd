extends Sprite2D

func make_visible(_visible: bool = true) -> void:
	visible = _visible
	if _visible:
		var tween: Tween = create_tween()
		tween.tween_property(self, "rotation", 4.0 * PI, 1.0)
