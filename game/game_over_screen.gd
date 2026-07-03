extends MarginContainer

@onready var max_score_label: Label = %MaxScore

func game_over(max_score: int) -> void:
	max_score_label.text = "Max Score: " + str(max_score)
	visible = true
