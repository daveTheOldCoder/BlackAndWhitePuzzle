extends Node2D

# A smiley icon will be added to the display after each objective is completed.
# The game is completed when the row of smileys is completed.
#
# 1. Move the cursor.
# 2. Use the cursor to push the solid box.
# 3. Push the solid box into the closeable box.
# 4. Push the solid box out of the closeable box.
# 5. Put three solid shapes into the correct hollow containers.
# 6. Finish an equation that uses numbers, e.g. 2 + 2 = 5.

var num_trophies: int = 0

@onready var trophy1: Sprite2D = $%Trophy1
@onready var trophy2: Sprite2D = $%Trophy2
@onready var trophy3: Sprite2D = $%Trophy3
@onready var trophy4: Sprite2D = $%Trophy4
@onready var trophy5: Sprite2D = $%Trophy5
@onready var trophy6: Sprite2D = $%Trophy6
@onready var game_over_icon: Sprite2D = $%GameOver
@onready var trophy_sound: AudioStreamPlayer2D = $%TrophySound
@onready var replay: Sprite2D = $%Replay

@onready var hollow_triangle: Sprite2D = $GameArea/HollowTriangle
@onready var hollow_square: Sprite2D = $GameArea/HollowSquare
@onready var hollow_pentagon: Sprite2D = $GameArea/HollowPentagon
@onready var solid_triangle: Area2D = $GameArea/SolidTriangle
@onready var solid_square: Area2D = $GameArea/SolidSquare
@onready var solid_pentagon: Area2D = $GameArea/SolidPentagon
@onready var solid_triangle_rect: ReferenceRect = $GameArea/SolidTriangle/ReferenceRect
@onready var solid_square_rect: ReferenceRect = $GameArea/SolidSquare/ReferenceRect
@onready var solid_pentagon_rect: ReferenceRect = $GameArea/SolidPentagon/ReferenceRect
@onready var solid_triangle_cpoly: CollisionShape2D = $GameArea/SolidTriangle/CollisionShape2D
@onready var solid_square_cpoly: CollisionShape2D = $GameArea/SolidSquare/CollisionShape2D
@onready var solid_pentagon_cpoly: CollisionShape2D = $GameArea/SolidPentagon/CollisionShape2D

@onready var moveable_digits: Node2D = $%MoveableDigits
@onready var digit_containers: Node2D = $%DigitContainers
@onready var moveable_digit_solution: Sprite2D = $%MoveableDigits/"5"/Sprite2D
@onready var digit_container_solution: Sprite2D = $%DigitContainers/I

@onready var transition_timer: Timer = Timer.new()
@onready var match_shapes_timer: Timer = Timer.new()
@onready var solve_equation_timer: Timer = Timer.new()

@onready var transition: Sprite2D = $%Transition

@onready var elapsed_time: Label = $%ElapsedTime

@onready var credits: RichTextLabel = $%Credits


func _ready() -> void:
	
	init()
	
	var test: bool = true
	if test:
		pass
		_on_match_shapes_timer_timeout()
		#(func(): Globals.achieved_goal.emit(Globals.Goal.MOVED_CURSOR)).call_deferred()
		#(func(): Globals.achieved_goal.emit(Globals.Goal.PUSHED_BOX)).call_deferred()
		#(func(): Globals.achieved_goal.emit(Globals.Goal.PUSHED_BOX_INTO_CONTAINER)).call_deferred()
		#(func(): Globals.achieved_goal.emit(Globals.Goal.PUSHED_BOX_OUT_OF_CONTAINER)).call_deferred()
		#(func(): Globals.achieved_goal.emit(Globals.Goal.MATCHED_SHAPES)).call_deferred()
		#$%CloseableBox.make_visible(false)


func init() -> void:

	$%Credits.show()
	$%Cursor.show()
	$%VolumeControl.show()
	$%SolidBox.make_visible(false)
	$%CloseableBox.make_visible(false)
	make_digits_visible(false)
	
	trophy1.make_visible(false)
	trophy2.make_visible(false)
	trophy3.make_visible(false)
	trophy4.make_visible(false)
	trophy5.make_visible(false)
	trophy6.make_visible(false)
	game_over_icon.hide()
	replay.hide()
	Globals.achieved_goal.connect(_on_achieved_goal)

	make_shapes_visible(false)
	
	elapsed_time.show()

	# For adding a transition delay after a goal.
	# The wait_time may be overwritten when the timer is started.
	transition_timer.wait_time = 1.0
	transition_timer.one_shot = true
	transition_timer.autostart = false
	add_child(transition_timer)

	# For monitoring for goal achievement.
	match_shapes_timer.wait_time = 1.0
	match_shapes_timer.one_shot = false
	match_shapes_timer.autostart = false
	match_shapes_timer.timeout.connect(_on_match_shapes_timer_timeout)
	add_child(match_shapes_timer)

	# For monitoring for goal achievement.
	solve_equation_timer.wait_time = 1.0
	solve_equation_timer.one_shot = false
	solve_equation_timer.autostart = false
	solve_equation_timer.timeout.connect(_on_solve_equation_timer_timeout)
	add_child(solve_equation_timer)
	
	$%Cursor.position = $%CursorInitial.position
	
	transition.hide()
	
	# Start music.
	$%Music.play()


