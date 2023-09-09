extends Label

var timer: Timer

# Unix time (seconds)
var start_time: float


func _ready():
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	start_time = Time.get_unix_time_from_system()
	timer.start()


func _on_timeout() -> void:
	# Show elapsed time in hours, minutes and seconds.
	var time: int = floori(Time.get_unix_time_from_system() - start_time)
	var seconds: int = time % 60
	time /= 60
	var minutes: int = time % 60
	time /= 60
	var hours: int = time
	text = "%d:%02d:%02d" % [hours, minutes, seconds]


# For stopping the timer from outside this node.
func stop_timer() -> void:
	timer.stop()
