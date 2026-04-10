extends CanvasLayer

enum SCENE_NAME { NULL, House_Interior }
const Scenes:Dictionary[SCENE_NAME, PackedScene] = {
	SCENE_NAME.House_Interior : preload("res://Scenes/House_Interior.tscn"),
};

@onready var _curtain:ColorRect = $"Curtain";

var _start_dark:bool = true;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	# Determine if the Scene should Start
	# Dark or Bright.
	if _start_dark:
		self.show();
		_curtain.show();
		_curtain.color = Color.BLACK;
	else:
		self.hide();
		_curtain.hide();
		_curtain.color = Color.TRANSPARENT;
		
	# Reveal Scene on Start
	if self.visible && _curtain.color.a == 1:
		_Show_Scene();


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Cancel"):
		_Quit_Sequence();


# Public Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Change_Scene(scene_name:SCENE_NAME, caller_path:String) -> void:
	print("Change_Scene called by: ", caller_path);
	await _Hide_Scene();
	get_tree().change_scene_to_packed(Scenes[scene_name]);
	_Show_Scene();


# Level ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Quit_Sequence() -> void:
	
	# We use a Timer here because it lets us Stop the timer and
	# Cancel the Quit sequence if we want to.
	var timer:Timer = Timer.new()
	self.add_child(timer);
	timer.one_shot = true;
	timer.start(1);
	
	while timer.time_left > 0:
		if Input.is_action_just_released("Cancel"):
			timer.stop();
			return;
		await get_tree().process_frame;
	
	await _Hide_Scene();
	_Quit();

func _Quit() -> void:
	get_tree().quit();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Hide_Scene() -> void:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_SINE);
	tween.set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(_curtain, "modulate:a", 1, 2);
	await tween.finished;

func _Show_Scene() -> void:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_SINE);
	tween.set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(_curtain, "modulate:a", 0, 4);
	await tween.finished;
