extends Node;

var debugCanvLay:CanvasLayer;
var overlays:Array;
var textSize:int = 20;

var active:bool = false;

func _ready() -> void:
	
	# Init Canvas Layer
	debugCanvLay = CanvasLayer.new();
	add_child(debugCanvLay);
	debugCanvLay.layer = 1000;
	
	# General Overlay: 0
	AddRichTextLabel();
	
	debugCanvLay.hide();

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Tilde"):
		active = !active;
		debugCanvLay.set_visible(!debugCanvLay.is_visible());

func Add_Text(overlayIndex:int, val:String, withTime:bool = false) -> void:
	
	if !active:
		return;
	
	var currOverlay = GetOverlay(overlayIndex);
	
	var text = val;
	
	# Add Timestamp
	if withTime:
		text = str("[bgcolor='white'][color='black']", Time.get_ticks_msec(), " : ", '[/color][/bgcolor]') + text;

	# Force New Line on Empty RichTextLabel
	if currOverlay.text != "":
		currOverlay.text = str(currOverlay.text, "\n", text);
		return;
	currOverlay.text = text;

func Whisper(val, withTime:bool = false) -> void:
	Add_Text(0, str("[bgcolor='gray'][color='white']", str(val), '[/color][/bgcolor]'), withTime);

func Say(val, withTime:bool = false) -> void:
	Add_Text(0, str("[bgcolor='black'][color='white']", str(val), '[/color][/bgcolor]'), withTime);

func Warn(val, withTime:bool = false) -> void:
	Add_Text(0, str("[bgcolor='Firebrick'][color='white']", str(val), '[/color][/bgcolor]'), withTime);

func Scream(val, withTime:bool = false) -> void:
	Add_Text(0, str("[bgcolor='red'][color='yellow']", str(val), '[/color][/bgcolor]'), withTime);

# Initialisation

func AddRichTextLabel() -> void:
	
	var newLabel:RichTextLabel = RichTextLabel.new();
	debugCanvLay.add_child(newLabel);
	
	newLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE;
	newLabel.bbcode_enabled = true;
	newLabel.clip_contents = false;
	newLabel.scroll_following = true;
	newLabel.set_anchors_preset(Control.PRESET_FULL_RECT, true);
	newLabel.add_theme_font_size_override("normal_font_size", textSize);
	
	# Add to Overlay Array
	overlays.push_back(newLabel);
	
func GetOverlay(overlayIndex:int) -> RichTextLabel:
	
	for i in overlays.size():
		if i == overlayIndex:
			return overlays[i];
	
	print(str('Debug Overlay "', overlayIndex, '" NOT found.'));
	return RichTextLabel.new();