func _on_achieved_goal(goal: Globals.Goal):
	print_debug("goal=", goal)
	assert(Globals.goal_achieved.has(goal))
	if not Globals.goal_achieved[goal]:
		add_trophy()
		Globals.goal_achieved[goal] = true
		
	match goal:
		Globals.Goal.MOVED_CURSOR:
			# Fade out credits.
			var tween: Tween = create_tween()
			tween.tween_property(credits, "modulate", Color.BLACK, 1.0)
			# Hide credits so that they don't reappear
			# when the background changes.
			tween.tween_property(credits, "visible", false, 1.0)

			# Transition
			await do_transition(2.0)

			# Show objects for next goal.
			$%SolidBox.make_visible()

		Globals.Goal.PUSHED_BOX:
			await do_transition()

			# Show objects for next goal.
			$%CloseableBox.make_visible()

		Globals.Goal.PUSHED_BOX_INTO_CONTAINER:
			await do_transition(1.0)

			# Show objects for next goal.
			# (N/A)

		Globals.Goal.PUSHED_BOX_OUT_OF_CONTAINER:

			# Hide objects for this goal.
			$%CloseableBox.make_visible(false)
			$%SolidBox.make_visible(false)

			await do_transition(1.0)

			# Show objects for next goal.
			$%Cursor.position = $%CursorSolveEquation.position
			make_digits_visible()

			# Start monitoring for next goal.
			solve_equation_timer.start()

		Globals.Goal.SOLVED_EQUATION:
			await do_transition(1.0)

			# Hide objects for this goal.
			make_digits_visible(false)

			# Show objects for next goal.
			$%Cursor.position = $%CursorMatchShapes.position
			make_shapes_visible()

			# Start monitoring for next goal achievement.
			match_shapes_timer.start()

		Globals.Goal.MATCHED_SHAPES:
			await do_transition(1.0)

			# Hide objects for this goal.
			make_shapes_visible(false)

			# End of game.

			# Hide game objects.
			$%Cursor.hide()
			$%VolumeControl.hide()

			# Show end-of-game objects.
			game_over_icon.show()

			# Freeze game clock.
			elapsed_time.stop_timer()

			# Stop music.
			$%Music.stop()

			#replay.show()
			# test
			#replay_game()


func add_trophy() -> void:
	
	trophy_sound.play()

	match num_trophies:
		0:
			trophy1.make_visible()
			num_trophies += 1
		1:
			trophy2.make_visible()
			num_trophies += 1
		2:
			trophy3.make_visible()
			num_trophies += 1
		3:
			trophy4.make_visible()
			num_trophies += 1
		4:
			trophy5.make_visible()
			num_trophies += 1
		5:
			trophy6.make_visible()
			num_trophies += 1


func _on_match_shapes_timer_timeout() -> void:

	var h3: Rect2 = hollow_triangle.get_rect()
	var s3: Rect2 = solid_triangle_rect.get_global_rect()
	var h4: Rect2 = hollow_square.get_rect()
	var s4: Rect2 = solid_square_rect.get_global_rect()
	var h5: Rect2 = hollow_pentagon.get_rect()
	var s5: Rect2 = solid_pentagon_rect.get_global_rect()

	# Convert coordinates from local to global.
	h3 = Rect2(hollow_triangle.to_global(h3.position), h3.size)
	h4 = Rect2(hollow_square.to_global(h4.position), h4.size)
	h5 = Rect2(hollow_pentagon.to_global(h5.position), h5.size)
	
	if (h3.encloses(s4) or h3.encloses(s5))\
			and (h4.encloses(s3) or h4.encloses(s5))\
			and (h5.encloses(s3) or h5.encloses(s4)):
		Globals.achieved_goal.emit(Globals.Goal.MATCHED_SHAPES)
		match_shapes_timer.stop()


func _on_solve_equation_timer_timeout() -> void:

	var c: Rect2 = digit_container_solution.get_rect()
	var m: Rect2 = moveable_digit_solution.get_rect()

	# Convert coordinates from local to global.
	c = Rect2(digit_container_solution.to_global(c.position), c.size)
	m = Rect2(moveable_digit_solution.to_global(m.position), m.size)
	
	#print_debug("c=", c, " c.position", c.position, " c.end=", c.end)
	#print_debug("m=", m, " m.position", m.position, " m.end=", m.end)
	#print_debug("encloses=", c.encloses(m))
	if c.encloses(m):
		Globals.achieved_goal.emit(Globals.Goal.SOLVED_EQUATION)
		solve_equation_timer.stop()


func make_shapes_visible(_visible: bool = true) -> void:

	solid_triangle_cpoly.disabled = not _visible
	solid_square_cpoly.disabled = not _visible
	solid_pentagon_cpoly.disabled = not _visible

	hollow_triangle.visible = _visible
	hollow_square.visible = _visible
	hollow_pentagon.visible = _visible
	solid_triangle.visible = _visible
	solid_square.visible = _visible
	solid_pentagon.visible = _visible

func make_digits_visible(_visible: bool = true) -> void:
	moveable_digits.visible = _visible
	for child in moveable_digits.get_children():
		child.make_visible(_visible)
	digit_containers.visible = _visible
	for child in digit_containers.get_children():
		child.visible = _visible
	

# Perform visual transition between goals.
# Tweens are used to change the alpha channel of a sprite
# from 0 to 1 and then from 1 to 0.
#
# Parameter:
#   delay (seconds) before the transitions
func do_transition(delay: float = 0.0) -> void:
	if delay > 0.0:
		transition_timer.start(delay)
		await transition_timer.timeout

	transition.show()

	var tween: Tween = create_tween()
	tween.tween_property(transition, "modulate:a", 1.0, 0.5)\
			.set_trans(Tween.TRANS_SINE).from(0.0)
	await tween.finished

	tween = create_tween()
	tween.tween_property(transition, "modulate:a", 0.0, 0.5)\
			.set_trans(Tween.TRANS_SINE)
	await tween.finished

	transition.hide()


func replay_game() -> void:
	print_debug("not yet implemented")
	assert(false)
	init()
	Globals.clear_goals()
