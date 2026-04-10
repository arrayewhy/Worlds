extends CanvasLayer

@onready var _mouse:Node2D = $"../mouse";

var _open:bool;

var _alpha_tween:Tween;

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
	if World.PLAYER_COORD.distance_to(mouse_coord) <= World.CellSize / 2:
		if !_open:
			_Open();
	
	# If Far from the player, Hide inventory
	elif World.PLAYER_COORD.distance_to(mouse_coord) > World.CellSize:
		if _open:
			_Close();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Open(callerPath:String) -> void:
	_Open();
	if _debug: print_debug("\ninventory.gd - Open, called by: ", callerPath);

func _Open() -> void:
	
	_open = true;
	
	$slot_holder.position = World.PLAYER_COORD + Vector2.UP * World.CellSize;
	
	$slot_holder.modulate.a = 0;
	
	if _alpha_tween != null && _alpha_tween.is_running():
		_alpha_tween.kill();
	
	_alpha_tween = create_tween();
	_alpha_tween.tween_property($slot_holder, "modulate:a", 1, .2);
	
	self.show();


func Close(callerPath:String) -> void:
	_Close();
	if _debug: print_debug("\ninventory.gd - Close, called by: ", callerPath);

func _Close() -> void:
	_open = false;
	
	if _alpha_tween != null && _alpha_tween.is_running():
		_alpha_tween.kill();
	
	_alpha_tween = create_tween();
	_alpha_tween.tween_property($slot_holder, "modulate:a", 0, .2);
	
	await _alpha_tween.finished;
	
	self.hide();
