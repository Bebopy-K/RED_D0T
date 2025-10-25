extends Node
class_name Stopwatch

var time: float = 0.0
var stopped: bool = false

func _process(delta) -> void:
	if stopped:
		return
	time += delta

func reset() -> void:
	time = 0.0

func stop() -> void:
	stopped = true

func start() -> void:
	stopped = false

func time_to_string() -> String:
	var msec = int(floor(fmod(time, 1) * 1000))
	var sec = int(floor(fmod(time, 60)))
	var min = int(floor(time / 60))
	return "%02d : %02d : %03d" % [min, sec, msec]
