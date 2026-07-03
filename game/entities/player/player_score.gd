extends Label

@onready var particles: GPUParticles2D = $GPUParticles2D

func emit_particles() -> void:
	particles.position = pivot_offset
	particles.resize_box_extents(size)
	particles.emitting = true;

func stop_particles() -> void:
	particles.emitting = false
