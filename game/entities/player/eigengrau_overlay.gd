extends ColorRect

# =============================================================================
# public variables 
# =============================================================================
var current_fade: float = 0.0
var tween: Tween

# =============================================================================
# onready variables
# =============================================================================
@export var fade_in_duration: float = 0.6
@export var fade_out_duration: float = 0.1

# =============================================================================
# built-in virtual methods
# =============================================================================
func _ready() -> void:
	visible = true
	var eig_shader_material := material as ShaderMaterial
	if eig_shader_material:
		eig_shader_material.set_shader_parameter("fade", 0.0)


# =============================================================================
# helper methods
# =============================================================================
func set_fade(is_closed: bool) -> void:
	if tween and tween.is_valid():
		tween.kill()
		
	tween = create_tween()
	
	if is_closed:
		visible = true
		tween.tween_property(material, "shader_parameter/fade", 1.0, fade_in_duration) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(material, "shader_parameter/fade", 0.0, fade_out_duration) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN)
		tween.tween_callback(func() -> void: visible = false)
