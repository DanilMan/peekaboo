extends Control
class_name HUD

@onready var left_eyelid: TextureRect = %LeftEyelid
@onready var right_eyelid: TextureRect = %RightEyelid

func close_eye() -> void:
	left_eyelid.show()
	right_eyelid.show()

func open_eye() -> void:
	left_eyelid.hide()
	right_eyelid.hide()
