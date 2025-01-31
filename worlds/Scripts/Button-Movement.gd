extends Node;

func Get_InputDirection() -> Vector2i:
	if Input.is_action_just_pressed("Up"):
		return Vector2i(0,-1);
	if Input.is_action_just_pressed("Down"):
		return Vector2i(0,1);
	if Input.is_action_just_pressed("Left"):
		return Vector2i(-1,0);
	if Input.is_action_just_pressed("Right"):
		return Vector2i(1,0);
	return Vector2i(0,0);
