extends Control
class_name Game

# =============================================================================
# enums
# =============================================================================
enum GameState {ENEMY_STARING, PLAYER_STARING, ENEMY_ATTACK, PLAYER_ATTACK, ENEMY_SCORES, CLOSED}

# =============================================================================
# public variables 
# =============================================================================
var player_score: int
var enemy_score: int
var current_state: GameState = GameState.CLOSED
var previous_state: GameState = GameState.CLOSED
var player_eyelids_closed: bool = false
var enemy_eyes_closed: bool = true
var enemy_is_blinking: bool = false
var rng:= RandomNumberGenerator.new()

# =============================================================================
# onready variables
# =============================================================================
@onready var enemy_ui: EnemyUI = $EnemyUI
@onready var hud: HUD = $HUD
@onready var enemy_timer: Timer = $EnemyTimer
@onready var enemy_piercing_timer: Timer = $EnemyPiercingTimer
@onready var player_point_timer: Timer = $PlayerPointTimer
@onready var enemy_point_timer: Timer = $EnemyPointTimer
@onready var player_grace_period_timer: Timer = $PlayerGracePeriodTimer
@onready var enemy_grace_period_timer: Timer = $EnemyGracePeriodTimer

# =============================================================================
# built-in virtual methods
# =============================================================================
#region built-in methods

#region _ready
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_window().grab_focus() #TRY THIS FIRST FOR MOUSE FIRST CLICK NOT CAPTURED!!!!!!
	#DisplayServer.window_request_attention() ## TRY THIS!!!!!!!!
	#DisplayServer.window_move_to_foreground() ### TRY THIS 2!!!!!!!!
	
	_initialize_ui()
	
	_initialize_enemy_timer()
	enemy_piercing_timer.timeout.connect(_on_enemy_piercing_timer_timeout)
	player_point_timer.timeout.connect(_on_player_score_tick)
	enemy_point_timer.timeout.connect(_on_enemy_score_tick)
	player_grace_period_timer.timeout.connect(_on_player_grace_period_timeout)
	enemy_grace_period_timer.timeout.connect(_on_enemy_grace_period_timeout)
	
	_initialize_game_state()

# helper funcitons of _ready
func _initialize_ui() -> void:
	# this will change when eyes are controled together with animations!!!!!!!!!!!!!!!
	hud.left_eyelid.visible = player_eyelids_closed # set player eye to bool handler
	hud.right_eyelid.visible = player_eyelids_closed # set player eye to bool handler
	enemy_ui.left_eye.visible = not enemy_eyes_closed # set enemy eye to bool handler
	enemy_ui.right_eye.visible = not enemy_eyes_closed # set enemy eye to bool handler

func _initialize_enemy_timer() -> void:
	rng.randomize()
	var rand_time := rng.randi_range(3, 10)
	enemy_timer.wait_time = rand_time
	enemy_timer.timeout.connect(_on_enemy_timer_timeout)
	enemy_timer.start()

func _initialize_game_state() -> void:
	var starting_state: GameState
	if player_eyelids_closed and enemy_eyes_closed:
		starting_state = GameState.CLOSED
	elif not player_eyelids_closed and enemy_eyes_closed:
		starting_state = GameState.PLAYER_STARING
	elif player_eyelids_closed and not enemy_eyes_closed:
		starting_state = GameState.ENEMY_STARING
	elif not player_eyelids_closed and not enemy_eyes_closed:
		starting_state = GameState.ENEMY_ATTACK
	_change_game_state(starting_state)

#endregion _ready

#region player input
# input method to open or close player eyes
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Eyelid"):
		_close_player_eyes()
	elif event.is_action_released("Eyelid"):
		_open_player_eyes()

# helper methods of _unhandled_input
func _close_player_eyes() -> void:
	if player_eyelids_closed: return
	player_eyelids_closed = true
	hud.close_eye()
	_evaluate_player_eyes_state()

func _open_player_eyes() -> void:
	if not player_eyelids_closed: return
	
	if not enemy_piercing_timer.is_stopped():
		_game_over()
		return
	
	player_eyelids_closed = false
	hud.open_eye()
	_evaluate_player_eyes_state()

#endregion player input

# --- App Out of Focus ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		#forces eyes open in edge case (could switch to pause menu later)
		Input.action_release("Eyelid")
#endregion built-in methods

# =============================================================================
# helper methods
# =============================================================================
#region helper methods
# toggles enemy eyes and resets enemy_timer with rand cooldown
func _on_enemy_timer_timeout() -> void:
	if current_state != GameState.ENEMY_STARING:
		enemy_is_blinking = false
		_toggle_enemy_eye_state()
		return
	
	if not enemy_is_blinking:
		# timer just ended and enemy is staring so start 1 second blink
		enemy_is_blinking = true
		print("enemy_is_blinking: ", enemy_is_blinking)
		# play animation
		enemy_timer.start(1)
	else:
		# 1 second blink ended toggle enemy eye state
		enemy_is_blinking = false
		_toggle_enemy_eye_state()

