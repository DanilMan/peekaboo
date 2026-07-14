class_name Game
extends Control
## Handles game state and all logic and game


# =============================================================================
# enums
# =============================================================================
enum GameState {
	ENEMY_STARING,
	PLAYER_STARING,
	ENEMY_ATTACK,
	PLAYER_ATTACK,
	CLOSED,
	GAME_OVER,
}

# =============================================================================
# public variables 
# =============================================================================
var player_score: int = 0
var player_stamina: float = 100.0
var p_stamina_timestamp: int = 0
var player_score_mult: int = 0
var max_score: int = 0
var enemy_score: int = 0
var current_state: GameState = GameState.CLOSED
var previous_state: GameState = GameState.CLOSED
var player_eyelids_closed: bool = false
var enemy_eyes_closed: bool = true
var enemy_is_blinking: bool = false
var rng := RandomNumberGenerator.new()

# =============================================================================
# export variables
# =============================================================================

@export var enemy_timer_range := Vector2(3.0, 10.0) # default (3.0, 10.0)
@export var enemy_blinking_time: float = 2.0 # default 2.0
@export var enemy_piercing_time: float = 1.0 # default 1.0
@export var player_point_time: float = 0.1 # deault 0.1
@export var enemy_point_time: float = 1.0 # deault 1.0
@export var player_grace_period_time: float = 2.0 # deault 2.0
@export var stamina_time: float = 0.1 # default 0.1
@export var stamina_dec: float = 1 # default 1
@export var stamina_rate: float = 2.0 # default 2.0

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
@onready var stamina_timer: Timer = $StaminaTimer
@onready var game_over_screen: MarginContainer = $GameOverScreen
@onready var max_score_label: Label = %MaxScore
@onready var dust_particles: GPUParticles2D = %DustParticles

#@onready var fps: Label = $FPS

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
	
	_initialize_enemy_timer()
	enemy_piercing_timer.wait_time = enemy_piercing_time
	enemy_piercing_timer.timeout.connect(_on_enemy_piercing_timer_timeout)
	player_point_timer.wait_time = player_point_time
	player_point_timer.timeout.connect(_on_player_score_tick)
	enemy_point_timer.wait_time = enemy_point_time
	enemy_point_timer.timeout.connect(_on_enemy_score_tick)
	player_grace_period_timer.wait_time = player_grace_period_time
	player_grace_period_timer.timeout.connect(_on_player_grace_period_timeout)
	stamina_timer.wait_time = stamina_time
	stamina_timer.timeout.connect(_on_stamina_timeout)
	
	_initialize_game_state()
	
	hud.open_eye() # initialize player eyes open 


func _initialize_enemy_timer() -> void:
	rng.randomize()
	var rand_time: float = rng.randf_range(enemy_timer_range.x, enemy_timer_range.y)
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
	if player_eyelids_closed:
		return
	
	var stamina_delta: int = Time.get_ticks_msec() - p_stamina_timestamp
	stamina_delta /= round(100.0 / stamina_rate)
	player_stamina = clampf(player_stamina + stamina_delta, 0.0, 100.0)
	
	if player_stamina <= 0.0:
		return
	
	dust_particles.restart()
	dust_particles.emitting = false
	
	stamina_timer.start()
	hud.set_stamina_bars(player_stamina)
	hud.show_stamina_bars()
	
	player_eyelids_closed = true
	player_score_mult = 0
	hud.close_eye()
	_evaluate_eyes_state(true)


func _open_player_eyes() -> void:
	if not player_eyelids_closed:
		return
	
	if not enemy_piercing_timer.is_stopped():
		_change_game_state(GameState.GAME_OVER)
		return
	
	dust_particles.emitting = true
	
	hud.hide_stamina_bars()
	stamina_timer.stop()
	p_stamina_timestamp = Time.get_ticks_msec()
	
	
	player_eyelids_closed = false
	hud.open_eye()
	_evaluate_eyes_state(true)


#endregion player input
# --- App Out of Focus ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# forces eyes open in edge case (could switch to pause menu later)
		Input.action_release("Eyelid")

# check fps
#func _process(_delta: float) -> void:
	#fps.text = "FPS: %d" % Engine.get_frames_per_second()

#endregion built-in methods

# =============================================================================
# helper methods
# =============================================================================
#region helper methods
# toggles enemy eyes and resets enemy_timer with rand cooldown
func _on_enemy_timer_timeout() -> void:
	if current_state != GameState.ENEMY_STARING:
		# enemy eyes are about to open after eyes are toggled
		enemy_is_blinking = false
		_toggle_enemy_eye_state(enemy_blinking_time)
		return
	
	if not enemy_is_blinking:
		# timer just ended and enemy is staring so start 1 second blink
		enemy_is_blinking = true
		enemy_ui.play_blinking(enemy_blinking_time)
		enemy_timer.start(enemy_blinking_time)
	else:
		# 1 second blink ended toggle enemy eye state
		enemy_is_blinking = false
		_toggle_enemy_eye_state()


