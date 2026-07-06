@tool
extends Sprite2D

# =============================================================================
# built-in virtual methods
# =============================================================================
func _ready() -> void:
	if not get_tree().get_root().size_changed.is_connected(_resize_sprite_to_screen):
		get_tree().get_root().size_changed.connect(_resize_sprite_to_screen)
	_resize_sprite_to_screen()


func _enter_tree() -> void:
	_resize_sprite_to_screen()


# =============================================================================
# helper methods
# =============================================================================
func _resize_sprite_to_screen() -> void:
	if not texture:
		return   
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	var frame_size: Vector2 = Vector2(texture.get_size().x / hframes,
	texture.get_size().y / vframes)
	global_scale.x = screen_size.x / frame_size.x
	global_scale.y = screen_size.y / frame_size.y
