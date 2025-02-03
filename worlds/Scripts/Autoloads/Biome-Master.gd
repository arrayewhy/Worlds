extends Node;

enum Type {NULL, Earth, Grass, Water};

func RandomBiomeType() -> int:
	# Return an Int instead of a Type since this is faster.
	# If this doesn't suffice, do a Match and return the appropriate Type.
	return randi_range(1, Type.keys().size() - 1);
