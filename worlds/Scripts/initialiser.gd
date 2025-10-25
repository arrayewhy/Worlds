extends Node

@onready var _playerPrefab:PackedScene = preload("res://Prefabs/player.tscn");

@export var _mapGen:Node2D;
@export var _cont_showOnZoom:Node2D;

@export var _cam:Camera2D;
@export var _message:Node2D;

signal Player_Created(player:AnimatedSprite2D);


func _ready() -> void:
	
	_mapGen.Generate_Map(2989861102, self.get_path());
	
	_mapGen.Map_Generated.connect(_Create_Player);


func _Create_Player() -> void:
	
	var player:AnimatedSprite2D = _playerPrefab.instantiate()
	_cont_showOnZoom.add_child(player);
	player.Initialise(_mapGen, _cam, _message);
	
	Player_Created.emit(player);
