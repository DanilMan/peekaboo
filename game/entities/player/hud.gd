extends Control
class_name HUD

# =============================================================================
# onready variables
# =============================================================================
@onready var left_eyelid: Control = %Left
@onready var right_eyelid: Control = %Right
@onready var player_score: Label = %PlayerScore
@onready var enemy_score: Label = %EnemyScore
@onready var eyelid_animation_player: AnimationPlayer = $EyelidAnimationPlayer

# =============================================================================
# helper methods
# =============================================================================
#region eyelid animations
func close_eye() -> void:
	#left_eyelid.show()
	#right_eyelid.show()
	eyelid_animation_player.play("closing")

func open_eye() -> void:
	#left_eyelid.hide()
	#right_eyelid.hide()
	eyelid_animation_player.play("opening")
#endregion eyelid animations

#region game scores
func set_player_score(val: int) -> void:
	player_score.text = str(val)

func show_enemey_score() -> void:
	enemy_score.visible = true

func hide_enemey_score() -> void:
	enemy_score.visible = false

func set_enemy_score(val: int) -> void:
	enemy_score.text = str(val)
#endregion game scores
