extends CanvasLayer

const DEBUG:bool = true;


func _ready() -> void:
	#self.hide();
	if !DEBUG:
		self.queue_free();


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		if !self.visible: self.show();
		else: self.hide();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func LOG(text:String, col:Color = Color.BLACK, print_to_console:bool = true) -> void:
	
	if print_to_console:
		print(text);
	
	for c in get_children().size():
		if c == 0: continue;
		get_child(c).position.y += 35;
	
	var msg:PanelContainer = _Create_Message(text, col);
	self.add_child(msg);
	
	await _Fade(msg, 1, 1);
	await _Fade(msg, 0, 20);
	msg.queue_free();


func _Fade(msg:PanelContainer, targ_alpha:float, dur:float) -> void:
	var tween:Tween = create_tween();
	tween.tween_property(msg, "modulate:a", targ_alpha, dur);
	await tween.finished;


# Create ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Create_Message(text:String, col:Color) -> PanelContainer:
	
	var panel_container:PanelContainer = PanelContainer.new();
	var style:StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = col;
	style.content_margin_top = 5;
	style.content_margin_bottom = 5;
	style.content_margin_left = 10;
	style.content_margin_right = 10;
	panel_container.add_theme_stylebox_override("panel", style);
	
	panel_container.modulate.a = 0;
	
	var label:Label = Label.new();
	label.text = text;
	label.add_theme_color_override("label", Color.WHITE);
	panel_container.add_child(label);
	
	return panel_container;
