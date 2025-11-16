extends Node


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("One"):
		Engine.time_scale = 1.0;
		return;
	if event.is_action_pressed("Two"):
		Engine.time_scale = 2.0;
		return;
	if event.is_action_pressed("Three"):
		Engine.time_scale = 3.0;
		return;
