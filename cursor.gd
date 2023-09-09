extends AnimatedSprite2D


const SPEED: float = 250.0
#const JUMP_position: float = -400.0

# For detecting first move.
var moved: bool = false

# Used to keep cursor in bounds.
@onready var viewport_rect: Rect2 = $%GameArea.get_rect()

# Experiment with using cursor regions as onscreen arrow "keys".
# It works, but is clumsy because clicking the mouse button (or
# tapping the touchscreen) repeatedly is annoying.
@onready var up: Rect2 = $Up.get_rect()
@onready var left: Rect2 = $Left.get_rect()
@onready var down: Rect2 = $Down.get_rect()
@onready var right: Rect2 = $Right.get_rect()


# Handle mouse input (including emulated touch input).
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed\
			and viewport_rect.has_point(event.position):
		# Use tween to gradually move to new position.
		var tween: Tween = create_tween()
		tween.tween_property(self, "position", event.position, 1.0)
		if not moved:
			Globals.achieved_goal.emit(Globals.Goal.MOVED_CURSOR)
			moved = true

	# Experiment with using cursor regions as onscreen arrow "keys".
	#var step: float = 10.0
	#if event is InputEventMouseButton:
		#var local_position: Vector2 = to_local(event.position)
		#var new_position: Vector2 = position
		#if up.has_point(local_position):
			#new_position.y -= step
		#elif left.has_point(local_position):
			#new_position.x -= step
		#elif down.has_point(local_position):
			#new_position.y += step
		#elif right.has_point(local_position):
			#new_position.x += step
		#if new_position != position and viewport_rect.has_point(new_position):
			#position = new_position
			#if not moved:
				#Globals.achieved_goal.emit(Globals.Goal.MOVED_CURSOR)
				#moved = true


# Handle input action.
func _process(delta: float) -> void:
	var new_position: Vector2 = position
	if Input.is_action_pressed("ui_right"):
		new_position.x += SPEED * delta
	if Input.is_action_pressed("ui_left"):
		new_position.x -= SPEED * delta
	if Input.is_action_pressed("ui_down"):
		new_position.y += SPEED * delta
	if Input.is_action_pressed("ui_up"):
		new_position.y -= SPEED * delta
	if new_position != position and viewport_rect.has_point(new_position):
		position = new_position
		if not moved:
			Globals.achieved_goal.emit(Globals.Goal.MOVED_CURSOR)
			moved = true

#func _process(delta: float) -> void:
#
	## Handle Jump.
	#if Input.is_action_just_pressed("ui_accept"):
		##position.y = JUMP_position
		#pass
