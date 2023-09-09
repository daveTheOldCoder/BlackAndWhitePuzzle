extends Node2D

# For detecting first containment.
var pushed_inside: bool = false

# For detecting first removal.
var pushed_outside: bool = false

var box_lid_closed: bool = true

# Extents of this object.
@onready var rect: Rect2 = $ReferenceRect.get_rect()

# Other object.
@onready var other: Node = $%SolidBox
# Extents of other object.
@onready var other_rect: Rect2 = other.find_child("CollisionShape2D").shape.get_rect()

# Lid parent: use for rotation.
# This is a trick for changing the pivot point for rotation/scaling.
@onready var top: Node2D = $Top
# Lid handle.
@onready var handle: Area2D = $Handle

# For enabling/disabling collisions.
@onready var handle_collision_shape: CollisionShape2D = $Handle/CollisionShape2D
@onready var top_collision_shape: CollisionShape2D = $Top/Area2D/CollisionShape2D
@onready var left_collision_shape: CollisionShape2D = $Left/CollisionShape2D
@onready var bottom_collision_shape: CollisionShape2D = $Bottom/CollisionShape2D
@onready var right_collision_shape: CollisionShape2D = $Right/CollisionShape2D


func _ready() -> void:
	make_visible(false)
	
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	timer.start()

	handle.area_entered.connect(_on_area_entered)
	#top_handle.area_exited.connect(_on_area_entered)


func _on_timeout() -> void:
	#print_debug("top.rotation=%.1f" % (top.rotation * 180.0 / PI))
	if not pushed_inside:
		var r: Rect2 = Rect2(to_global(rect.position), rect.size)
		var ro: Rect2 = Rect2(other.to_global(other_rect.position), other_rect.size)
		if r.encloses(ro) and box_lid_closed:
			Globals.achieved_goal.emit(Globals.Goal.PUSHED_BOX_INTO_CONTAINER)
			pushed_inside = true
	elif not pushed_outside:
		var r: Rect2 = Rect2(to_global(rect.position), rect.size)
		var ro: Rect2 = Rect2(other.to_global(other_rect.position), other_rect.size)
		if not r.intersects(ro, true) and box_lid_closed:
			Globals.achieved_goal.emit(Globals.Goal.PUSHED_BOX_OUT_OF_CONTAINER)
			pushed_outside = true


func _on_area_entered(area: Area2D) -> void:
	#print_debug("Entered:", area.get_parent().name)
	if area.get_parent().name != "Cursor":
		return
	# Get angle from area that entered this object.
	#var angle: float = (rect.get_center() - area.global_position).angle()
	#print_debug("angle=%.0f" % (angle * 180.0/PI))
	# Round angle to one of the four cardinal directions (right/down/left/up).
	# The reason is to simplify the movement.
	#var angle_quadrant: float = round(angle / (PI/2.0)) * PI/2.0
	#print_debug("angle_quadrant=%.0f" % (angle_quadrant * 180.0/PI))
	if box_lid_closed:
		# Open lid.
		var tween: Tween = create_tween()
		tween.tween_property(top, "rotation", -3.0 * PI / 4.0, 0.5)
		box_lid_closed = false
	else:
		# Close lid.
		var tween: Tween = create_tween()
		tween.tween_property(top, "rotation", 0.0, 0.5)
		box_lid_closed = true


func make_visible(_visible: bool = true) -> void:
	visible = _visible
	handle_collision_shape.disabled = not _visible
	top_collision_shape.disabled = not _visible
	left_collision_shape.disabled = not _visible
	bottom_collision_shape.disabled = not _visible
	right_collision_shape.disabled = not _visible


#func _on_area_exited(area: Area2D) -> void:
	#print_debug("Exited:", area.get_parent().name)
