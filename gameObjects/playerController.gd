extends Node2D

enum Direction {
	left=0,
	up=1,
	right=2,
	down=3
}

var actions = []
var blockAction = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actions = []
	blockAction = false
	
func startMove(direction):
	if direction not in actions:
		actions.append(direction)
		
func stopMove(direction):
	if direction in actions:
		actions.erase(direction)
	if len(actions) < 1:
		blockAction = false
	
func doAction(actions):
	if len(actions) < 1:
		return
	if blockAction:
		return
	blockAction = true
	var action = actions[0]
	
	if action == Direction.up:
		position.y -= 32
	if action == Direction.down:
		position.y += 32
	if action == Direction.left:
		position.x -= 32
	if action == Direction.right:
		position.x += 32

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	doAction(actions)
	
func _input(event):
	if event.is_action_pressed("left"):
		startMove(Direction.left)
	if event.is_action_pressed("right"):
		startMove(Direction.right)
	if event.is_action_pressed("up"):
		startMove(Direction.up)
	if event.is_action_pressed("down"):
		startMove(Direction.down)
	if event.is_action_released("left"):
		stopMove(Direction.left)
	if event.is_action_released("right"):
		stopMove(Direction.right)
	if event.is_action_released("up"):
		stopMove(Direction.up)
	if event.is_action_released("down"):
		stopMove(Direction.down)
