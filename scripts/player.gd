extends Node2D
class_name Player

var eyes_closed : bool = true
signal eyes_state_changed(eyes_closed: bool)
@onready var left: Sprite2D = $Left
@onready var right: Sprite2D = $Right

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Eyelid"):
		close_eye()
	elif event.is_action_released("Eyelid"):
		open_eye()

func close_eye() -> void:
	if eyes_closed: return
	eyes_closed = true
	eyes_state_changed.emit(eyes_closed)
	left.show()
	right.show()

func open_eye() -> void:
	if not eyes_closed: return
	eyes_closed = false
	eyes_state_changed.emit(eyes_closed)
	left.hide()
	right.hide()

# --- App Out of Focus ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		#forces eyes open in edge case (could switch to pause menu later)
		Input.action_release("Eyelid")
		open_eye()

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
