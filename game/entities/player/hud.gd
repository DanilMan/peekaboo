extends Control
class_name HUD

# =============================================================================
# onready variables
# =============================================================================
@onready var left_eyelid: TextureRect = %LeftEyelid
@onready var right_eyelid: TextureRect = %RightEyelid
@onready var player_score: Label = %PlayerScore
@onready var enemy_score: Label = %EnemyScore

# =============================================================================
# helper methods
# =============================================================================
func close_eye() -> void:
	left_eyelid.show()
	right_eyelid.show()

func open_eye() -> void:
	left_eyelid.hide()
	right_eyelid.hide()

func set_player_score(val: int) -> void:
	player_score.text = str(val)

func show_enemey_score() -> void:
	enemy_score.visible = true

func hide_enemey_score() -> void:
	enemy_score.visible = false

func set_enemy_score(val: int) -> void:
	enemy_score.text = str(val)
