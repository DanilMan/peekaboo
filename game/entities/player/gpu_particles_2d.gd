extends GPUParticles2D

func resize_box_extents(size: Vector2) -> void:
	process_material.emission_box_extents = Vector3(size.x, size.y, 0.0)
