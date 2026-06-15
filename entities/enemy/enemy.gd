extends Node2D
class_name Enemy

var enemy_eyes_closed: bool = false;
signal enemy_eyes_state_changed(enemy_eyes_closed: bool)
@onready var timer: Timer = $Timer
@onready var left: Sprite2D = $Left
@onready var right: Sprite2D = $Right
var rng:= RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_eyes_closed = left.visible
	enemy_eyes_state_changed.emit(enemy_eyes_closed)
	rng.randomize()
	var rand_time := rng.randi_range(3, 10)
	timer.wait_time = rand_time
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	toggle_visible()
	var rand_time := rng.randi_range(3, 10)
	timer.wait_time = rand_time
	timer.start()
	

func toggle_visible() -> void:
	left.visible = not left.visible
	right.visible = not right.visible
	enemy_eyes_closed = left.visible
	enemy_eyes_state_changed.emit(enemy_eyes_closed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	##print(timer.time_left)
	#pass
