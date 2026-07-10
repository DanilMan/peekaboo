class_name EnemyUI
extends Control
## Sets visual state of enemy eyes

# =============================================================================
# onready variables
# =============================================================================
@onready var eye_animation_player: AnimationPlayer = $EyeAnimationPlayer
@onready var warning_animation_player: AnimationPlayer = $WarningAnimationPlayer

# =============================================================================
# helper methods
# =============================================================================
#region enemy eye animations
func play_opening() -> void:
	eye_animation_player.speed_scale = 1.0 # reset scale
	eye_animation_player.play("opening")


func queue_open() -> void:
	eye_animation_player.queue("open")


func play_closing() -> void:
	eye_animation_player.speed_scale = 1.0 # reset scale
	eye_animation_player.play("closing")


func queue_close() -> void:
	eye_animation_player.queue("close")


func play_attack(time: float) -> void:
	var length: float = eye_animation_player.get_animation("attack").length
	var anim_scale: float = get_anim_scale(time, length)
	eye_animation_player.speed_scale = anim_scale
	eye_animation_player.play("attack")


#endregion enemy eye animations
#region warning eye animations
func play_blinking(time: float) -> void:
	var length: float = warning_animation_player.get_animation("blinking").length
	var anim_scale: float = get_anim_scale(time, length)
	warning_animation_player.speed_scale = anim_scale
	warning_animation_player.play("blinking")


func play_piercing(time: float) -> void:
	var length: float = warning_animation_player.get_animation("piercing").length
	var anim_scale: float = get_anim_scale(time, length)
	warning_animation_player.speed_scale = anim_scale
	warning_animation_player.play("piercing")


func stop_warnings() -> void:
	warning_animation_player.speed_scale = 1.0 # reset scale
	warning_animation_player.play("stop_warnings")


#endregion warning eye animations
func get_anim_scale(time: float, length: float) -> float:
	if time > 0.0:
		return length / time
	else:
		return 1.0