func _toggle_enemy_eye_state(dec_range: float = 0.0) -> void:
	_toggle_enemy_eyes()
	_evaluate_eyes_state(false)
	var rand_time: float = rng.randf_range(enemy_timer_range.x, enemy_timer_range.y - dec_range)
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
	if current_state == new_state:
		return
	if current_state == GameState.GAME_OVER:
		return
	
	previous_state = current_state
	current_state = new_state
	#print(GameState.find_key(current_state))
	
	player_point_timer.stop()
	enemy_point_timer.stop()
	
	enemy_ui.stop_warnings()
	
	hud.grey_player_score()
	
	_update_max_score()
	
	match current_state:
		GameState.ENEMY_STARING:
			# increase enemy points
			enemy_ui.play_piercing(enemy_piercing_time)
			enemy_piercing_timer.start()
			enemy_score = 0
			hud.set_enemy_score(enemy_score)
			hud.show_enemy_score()
			enemy_point_timer.start()
			player_grace_period_timer.stop()
		GameState.PLAYER_STARING:
			# increase player points
			player_point_timer.start()
			hud.hide_enemy_score()
			hud.white_player_score()
		GameState.ENEMY_ATTACK:
			# player has second(s) to close eyes or game over
			enemy_ui.play_attack(player_grace_period_time)
			hud.flinch_eye()
			player_grace_period_timer.start()
		GameState.PLAYER_ATTACK:
			# enemy will close eyes within a second
			if enemy_is_blinking:
				var prev_player_score: int = player_score
				player_score += _get_enemy_mult_score()
				_update_max_score()
				hud.tween_player_score(prev_player_score, player_score, player_point_time)
			enemy_timer.stop()
			enemy_is_blinking = false
			_toggle_enemy_eye_state()
		GameState.CLOSED:
			# both eyes closed and nothing is happening
			player_grace_period_timer.stop()
		GameState.GAME_OVER:
			max_score_label.text = "Max Score: " + str(max_score)
			game_over_screen.visible = true
			hud.stop_hud()
			enemy_ui.stop_enemy_ui()
			_stop_all_timers()


#endregion game state logic
#region timer helper methods
func _on_enemy_piercing_timer_timeout() -> void:
	enemy_ui.stop_warnings()


func _on_player_score_tick() -> void:
	var prev_player_score: int = player_score
	player_score_mult += 1 + _get_base_10_log(player_score)
	player_score += player_score_mult
	hud.tween_player_score(prev_player_score, player_score, player_point_time)
	hud.pop_player_score()


func _update_max_score() -> void:
	max_score = maxi(player_score, max_score)


func _on_enemy_score_tick() -> void:
	enemy_score += 1
	hud.set_enemy_score(enemy_score)
	hud.pop_enemy_score()


func _on_player_grace_period_timeout() -> void:
	_change_game_state(GameState.GAME_OVER)


func _on_stamina_timeout() -> void:
	player_stamina = clampf(player_stamina - stamina_dec, 0.0, 100.0)
	hud.set_stamina_bars(player_stamina)
	if player_stamina <= 0.0:
		_open_player_eyes()


#endregion timer helper methods
func _enemy_scores_event() -> void:
	var prev_player_score: int = player_score
	player_score -= _get_enemy_mult_score()
	hud.hide_enemy_score()
	if player_score < 0:
		_change_game_state(GameState.GAME_OVER)
	#hud.set_player_score(player_score)
	hud.tween_player_score(prev_player_score, player_score, player_point_time)


# stop all timers on Game Over UI
func _stop_all_timers() -> void:
	enemy_timer.stop()
	enemy_piercing_timer.stop()
	player_point_timer.stop()
	enemy_point_timer.stop()
	player_grace_period_timer.stop()
	stamina_timer.stop()


func _get_enemy_mult_score() -> int:
	return enemy_score * (10 ** _get_base_10_log(player_score))


func _get_base_10_log(num: int) -> int:
	if num <= 0:
		return 0
	return floori(log(num) / log(10.0))


#endregion helper methods

# Note to future self:
# After initial playtest:
# Also, maybe a spacebar stamina bar, so the player sees they can keep their eyes shut for only so 
# long (adds difficulty/complexity and communicates to player.

# After second playtest:
# Point system starting making more sense, still confusion over how to defeat enemy eyes. Both
# players kept tapping the space bar instead of holding it down. I think that spacebar stamina bar
# might help, but I don't know what other visual cues might help. Yes I could add the scary enemy
# audio and a serene hum that makes holding the eyes shut satisfying (as well as visual white noise
# behind the eyes). But of course audio will do a great job communicating. I want more visual clues
# beyond straight up have a text prompt tell the player to hold down spacebar to avoid the enemy.
# Maybe create menu screen and allow player to check or uncheck toggle spacebar for different
# player styles.

# Make player point increment dependent on player score.

# Eigengrau shader needs tweaking. Also, maybe try adding it to Eyelid(s) instead. STAMINA BAR!!!!
# Particles that fall down the screen, looking like dust in the darkness.
# Fix optimization for shader too.

# As game stands in current state, it is unclear to non-gamer player what game is. Player repeatedly
# smashed spacebar "the monkey at the keyboard." Didn't understand why they kept losing and what
# they were supposed to do to not lose. Needs more visual and eventually audio communication.

# Add enemy point animation?, particle text for enemy points, player eyelid twitch for enemy attack,
# spacebar stamina bar, shader for edge of screen glowing blood red when enemied eyes open (bright
# until peircing ends, then mellow, then bright and blinking along with enemy eye blinks), add enemy
# eye blink animation speeds up.
# Get as much visual information to the player to communicate what the game is. Also
# maybe add some placeholder sfx.

# Needs speed of enemyTimer to fluctuate from slower faster to make the game feel more lively  

# Add monster silhouette that fades in and out at random like a flickering and fading light source
# allows their face to almost be visible in the darkness, creeping out the plater and giving them
# something to look at

# Maybe get rid of Previous State Haven't used it yet...!!!!!!!!!!!!!!!!!!
