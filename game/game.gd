extends Control
class_name Game

var player_eyelids_closed: bool = true
var enemy_eyes_closed: bool = false
var rng:= RandomNumberGenerator.new()
@onready var enemy_ui: EnemyUI = $EnemyUI
@onready var hud: HUD = $HUD
@onready var timer: Timer = $EnemyTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#enemy_eyes_closed = enemy_ui.lefteye.visible #checking if eye is open at start (change this later)!!!
	rng.randomize()
	var rand_time := rng.randi_range(3, 10)
	timer.wait_time = rand_time
	timer.timeout.connect(_on_enemy_timer_timeout)
	timer.start()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Eyelid"):
		close_eye()
	elif event.is_action_released("Eyelid"):
		open_eye()
	_on_player_eyes_state_changed() 

func close_eye() -> void:
	if player_eyelids_closed: return
	player_eyelids_closed = true
	hud.close_eye()

func open_eye() -> void:
	if not player_eyelids_closed: return
	player_eyelids_closed = false
	hud.open_eye()

func _on_enemy_timer_timeout() -> void:
	toggle_enemy_eyes()
	_on_enemy_eyes_state_changed()
	var rand_time := rng.randi_range(3, 10)
	timer.wait_time = rand_time
	timer.start()

func toggle_enemy_eyes() -> void:
	if enemy_eyes_closed:
		enemy_ui.enemy_eyes_open()
		enemy_eyes_closed = false
	else:
		enemy_ui.enemy_eyes_close()
		enemy_eyes_closed = true

# player signal handling
func _on_player_eyes_state_changed() -> void:
	# Rule 1: player closes shut and enemy is staring
	if player_eyelids_closed and not enemy_eyes_closed:
		# increase enemy points
		pass
	# Rule 2: player opens wide and enemy is hiding
	elif not player_eyelids_closed and enemy_eyes_closed:
		# increase player points
		pass
	# Rule 3: player opens wide and enemy is staring
	elif not player_eyelids_closed and not enemy_eyes_closed:
		# close enemy eyes after a second (or animation)
		# SPECIAL CASE if within 1 second of enemy having just opened eyes game over
		# add logic for if enemy eyes were within a second of closing take points
		# if enemy eyes were in the middle of being open then no points added
		pass

# enemy signal handling
func _on_enemy_eyes_state_changed() -> void:
	# Rule 4: enemy opens wide and player is staring
	if not enemy_eyes_closed and not player_eyelids_closed:
		# player has 1 second to close eyes or game over (timer is necessary)
		pass
	# Rule 5: enemy closes shut and player is hiding
	elif enemy_eyes_closed and player_eyelids_closed:
		# deduct points from player
		pass

# --- App Out of Focus ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		#forces eyes open in edge case (could switch to pause menu later)
		Input.action_release("Eyelid")

# Note to future self:
# You need a timer in here to handle the point counter
# You need a second timer for the time bomb clock for the 4th Rule
# Use the time stamps where it is helpful or necessary
# If confused look at time bomb and point counter timer info in gemini

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
