extends Node

@onready var _playerPrefab:PackedScene = preload("res://Prefabs/player.tscn");

@export var _mapGen:Node2D;
@export var _cont_showOnZoom:Node2D;

@export var _cam:Camera2D;
@export var _message:Node2D;

signal Player_Created(player:AnimatedSprite2D);


func _ready() -> void:
	
	await get_tree().process_frame;
	
	# When Map Generation Ends, Create the player
	_mapGen.Map_Generated.connect(_Create_Player);
	
	# Generate the Map
	_mapGen.Generate_Map(Map_Data.goodSeeds.find_key("cut_through_the_mountains"), self.get_path());


func _Create_Player() -> void:
	
	var player:AnimatedSprite2D = _playerPrefab.instantiate()
	player.name = "Player";
	_cont_showOnZoom.add_child(player);
	player.Initialise(_mapGen, _cam, _message, self.get_path());
	
	Player_Created.emit(player);
