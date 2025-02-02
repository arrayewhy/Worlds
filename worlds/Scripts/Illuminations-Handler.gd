extends CanvasLayer;

@onready var illumFader:Node = $"Illumination-Fader";
@onready var blackBars:Node2D = $"Black-Bars";

var showing:bool;

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Enter"):
		if !showing:
			showing = true;
			Show();
			return;
		showing = false;
		Hide();
		
func Show() -> void:
	illumFader.FadeToOpaque(.5);
	blackBars.Show();
	
func Hide() -> void:
	illumFader.FadeToTrans(8);
	blackBars.Hide();
