extends Area2D

const SPEED: float = 250.0

var velocity: Vector2 = Vector2.ZERO

# Region within which this object must remain fully enclosed.
var move_rect: Rect2

# For detecting first push.
var pushed: bool = false

# Extents of this object.
@onready var rect: Rect2 = $CollisionShape2D.shape.get_rect()

@onready var collision_shape1: CollisionShape2D = $CollisionShape2D
@onready var collision_shape2: CollisionShape2D = $StaticBody2D/CollisionShape2D


func _ready() -> void:
	make_visible(false)
	
	# Make move_rect slightly smaller than the viewport, to ensure that the
	# the cursor can fit between this object and the edge of the viewport.
	# Choosing a gap of half this object's size seems reasonable.
	var viewport_rect: Rect2 = $%GameArea.get_rect()
	var gap: Vector2 = rect.size / 2.0
	move_rect.position = viewport_rect.position + gap
	move_rect.end = viewport_rect.end - gap

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


# TODO: It may make more sense to do the movement in _on_area_entered(), and get
# rid of _physics_process().
func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		var new_position: Vector2 = position + (velocity * delta)
		var new_rect: Rect2 = Rect2(new_position - rect.size / 2.0, rect.size)
		if move_rect.encloses(new_rect):
			# New position is valid:  perform move.
			position = new_position
			#move_and_collide(new_position)
			if not pushed:
				Globals.achieved_goal.emit(Globals.Goal.PUSHED_BOX)
				pushed = true
		else:
			# New position is not valid: don't move.
			# Also set velocity to zero since it's a waste of time to try this
			# new position again.
			velocity = Vector2.ZERO


func _on_area_entered(area: Area2D) -> void:
	#print_debug("Entered:", area.name)
	# Get angle from area that entered this object.
	var angle: float = (position - area.global_position).angle()
	# Round angle to one of the four cardinal directions (right/down/left/up).
	# The reason is to simplify the movement.
	var angle_quadrant: float = round(angle / (PI/2.0)) * PI/2.0
	# Rotate Vector2.RIGHT (unit vector at zero angle) to computed angle to get
	# direction vector, and multiply by speed to get velocity.
	velocity = SPEED * Vector2.RIGHT.rotated(angle_quadrant)


@warning_ignore("unused_parameter")
func _on_area_exited(area: Area2D) -> void:
	#print_debug("Exited:", area.name)
	velocity = Vector2.ZERO


func make_visible(_visible: bool = true) -> void:
		visible = _visible
		collision_shape1.disabled = not _visible
		collision_shape2.disabled = not _visible
