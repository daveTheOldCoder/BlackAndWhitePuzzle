extends VSlider


# Minimum and maximum volume (slider value).
const MIN_VOL: float = 0.0
const MAX_VOL: float = 1.0
# Minimum and maximum volume (Decibels).
# CAUTION: A MISTAKE HERE COULD DAMAGE AUDIO COMPONENTS.
const MIN_DB: float = -60.0
const MAX_DB: float = 0.0


func _ready() -> void:
	
	@warning_ignore("assert_always_true")
	assert(MIN_VOL < MAX_VOL)
	@warning_ignore("assert_always_true")
	assert(MIN_DB < MAX_DB)

	# min_value, max_value and step must be set before value.
	min_value = MIN_VOL
	max_value = MAX_VOL
	step = 0.1
	
	value = 0.8 # Determined by testing.
	editable = true
	tick_count = 11
	ticks_on_borders = true
	
	focus_mode = Control.FOCUS_NONE

	value_changed.connect(func(_value: float):\
			Globals.volume_changed.emit(volume_to_db(_value)))

	# Emit signal to initialize volume based on slider value.
	# Use call_deferred() since this is in _ready(), and the nodes that receive
	# the signal may not be ready.
	(func(): value_changed.emit(value)).call_deferred()


# Handle input action.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("increase_volume"):
		value += step
	if Input.is_action_just_pressed("decrease_volume"):
		value -= step


# Convert volume in range [MIN_VOL, MAX_VOL] to decibels in range
# [MIN_DB, MAX_DB].
# CAUTION: A MISTAKE HERE COULD DAMAGE AUDIO COMPONENTS.
func volume_to_db(volume: float) -> float:
	assert(volume >= MIN_VOL and volume <= MAX_VOL)
	var db: float = MIN_DB + volume * (MAX_DB - MIN_DB) / (MAX_VOL - MIN_VOL)
	# assert() is ignored in release-mode, so use clamp() for safety.
	return clamp(db, MIN_DB, MAX_DB)
