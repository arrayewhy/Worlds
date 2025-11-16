extends Node;

@onready var sfx:Node = $SFX;

func PlaySFX_DogBark(pos:Vector2) -> void:
	sfx.PlayAudio_DogBark(pos);
