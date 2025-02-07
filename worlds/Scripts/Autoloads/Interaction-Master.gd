extends Node;

enum Type {NULL, Dog, Fish, Boat};

func LandInteractions() -> Array[Type]:
	return [Type.Dog];

func WaterInteractions() -> Array[Type]:
	return [Type.Fish, Type.Boat];

func InteractionsWith_IncreasingChance() -> Array[Type]:
	return [Type.Dog, Type.Boat];
