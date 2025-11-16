extends Node

const _sounds:Dictionary[String, Object] = {
	"DOG_BARK" : preload("res://Audio/SFX/Dog-Bark_700748__robinhood76__11780-labrador-dog-barks.wav"),
	"SHIP_HORN" : preload("res://Audio/SFX/157284_Ship_Horn.wav")
}


func _Play_Sound(sound:Object, vol:float) -> void:
	
	# Play sound with AudioStreamPlayer that is NOT Busy
	
	for aud_player in get_children():
		
		if !aud_player.playing:
			aud_player.stream = sound;
			aud_player.play();
			return;
		else:
			continue;
	
	# Add new AudioStreamPlayer to children
	
	var new_aud_player:AudioStreamPlayer = AudioStreamPlayer.new();
	self.add_child(new_aud_player);
	
	new_aud_player.stream = sound;
	new_aud_player.volume_db = vol;
	new_aud_player.play();


# Public ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Ship_Horn(vol:float = 0) -> void:
	_Play_Sound(_sounds.get("SHIP_HORN"), vol);

func Dog_Bark(vol:float = 0) -> void:
	_Play_Sound(_sounds.get("DOG_BARK"), vol);
