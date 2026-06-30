@tool
extends Control

@onready var sprite: Sprite2D = $RightEye

func _ready() -> void:
	_update_size()

func _enter_tree() -> void:
	_update_size()

func _update_size() -> void:
	if sprite != null and sprite.texture != null:
		var frame_width := float(sprite.texture.get_width()) / sprite.hframes
		var frame_height := float(sprite.texture.get_height()) / sprite.vframes
		
		custom_minimum_size = Vector2(frame_width, frame_height)
