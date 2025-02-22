class_name Biome_Master extends Node;

enum Type {NULL, Earth, Grass, Water};

static func RandomBiomeType() -> int:
	# Return an Int instead of a Type since this is faster.
	# If this doesn't suffice, do a Match and return the appropriate Type as a String.
	return randi_range(1, Type.keys().size() - 1);
