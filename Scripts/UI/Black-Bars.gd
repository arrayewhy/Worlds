extends Node2D;

@onready var topBar:Sprite2D = $Top;
@onready var btmBar:Sprite2D = $Bottom;
@onready var leftBar:Sprite2D = $Left;
@onready var rightBar:Sprite2D = $Right;

var initTopPos:Vector2;
var initBtmPos:Vector2;
var initLeftPos:Vector2;
var initRightPos:Vector2;

const offset:float = 48;
const speed:float = 100;

var showing:bool;

signal HideDone;

func _ready() -> void:
	
	initTopPos = topBar.position;
	initBtmPos = btmBar.position;
	initLeftPos = leftBar.position;
	initRightPos = rightBar.position;
	
	topBar.position.y -= offset;
	btmBar.position.y += offset;
	leftBar.position.x -= offset;
	rightBar.position.x += offset;
	
	set_process(false);
	
func _process(delta: float) -> void:
	
	if showing:
		Show_Bars(speed * delta);
		if All_Shown():
			#InGameDebugger.Say("Black-Bars: Shown");
			set_process(false);
		return;
	else:
		Hide_Bars(speed * delta);
		if All_Hidden():
			#InGameDebugger.Say("Black-Bars: Hidden");
			HideDone.emit();
			set_process(false);

func Show() -> void:
	showing = true;
	if !is_processing():
		set_process(true);
	
func Hide() -> void:
	showing = false;
	if !is_processing():
		set_process(true);

# Show and Hide Bars

func Show_Bars(change:float) -> void:
	Show_TopBar(change);
	Show_BtmBar(change);
	Show_LeftBar(change);
	Show_RightBar(change);
	
func Hide_Bars(change:float) -> void:
	Hide_TopBar(change);
	Hide_BtmBar(change);
	Hide_LeftBar(change);
	Hide_RightBar(change);

func Show_TopBar(change:float) -> void:
	var next:Vector2 = topBar.position + Vector2(0, change);
	if next.y < initTopPos.y:
		topBar.position = next;
	else:
		topBar.position = initTopPos;

func Hide_TopBar(change:float) -> void:
	var next:Vector2 = topBar.position - Vector2(0, change);
	if next.y > initTopPos.y - offset:
		topBar.position = next;
	else:
		topBar.position.y = initTopPos.y - offset;

func Show_BtmBar(change:float) -> void:
	var next:Vector2 = btmBar.position - Vector2(0, change);
	if next.y > initBtmPos.y:
		btmBar.position = next;
	else:
		btmBar.position = initBtmPos;
		
func Hide_BtmBar(change:float) -> void:
	var next:Vector2 = btmBar.position + Vector2(0, change);
	if next.y < initBtmPos.y + offset:
		btmBar.position = next;
	else:
		btmBar.position.y = initBtmPos.y + offset;

func Show_LeftBar(change:float) -> void:
	var next:Vector2 = leftBar.position + Vector2(change, 0);
	if next.x < initLeftPos.x:
		leftBar.position = next;
	else:
		leftBar.position = initLeftPos;

func Hide_LeftBar(change:float) -> void:
	var next:Vector2 = leftBar.position - Vector2(change, 0);
	if next.x > initLeftPos.x - offset:
		leftBar.position = next;
	else:
		leftBar.position.x = initLeftPos.x - offset;

func Show_RightBar(change:float) -> void:
	var next:Vector2 = rightBar.position - Vector2(change, 0);
	if next.x > initRightPos.x:
		rightBar.position = next;
	else:
		rightBar.position = initRightPos;
		
func Hide_RightBar(change:float) -> void:
	var next:Vector2 = rightBar.position + Vector2(change, 0);
	if next.x < initRightPos.x + offset:
		rightBar.position = next;
	else:
		rightBar.position.x = initRightPos.x + offset;

# Check All Bars

func All_Shown() -> bool:
	return topBar.position.y == initTopPos.y \
	and btmBar.position.y == initBtmPos.y \
	and leftBar.position.x == initLeftPos.x \
	and rightBar.position.x == initRightPos.x;

func All_Hidden() -> bool:
	return topBar.position.y == initTopPos.y - offset \
	and btmBar.position.y == initBtmPos.y + offset \
	and leftBar.position.x == initLeftPos.x - offset \
	and rightBar.position.x == initRightPos.x + offset;
