@tool
extends Control

# =============================================================================
# export variables
# =============================================================================
@export var sprite: Sprite2D:
	set(value):
		sprite = value
		_update_size()

# =============================================================================
# built-in virtual methods
# =============================================================================
func _ready() -> void:
	_update_size()


func _enter_tree() -> void:
	_update_size()


# =============================================================================
# helper methods
# =============================================================================
func _update_size() -> void:
	if sprite and sprite.texture:
		var frame_width : float = float(sprite.texture.get_width()) / sprite.hframes
		var frame_height : float = float(sprite.texture.get_height()) / sprite.vframes
		
		custom_minimum_size = Vector2(frame_width, frame_height)
