extends AudioStreamPlayer

const MUSIC:Array = [
	preload("res://Audio/Music/The Sea - Tomas Dvorak, Machinarium.mp3")
]


func _ready() -> void:
	_Play(0, .3);


func _Play(music_idx:int, vol:float) -> void:
	stream = MUSIC[music_idx];
	self.volume_linear = vol;
	self.play();
