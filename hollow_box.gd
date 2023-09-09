# This node and script were used in an early version of the game.
# They are not currently used.
extends Area2D

# For detecting first containment.
var pushed_inside: bool = false

# For detecting first removal.
var pushed_outside: bool = false

# Extents of this object.
@onready var rect: Rect2 = $CollisionShape2D.shape.get_rect()

# Other object.
@onready var other: Node = $%SolidBox
# Extents of other object.
@onready var other_rect: Rect2 = other.find_child("CollisionShape2D").shape.get_rect()


#func _ready() -> void:
	#hide()
#
	#var timer: Timer = Timer.new()
	#timer.wait_time = 1.0
	#timer.one_shot = false
	#timer.autostart = false
	#timer.timeout.connect(_on_timeout)
	#add_child(timer)
	#timer.start()


func _on_timeout() -> void:
	if not pushed_inside:
		var r: Rect2 = Rect2(to_global(rect.position), rect.size)
		var ro: Rect2 = Rect2(other.to_global(other_rect.position), other_rect.size)
		if r.encloses(ro):
			Globals.achieved_goal.emit(Globals.Goal.PUSHED_BOX_INTO_CONTAINER)
			pushed_inside = true
	elif not pushed_outside:
		var r: Rect2 = Rect2(to_global(rect.position), rect.size)
		var ro: Rect2 = Rect2(other.to_global(other_rect.position), other_rect.size)
		if not r.intersects(ro, true):
			Globals.achieved_goal.emit(Globals.Goal.PUSHED_BOX_OUT_OF_CONTAINER)
			pushed_outside = true


