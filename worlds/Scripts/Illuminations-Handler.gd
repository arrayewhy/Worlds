extends CanvasLayer;

@onready var illumFader:Node = $"Illumination-Fader";
@onready var blackBars:Node2D = $"Black-Bars";

var showing:bool;

func _ready() -> void:
	Hide_CanvLayer();

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Enter"):
		if !showing:
			showing = true;
			Show_Illums();
			return;
		else:
			showing = false;
			Hide_Illums();
		
func Show_Illums() -> void:
	if !visible:
		show();
	illumFader.FadeToOpaque(.5);
	blackBars.Show();
	blackBars.HideDone.connect(Hide_CanvLayer);
	
func Hide_Illums() -> void:
	illumFader.FadeToTrans(8);
	blackBars.Hide();

func Hide_CanvLayer() -> void:
	self.hide();
