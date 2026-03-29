extends Node

const _sounds:Dictionary[String, Object] = {
	"DOG_BARK" : preload("res://Audio/SFX/Dog-Bark_700748__robinhood76__11780-labrador-dog-barks.wav"),
	"SHIP_HORN" : preload("res://Audio/SFX/157284_Ship_Horn.wav"),
	"DRAGON_GROWL" : preload("res://Audio/SFX/Dragon_Growl.mp3"),
}


func _Play_Sound(sound:Object, decibels:float, rand_pitch:bool = false) -> void:
	
	# Play sound with AudioStreamPlayer that is NOT Busy
	
	for aud_player in get_children():
		
		if !aud_player.playing:
			aud_player.stream = sound;
			
			if rand_pitch:
				aud_player.pitch_scale = randf_range(1, 1.1);
			else:
				aud_player.pitch_scale = 1;
			
			aud_player.play();
			return;
		else:
			continue;
	
	# Add new AudioStreamPlayer to children
	
	var new_aud_player:AudioStreamPlayer = AudioStreamPlayer.new();
	self.add_child(new_aud_player);
	
	new_aud_player.stream = sound;
	new_aud_player.volume_db = decibels;
	
	if rand_pitch:
		new_aud_player.pitch_scale = randf_range(1, 1.1);
	else:
		new_aud_player.pitch_scale = 1;
	
	new_aud_player.play();


# Public ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Ship_Horn(decibels:float = 0) -> void:
	_Play_Sound(_sounds.get("SHIP_HORN"), decibels, true);

func Dog_Bark(decibels:float = 0) -> void:
	_Play_Sound(_sounds.get("DOG_BARK"), decibels, true);

func Dragon_Growl(decibels:float = 0) -> void:
	_Play_Sound(_sounds.get("DRAGON_GROWL"), decibels, true)
