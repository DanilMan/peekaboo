extends Node2D
class_name Game

@onready var player: Player = $Player
@onready var enemy: Enemy = $Enemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.eyes_state_changed.connect(_on_player_eyes_state_changed)
	enemy.enemy_eyes_state_changed.connect(_on_enemy_eyes_state_changed)

func _on_player_eyes_state_changed(eyes_closed: bool) -> void:
	# Rule 1: player closes shut and enemy is staring
	if eyes_closed and not enemy.enemy_eyes_closed:
		# increase enemy points
		pass
	# Rule 2: player opens wide and enemy is hiding
	elif not eyes_closed and enemy.enemy_eyes_closed:
		# increase player points
		pass
	# Rule 3: player opens wide and enemy is staring
	elif not eyes_closed and not enemy.enemy_eyes_closed:
		# close enemy eyes after a second (or animation)
		# SPECIAL CASE if within 1 second of enemy having just opened eyes game over
		# add logic for if enemy eyes were within a second of closing take points
		# if enemy eyes were in the middle of being open then no points added
		pass

func _on_enemy_eyes_state_changed(enemy_eyes_closed: bool) -> void:
	# Rule 4: enemy opens wide and player is staring
	if not enemy_eyes_closed and not player.eyes_closed:
		# player has 1 second to close eyes or game over (timer is necessary)
		pass
	# Rule 5: enemy closes shut and player is hiding
	elif not enemy_eyes_closed and player.eyes_closed:
		# deduct points from player
		pass

# Note to future self:
# You need a timer in here to handle the point counter
# You need a second timer for the time bomb clock for the 4th Rule
# Use the time stamps where it is helpful or necessary
# If confused look at time bomb and point counter timer info in gemini

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
