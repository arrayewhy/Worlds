@icon("res://Misc/icons/envelope_icon_beige.png")
extends Node2D

@onready var _ninePatch:NinePatchRect = $NinePatchRect;
@onready var _panelContainer:PanelContainer = $PanelContainer;
@onready var _label:Label = $PanelContainer/Label;

const _padding:Vector2 = Vector2(128, 2);

@export_category("#DEBUG")
@export var _debug:bool;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	self.modulate.a = 0;
	
	# I can't remember why this is here.
	# Maybe to make sure Resizing works?
	_panelContainer.custom_minimum_size = Vector2(World.CellSize, World.CellSize);


#func _unhandled_key_input(event: InputEvent) -> void:
	#if event.is_action_pressed("Cancel"):
		#_Set_Position_And_Size();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Set_Text(messageText:String, callerPath:String) -> void:
	if _debug: print_debug("\nmessage => Set_Text() called by: ", callerPath);
	_Set_Text(messageText);

func _Set_Text(messageText:String) -> void:
	if messageText.contains("\n"):
		_ninePatch.patch_margin_top = 64 * 2;
		_ninePatch.patch_margin_bottom = 64 * 2;
	else:
		_ninePatch.patch_margin_top = 64;
		_ninePatch.patch_margin_bottom = 64;
	_label.text = messageText;


func Set_Position_And_Size(pos:Vector2, displaceY, callerPath:String) -> void:
	if _debug: print_debug("\nmessage => Set_Position_And_Size() called by: ", callerPath);
	_Set_Position_And_Size(pos, displaceY);

func _Set_Position_And_Size(pos:Vector2, displaceY:float) -> void:
	
	_panelContainer.reset_size();
	if _debug: print_debug(_panelContainer.size);
	self.position = World.Coord_OnGrid(pos) - _panelContainer.size;

	_panelContainer.position = _panelContainer.size / 2;
	
	_ninePatch.size = _panelContainer.size * (1 / _ninePatch.scale.x) + _padding;
	_ninePatch.position = _panelContainer.position - Vector2(_padding.x / 8 / 2, _padding.y * displaceY);
	
	if self.modulate.a <= 0:
		_Appear();


func _Appear() -> void:
	var fade:Fade = Fade.new(Fade.Phase.IN, self, -1, .25);
	self.add_child(fade);

func Disappear(callerPath:String) -> void:
	if _debug: print_debug("\nmessage => Disappear() called by: ", callerPath);
	_Disappear();

func _Disappear() -> void:
	var fade:Fade = Fade.new(Fade.Phase.OUT, self, .25);
	self.add_child(fade);
