extends Control
class_name EnemyUI

# =============================================================================
# onready variables
# =============================================================================
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# =============================================================================
# helper methods
# =============================================================================
func play_opening() -> void:
	animation_player.play("opening")

func queue_open() -> void:
	animation_player.queue("open")

func play_closing() -> void:
	animation_player.play("closing")

func queue_close() -> void:
	animation_player.queue("close")

func play_blinking() -> void:
	animation_player.play("blinking")

func play_piercing() -> void:
	animation_player.play("piercing")

func play_stop_warnings() -> void:
	animation_player.play("stop_warnings")
