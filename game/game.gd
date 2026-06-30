extends Control
class_name Game

# =============================================================================
# enums
# =============================================================================
enum GameState {ENEMY_STARING, PLAYER_STARING, ENEMY_ATTACK, PLAYER_ATTACK, CLOSED, GAME_OVER}

# =============================================================================
# public variables 
# =============================================================================
var player_score: int = 0
var player_score_mult: int = 0
var max_score: int = 0
var enemy_score: int = 0
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
@onready var game_over_screen: CanvasLayer = $GameOverScreen

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
	
	_initialize_game_state()

# helper funcitons of _ready
func _initialize_ui() -> void:
	# this will change when eyes are controled together with animations!!!!!!!!!!!!!!!
	hud.left_eyelid.visible = player_eyelids_closed # set player eye to bool handler
	hud.right_eyelid.visible = player_eyelids_closed # set player eye to bool handler

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
# input method to open or close player eyes and game over input
func _unhandled_input(event: InputEvent) -> void:
	if current_state == GameState.GAME_OVER:
		if event.is_action_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
	if event.is_action_pressed("Eyelid"):
		_close_player_eyes()
	elif event.is_action_released("Eyelid"):
		_open_player_eyes()

# helper methods of _unhandled_input
func _close_player_eyes() -> void:
	if player_eyelids_closed: return
	player_eyelids_closed = true
	player_score_mult = 0
	hud.close_eye()
	_evaluate_eyes_state(true)

func _open_player_eyes() -> void:
	if not player_eyelids_closed: return
	
	if not enemy_piercing_timer.is_stopped():
		_change_game_state(GameState.GAME_OVER)
		return
	
	player_eyelids_closed = false
	hud.open_eye()
	_evaluate_eyes_state(true)

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
		enemy_ui.play_blinking()
		enemy_timer.start(2) # hard coded!!!!!!!!!!!!!!!!!!!!!
	else:
		# 1 second blink ended toggle enemy eye state
		enemy_is_blinking = false
		_toggle_enemy_eye_state()

func _toggle_enemy_eye_state() -> void:
	_toggle_enemy_eyes()
	_evaluate_eyes_state(false)
	var rand_time := rng.randi_range(3, 10) # hard coded!!!!!!!!!!!!!!
	enemy_timer.wait_time = rand_time
	enemy_timer.start()

func _toggle_enemy_eyes() -> void:
	if enemy_eyes_closed:
		enemy_ui.play_opening()
		enemy_ui.queue_open()
		enemy_eyes_closed = false
	else:
		enemy_ui.play_closing()
		enemy_ui.queue_close()
		enemy_eyes_closed = true

#region game state logic
# game state handling
func _evaluate_eyes_state(is_player_action: bool) -> void:
	var new_state: GameState
	# Rule 1: player opens wide and enemy is hiding
	if not player_eyelids_closed and enemy_eyes_closed:
		new_state = GameState.PLAYER_STARING
	# Rule 2: player closes shut and enemy is staring
	elif player_eyelids_closed and not enemy_eyes_closed:
		new_state = GameState.ENEMY_STARING
	# Rule 3: both open wide and context determines attacker
	elif not player_eyelids_closed and not enemy_eyes_closed:
		new_state = GameState.PLAYER_ATTACK if is_player_action else GameState.ENEMY_ATTACK
	# Rule 4: both eyes are closed and passive state
	elif player_eyelids_closed and enemy_eyes_closed:
		if not is_player_action:
			_enemy_scores_event()
		new_state = GameState.CLOSED
	_change_game_state(new_state)

func _change_game_state(new_state: GameState) -> void:
	if current_state == new_state: return
	if current_state == GameState.GAME_OVER: return
	
	previous_state = current_state
	current_state = new_state
	#print(GameState.find_key(current_state))
	
	player_point_timer.stop()
	enemy_point_timer.stop()
	
	enemy_ui.stop_warnings()
	
	match current_state:
		GameState.ENEMY_STARING:
			# increase enemy points
			enemy_ui.play_piercing()
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
			enemy_ui.play_attack()
			player_grace_period_timer.start()
		GameState.PLAYER_ATTACK:
			# enemy will close eyes within a second
			# Add previous state check to see if enemy was blinking to steal points.
			if enemy_is_blinking:
				player_score += enemy_score * 100 # no hard coding!!!!!!!!!!!!!!
				hud.set_player_score(player_score)
			enemy_timer.stop()
			enemy_is_blinking = false
			_toggle_enemy_eye_state()
		GameState.CLOSED:
			# both eyes closed and nothing is happening
			player_grace_period_timer.stop()
		GameState.GAME_OVER:
			game_over_screen.visible = true
			_stop_all_timers()
#endregion game state logic

#region timer helper methods
func _on_enemy_piercing_timer_timeout() -> void:
	enemy_ui.stop_warnings()

func _on_player_score_tick() -> void:
	player_score_mult += 1 # hard coded!!!!!!!!!!!!!!!!!!!
	player_score += player_score_mult
	hud.set_player_score(player_score)
	_update_max_score()

func _update_max_score() -> void:
	if player_score > max_score:
		max_score = player_score

func _on_enemy_score_tick() -> void:
	enemy_score += 1
	hud.set_enemy_score(enemy_score)
	
func _on_player_grace_period_timeout() -> void:
	_change_game_state(GameState.GAME_OVER)

#endregion timer helper methods

func _enemy_scores_event() -> void:
	player_score -= enemy_score * 100 # fix later, no hard coding!!!!!!!!!!
	if player_score < 0: _change_game_state(GameState.GAME_OVER)
	hud.set_player_score(player_score)
	hud.hide_enemey_score()

# stop all timers on Game Over UI
func _stop_all_timers() -> void:
	enemy_timer.stop()
	enemy_piercing_timer.stop()
	player_point_timer.stop()
	enemy_point_timer.stop()
	player_grace_period_timer.stop()

#endregion helper methods

# Note to future self:
# Needs speed of enemyTimer to fluctuate from slower faster to make the game feel more lively  


# After initial playtest, I think points should go up in a non-linear way so it's clear the longer
# you open your eyes, the more points you are gaining. Also, maybe a spacebar cooldown bar, so the
# player sees they can keep their eyes shut for only so long (adds difficulty/complexity and
# communicates to player.
# As game stands in current state, it is unclear to non-gamer player what game is. Player repeatedly
# smashed spacebar "the monkey at the keyboard." Didn't understand why they kept losing and what
# they were supposed to do to not lose. Needs more visual and eventually audio communication.

# Add point animation, player eyelid twitch for enemy attack, spacebar stamina bar.
# Get as much visual information to the player to communicate what the game is. Also
# maybe add some placeholder sfx.

# Add monster silhouette that fades in and out at random like a flickering and fading light source
# allows their face to almost be visible in the darkness, creeping out the plater and giving them
# something to look at

# Maybe get rid of Previous State
