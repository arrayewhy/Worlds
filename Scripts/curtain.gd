extends CanvasLayer

@onready var colRect:ColorRect = $Control/ColorRect;

@onready var curtainTween:Tween = create_tween();

signal Fade_Complete;


func _init() -> void:
	self.show();


func _ready() -> void:
	Reveal(4);


func Reveal(dur:float = 1) -> void:
	
	if !self.visible:
		self.modulate.a = 0;
		return;
	
	if curtainTween.is_running():
		curtainTween.kill();
	
	curtainTween = create_tween();
	curtainTween.set_trans(Tween.TRANS_SINE);
	curtainTween.set_ease(Tween.EASE_IN_OUT);
	curtainTween.tween_property(colRect, "modulate:a", 0, dur);
	
	await curtainTween.finished;
	
	self.hide();


func Obscure(dur:float = 1) -> void:
	
	self.show();
	
	if curtainTween.is_running():
		curtainTween.kill();
	
	curtainTween = create_tween();
	curtainTween.set_trans(Tween.TRANS_SINE);
	curtainTween.set_ease(Tween.EASE_IN_OUT);
	curtainTween.tween_property(colRect, "modulate:a", 1, dur);
	
	await curtainTween.finished;
	
	Fade_Complete.emit();
