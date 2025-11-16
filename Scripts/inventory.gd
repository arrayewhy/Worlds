extends CanvasLayer

@export var _mouse:Node2D;

var _size:int = 1;

var _open:bool;

@export_group("#DEBUG")
@export var _debug:bool;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func _ready() -> void:
	self.hide();
	_mouse.Left_Click.connect(_On_Click);


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory"):
		if !_open:
			_Open();
		else:
			_Close();


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _On_Click(mouse_coord:Vector2) -> void:
	
	# On Left Click near the player, Show inventory
	
	if World.Distance_From_Player(mouse_coord) <= World.CellSize / 2:
		if !_open:
			_Open();
	
	# If Far from the player, Hide inventory
	
	elif World.Distance_From_Player(mouse_coord) > World.CellSize:
		if _open:
			_Close();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Open(callerPath:String) -> void:
	_Open();
	if _debug: print_debug("\ninventory.gd - Open, called by: ", callerPath);

func _Open() -> void:
	_open = true;
	$slot_holder.position = World.Player_Coord() + Vector2.UP * World.CellSize;
	self.show();


func Close(callerPath:String) -> void:
	_Close();
	if _debug: print_debug("\ninventory.gd - Close, called by: ", callerPath);

func _Close() -> void:
	_open = false;
	self.hide();
