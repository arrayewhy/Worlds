extends Sprite2D;

const speed:float = .25;

var limitTop:float;
var limitBtm:float;
var limitLeft:float;
var limitRight:float;

var dir := Vector2(1, 0);

func _ready() -> void:
	set_process(false);
	limitTop = get_parent().limitTop;
	limitBtm = get_parent().limitBtm;
	limitLeft = get_parent().limitLeft;
	limitRight = get_parent().limitRight;

func _process(delta: float) -> void:

	var nextPos = position + dir * speed;
	
	if dir == Vector2(1, 0) and !WithinBounds_X(nextPos.x):
		dir = Vector2(0, 1);
		position = Vector2(limitRight, nextPos.y + speed * delta);
		return;
	if dir == Vector2(0, 1) and !WithinBounds_Y(nextPos.y):
		dir = Vector2(-1, 0);
		position = Vector2(nextPos.x - speed * delta, limitBtm);
		return;
	if dir == Vector2(-1, 0) and !WithinBounds_X(nextPos.x):
		dir = Vector2(0, -1);
		position = Vector2(limitLeft, nextPos.y - speed * delta);
		return;
	if dir == Vector2(0, -1) and !WithinBounds_Y(nextPos.y):
		dir = Vector2(1, 0);
		position = Vector2(nextPos.x + speed * delta, limitTop);
		return;
		
	position = nextPos;

func Start() -> void:
	set_process(true);
	
func Stop() -> void:
	set_process(false);

func WithinBounds_X(x:float) -> bool:
	return x > limitLeft and x < limitRight;
	
func WithinBounds_Y(y:float) -> bool:
	return y > limitTop and y < limitBtm;

func Set_Dir(newDir:Vector2) -> void:
	dir = newDir;
