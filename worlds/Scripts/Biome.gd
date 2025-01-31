extends Node;

enum Type {NULL, Earth, Grass};

@onready var earthBiome:PackedScene = preload("res://Prefabs/Earth-Biome.tscn");
@onready var grassBiome:PackedScene = preload("res://Prefabs/Grass-Biome.tscn");

func Get_BiomePrefab(type:Type) -> PackedScene:
	
	match type:
		Type.Earth:
			return earthBiome;
		Type.Grass:
			return grassBiome;
			
	InGameDebugger.Warn("Failed to get Biome.");
	return null;