func _toggle_enemy_eye_state() -> void:
	print("enemy_is_blinking: ", enemy_is_blinking)
	_toggle_enemy_eyes()
	_evaluate_enemy_eyes_state()
	var rand_time := rng.randi_range(3, 10)
	enemy_timer.wait_time = rand_time
	enemy_timer.start()

func _toggle_enemy_eyes() -> void:
	if enemy_eyes_closed:
		enemy_ui.enemy_eyes_open()
		enemy_eyes_closed = false
	else:
		enemy_ui.enemy_eyes_close()
		enemy_eyes_closed = true

#region game state logic
# player activated game state handling
func _evaluate_player_eyes_state() -> void:
	var new_state: GameState
	# Rule 1: player closes shut and enemy is staring
	if player_eyelids_closed and not enemy_eyes_closed:
		new_state = GameState.ENEMY_STARING
	# Rule 2: player opens wide and enemy is hiding
	elif not player_eyelids_closed and enemy_eyes_closed:
		new_state = GameState.PLAYER_STARING
	# Rule 3: player opens wide and enemy is staring
	elif not player_eyelids_closed and not enemy_eyes_closed:
		new_state = GameState.PLAYER_ATTACK
	# Baseline: both eyes are closed and nothing is happening
	elif player_eyelids_closed and enemy_eyes_closed:
		new_state = GameState.CLOSED
	_change_game_state(new_state)

# enemy activated game state handling
func _evaluate_enemy_eyes_state() -> void:
	var new_state: GameState
	# Rule 4: enemy opens wide and player is staring
	if not enemy_eyes_closed and not player_eyelids_closed:
		new_state = GameState.ENEMY_ATTACK
	# Rule 5: enemy closes shut and player is hiding
	elif enemy_eyes_closed and player_eyelids_closed:
		new_state = GameState.ENEMY_SCORES
	#Rule 6: enemy closes shut and player is staring
	elif enemy_eyes_closed and not player_eyelids_closed:
		new_state = GameState.PLAYER_STARING
	#Rule 7: enemy opens wide and player is hiding
	elif not enemy_eyes_closed and player_eyelids_closed:
		new_state = GameState.ENEMY_STARING
	_change_game_state(new_state)

func _change_game_state(new_state: GameState) -> void:
	if current_state == new_state: return
	
	previous_state = current_state
	current_state = new_state
	print(GameState.find_key(current_state))
	
	player_point_timer.stop()
	enemy_point_timer.stop()
	
	match current_state:
		GameState.ENEMY_STARING:
			# increase enemy points
			enemy_piercing_timer.start()
			enemy_score = 0
			hud.set_enemy_score(enemy_score)
			hud.show_enemey_score()
			enemy_point_timer.start()
			player_grace_period_timer.stop()
		GameState.PLAYER_STARING:
			# increase player points
			player_point_timer.start()
			hud.hide_enemey_score()
		GameState.ENEMY_ATTACK:
			# player has second(s) to close eyes or game over
			player_grace_period_timer.start()
		
		GameState.PLAYER_ATTACK:
			# enemy will close eyes within a second
			# Add previous state check to see if enemy was blinking to steal points.
			if enemy_is_blinking:
				player_score += enemy_score
				hud.set_player_score(player_score)
			enemy_timer.stop()
			enemy_is_blinking = false
			enemy_grace_period_timer.start()
		GameState.ENEMY_SCORES:
			player_score -= enemy_score
			if player_score < 0: _game_over()
			hud.set_player_score(player_score)
			hud.hide_enemey_score()
		GameState.CLOSED:
			# both eyes closed and nothing is happening
			player_grace_period_timer.stop()
#endregion game state logic

#region timer helper methods
func _on_enemy_piercing_timer_timeout() -> void:
	#stop animation
	pass

func _on_player_score_tick() -> void:
	player_score += 1
	hud.set_player_score(player_score)

func _on_enemy_score_tick() -> void:
	enemy_score += 1
	hud.set_enemy_score(enemy_score)
	
func _on_player_grace_period_timeout() -> void:
	_game_over()
	
func _on_enemy_grace_period_timeout() -> void:
	_toggle_enemy_eye_state()
#endregion timer helper methods

func _game_over() -> void:
	print("GAMEOVER")
	get_tree().quit()

# stop all timers on Game Over UI
func _stop_all_timers() -> void:
	enemy_timer.stop()
	enemy_piercing_timer.stop()
	player_point_timer.stop()
	enemy_point_timer.stop()
	player_grace_period_timer.stop()
	enemy_grace_period_timer.stop()

#endregion helper methods

# Note to future self:
# Needs animations for both piercing eyes and blinking eyes
# Needs speed of enemyTimer to fluctuate from slower faster to make the game feel more lively
# Create a max_player_score counter and create a function to make sure it only sets maximum scores
# Needs Game Over screen
