extends ColorRect

var current_fade: float = 0.0
@export var fade_in_duration: float = 0.6
@export var fade_out_duration: float = 0.1
var tween: Tween

func _ready() -> void:
	visible = true
	material.set_shader_parameter("fade", 0.0)

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
