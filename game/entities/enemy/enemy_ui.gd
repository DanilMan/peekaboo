extends Control
class_name EnemyUI

# =============================================================================
# onready variables
# =============================================================================
@onready var left_eye: TextureRect = %LeftEye
@onready var right_eye: TextureRect = %RightEye
@onready var warning_left_eye: TextureRect = %WarningLeftEye
@onready var warning_right_eye: TextureRect = %WarningRightEye

# =============================================================================
# helper methods
# =============================================================================
func enemy_eyes_open() -> void:
	left_eye.visible = true
	right_eye.visible = true
	
func enemy_eyes_close() -> void:
	left_eye.visible = false
	right_eye.visible = false
