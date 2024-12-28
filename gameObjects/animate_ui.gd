extends RichTextLabel

var posOffset = 64
var startPos = Vector2(0,0)
var isToggled = false
var distance = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startPos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isToggled == true:
		var value = Vector2(0, posOffset) * delta
		position += value
		distance += value.y
	
	if isToggled == false && distance >= 0:
		var value = Vector2(0, posOffset) * delta
		position -= Vector2(0, posOffset) * delta
		distance -= value.y
