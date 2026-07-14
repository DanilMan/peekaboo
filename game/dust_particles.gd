@tool
extends GPUParticles2D

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
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	var particle_material := process_material as ParticleProcessMaterial
	if particle_material:
		particle_material.emission_box_extents = Vector3(screen_size.x, screen_size.y, 0.0)
