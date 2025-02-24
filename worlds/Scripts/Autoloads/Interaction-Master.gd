extends Node;

enum Type {NULL, Dog, Forest, Fish, Boat};

func LandInteractions() -> Array[Type]:
	return [Type.Dog, Type.Forest];

func WaterInteractions() -> Array[Type]:
	return [Type.Fish, Type.Boat];

func InteractionsWith_IncreasingChance() -> Array[Type]:
	return [Type.Dog, Type.Boat];
