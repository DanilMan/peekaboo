extends Control
class_name EnemyUI

@onready var lefteye: TextureRect = %LeftEye
@onready var righteye: TextureRect = %RightEye

func enemy_eyes_open() -> void:
	lefteye.visible = true
	righteye.visible = true
	
func enemy_eyes_close() -> void:
	lefteye.visible = false
	righteye.visible = false
