extends Button

@onready var _message:Node2D = get_parent().get_parent();


func _ready() -> void:
	self.button_down.connect(_Click);


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Enter"):
		_message.Disappear(self.get_path());
		_message.Signal_Message_Closed();


func _Click() -> void:
	_message.Disappear(self.get_path());
	_message.Signal_Message_Closed();
