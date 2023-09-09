extends Area2D

const SPEED: float = 10.0

# Region within which this object must remain fully enclosed.
var move_rect: Rect2

# For detecting first push.
var pushed: bool = false

# Extents of this object.
@onready var rect: Rect2 = $ReferenceRect.get_rect()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# For initial testing, don't hide.
	#hide()
	
	# Make move_rect slightly smaller than the viewport, to ensure that the
	# the cursor can fit between this object and the edge of the viewport.
	# Choosing a gap of half this object's size seems reasonable.
	var viewport_rect: Rect2 = $%GameArea.get_rect()
	var gap: Vector2 = rect.size / 2.0
	move_rect.position = viewport_rect.position + gap
	move_rect.end = viewport_rect.end - gap

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	

func _on_area_entered(area: Area2D) -> void:
	#print_debug("Entered:", area.name)
	# Get angle from area that entered this object.
	var angle: float = (position - area.global_position).angle()
	# Round angle to one of the four cardinal directions (right/down/left/up).
	# The reason is to simplify the movement.
	var angle_quadrant: float = round(angle / (PI/2.0)) * PI/2.0
	# Rotate Vector2.RIGHT (unit vector at zero angle) to computed angle to get
	# direction vector, and multiply by speed to get velocity.
	var new_position: Vector2 = position +\
			(SPEED * Vector2.RIGHT.rotated(angle_quadrant))
	var new_rect: Rect2 = Rect2(new_position - rect.size / 2.0, rect.size)
	if move_rect.encloses(new_rect):
		# New position is valid: perform move.
		position = new_position


@warning_ignore("unused_parameter")
func _on_area_exited(area: Area2D) -> void:
	#print_debug("Exited:", area.name)
	pass


func make_visible(_visible: bool = true) -> void:
		visible = _visible
		collision_shape.disabled = not _visible
