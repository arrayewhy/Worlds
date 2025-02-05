extends Camera2D;

signal Zoom;

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Two"):
		Zoom.emit();
