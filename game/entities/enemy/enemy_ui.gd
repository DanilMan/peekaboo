extends Control
class_name EnemyUI

# =============================================================================
# onready variables
# =============================================================================
@onready var eye_animation_player: AnimationPlayer = $EyeAnimationPlayer
@onready var warning_animation_player: AnimationPlayer = $WarningAnimationPlayer

# =============================================================================
# helper methods
# =============================================================================
func play_opening() -> void:
	eye_animation_player.play("opening")

func queue_open() -> void:
	eye_animation_player.queue("open")

func play_closing() -> void:
	eye_animation_player.play("closing")

func queue_close() -> void:
	eye_animation_player.queue("close")

func play_attack() -> void:
	eye_animation_player.play("attack")
	eye_animation_player.queue("open")

func play_blinking() -> void:
	warning_animation_player.play("blinking")

func play_piercing() -> void:
	warning_animation_player.play("piercing")

func stop_warnings() -> void:
	warning_animation_player.play("stop_warnings")
