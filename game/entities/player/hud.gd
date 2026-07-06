class_name HUD
extends Control
## Sets the hud visuals states

# =============================================================================
# public variables 
# =============================================================================
const EigengrauScript = preload("res://game/entities/player/eigengrau_overlay.gd")
var player_score_tween: Tween
var player_score_color_tween: Tween
var enemy_score_tween: Tween


# =============================================================================
# onready variables
# =============================================================================
@onready var player_score: Label = %PlayerScore
@onready var enemy_score: Label = %EnemyScore
@onready var eigengrau_overlay: EigengrauScript = $EigengrauOverlay
@onready var player_particles: GPUParticles2D = %PlayerParticles
@onready var eyelid_animation_player: AnimationPlayer = $EyelidAnimationPlayer

# =============================================================================
# helper methods
# =============================================================================
#region eyelid animations
func close_eye() -> void:
	eyelid_animation_player.play("closing")
	eigengrau_overlay.set_fade(true)


func open_eye() -> void:
	eyelid_animation_player.play("opening")
	eigengrau_overlay.set_fade(false)


#endregion eyelid animations
#region game scores
func set_player_score(val: int) -> void:
	player_score.text = str(val)


func pop_player_score() -> void:
	player_score.pivot_offset = player_score.size / 2.0 # set center of label
	
	emit_player_particles()
	
	if player_score_tween and player_score_tween.is_valid():
		player_score_tween.kill()
	
	player_score_tween = create_tween()
	
	# tween scale label up by 0.05 and color green
	player_score_tween.tween_property(player_score, "scale", Vector2(1.05, 1.05), 0.05) \
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	player_score_tween.parallel().tween_property(player_score,
	"theme_override_colors/font_color", Color(0.702, 1.0, 0.675, 1.0), 0.05)
	# tween scale label down to original state adn color white
	player_score_tween.tween_property(player_score, "scale", Vector2(1.0, 1.0), 0.05) \
	.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	player_score_tween.parallel().tween_property(player_score,
	"theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 1.0), 0.05)


func emit_player_particles() -> void:
	player_particles.position = player_score.pivot_offset
	
	var player_particle_material := player_particles.process_material as ParticleProcessMaterial
	if player_particle_material:
		player_particle_material.emission_box_extents = Vector3(player_score.size.x, player_score.size.y, 0.0)
	
	player_particles.emitting = true;


func grey_player_score() -> void:
	player_particles.emitting = false;
	
	if player_score_color_tween and player_score_color_tween.is_valid():
		player_score_color_tween.kill()
	
	player_score_color_tween = create_tween()
	
	player_score_color_tween.tween_property(player_score, "modulate", Color("686868"), 0.05) \
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func white_player_score() -> void:
	if player_score_color_tween and player_score_color_tween.is_valid():
		player_score_color_tween.kill()
		
	player_score_color_tween = create_tween()
	
	player_score_color_tween.tween_property(player_score, "modulate", Color("ffffff"), 0.05) \
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func hide_player_score() -> void:
	player_score.visible = false


func show_enemey_score() -> void:
	enemy_score.visible = true


func hide_enemey_score() -> void:
	enemy_score.visible = false


func set_enemy_score(val: int) -> void:
	enemy_score.text = str(val)


func pop_enemy_score() -> void:
	enemy_score.pivot_offset = enemy_score.size / 2.0 # set center of label
	
	if enemy_score_tween and enemy_score_tween.is_valid():
		enemy_score_tween.kill()
	
	enemy_score_tween = create_tween()
	
	# tween scale up by 0.2
	enemy_score_tween.tween_property(enemy_score, "scale", Vector2(1.2, 1.2), 0.5) \
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# tween scale back to original state
	enemy_score_tween.tween_property(enemy_score, "scale", Vector2(1.0, 1.0), 0.5) \
	.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


#endregion game scores
