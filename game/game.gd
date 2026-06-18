extends Control
class_name Game

# =============================================================================
# enums
# =============================================================================
enum GameState {ENEMY_STARING, PLAYER_STARING, ENEMY_ATTACK, PLAYER_ATTACK, ENEMY_SCORES, CLOSED}

# =============================================================================
# public variables
# =============================================================================
var current_state: GameState = GameState.CLOSED
var player_eyelids_closed: bool = false
var enemy_eyes_closed: bool = true
var rng:= RandomNumberGenerator.new()

# =============================================================================
# onready variables
# =============================================================================
@onready var hud: HUD = $HUD
@onready var enemy_ui: EnemyUI = $EnemyUI
@onready var timer: Timer = $EnemyTimer

# =============================================================================
# built-in virtual methods
# =============================================================================
#region built-in methods
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_window().grab_focus() #TRY THIS FIRST FOR MOUSE FIRST CLICK NOT CAPTURED!!!!!!
	#DisplayServer.window_request_attention() ## TRY THIS!!!!!!!!
	#DisplayServer.window_move_to_foreground() ### TRY THIS 2!!!!!!!!
	
	# this will change when eyes are controled together with animations!!!!!!!!!!!!!!!
	hud.left_eyelid.visible = player_eyelids_closed # set player eye to bool handler
	hud.right_eyelid.visible = player_eyelids_closed # set player eye to bool handler
	enemy_ui.lefteye.visible = not enemy_eyes_closed # set enemy eye to bool handler
	enemy_ui.righteye.visible = not enemy_eyes_closed # set enemy eye to bool handler
	
	rng.randomize()
	var rand_time := rng.randi_range(3, 10)
	timer.wait_time = rand_time
	timer.timeout.connect(_on_enemy_timer_timeout)
	timer.start()

#region player input
# input method to open or close player eyes
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Eyelid"):
		_close_eye()
	elif event.is_action_released("Eyelid"):
		_open_eye()

# helper methods of _unhandled_input
func _close_eye() -> void:
	if player_eyelids_closed: return
	_evaluate_player_eyes_state()
	player_eyelids_closed = true
	hud.close_eye()

func _open_eye() -> void:
	if not player_eyelids_closed: return
	_evaluate_player_eyes_state()
	player_eyelids_closed = false
	hud.open_eye()
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
# toggles enemy eyes and resets timer with rand cooldown
func _on_enemy_timer_timeout() -> void:
	_toggle_enemy_eyes()
	_evaluate_enemy_eyes_state()
	var rand_time := rng.randi_range(3, 10)
	timer.wait_time = rand_time
	timer.start()

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
	# Rule 1: player closes shut and enemy is staring
	if player_eyelids_closed and not enemy_eyes_closed:
		current_state = GameState.ENEMY_STARING
	# Rule 2: player opens wide and enemy is hiding
	elif not player_eyelids_closed and enemy_eyes_closed:
		current_state = GameState.PLAYER_STARING
	# Rule 3: player opens wide and enemy is staring
	elif not player_eyelids_closed and not enemy_eyes_closed:
		current_state = GameState.ENEMY_ATTACK
	# Baseline: both eyes are closed and nothing is happening
	elif player_eyelids_closed and enemy_eyes_closed:
		current_state = GameState.CLOSED
	_change_game_state()

# enemy activated game state handling
func _evaluate_enemy_eyes_state() -> void:
	# Rule 4: enemy opens wide and player is staring
	if not enemy_eyes_closed and not player_eyelids_closed:
		current_state = GameState.PLAYER_ATTACK
	# Rule 5: enemy closes shut and player is hiding
	elif enemy_eyes_closed and player_eyelids_closed:
		current_state = GameState.ENEMY_SCORES
	_change_game_state()

func _change_game_state() -> void:
	#print(current_state) # remove later!!!!!!!!!!!!!!!
	match current_state:
		GameState.ENEMY_STARING:
			# increase enemy points
			pass
		GameState.PLAYER_STARING:
			# increase player points
			pass
		GameState.ENEMY_ATTACK:
			# close enemy eyes after a second (or animation)
			# SPECIAL CASE if within 1 second of enemy having just opened eyes game over
			# add logic for if enemy eyes were within a second of closing take points
			# if enemy eyes were in the middle of being open then no points added
			pass
		GameState.PLAYER_ATTACK:
			# player has 1 second to close eyes or game over (time_stamp _process necessary)
			pass
		GameState.ENEMY_SCORES:
			# deduct points from player
			pass
		GameState.CLOSED:
			# both eyes closed and nothing is happening
			pass
		
#endregion game state logic

#endregion helper methods

# Note to future self:
# You need a timer in here to handle the point counter
# You need a second timer for the time bomb clock for the 4th Rule
# Use the time stamps where it is helpful or necessary
# If confused look at time bomb and point counter timer info in gemini
