extends Node2D

enum Direction {
	left=0,
	up=1,
	right=2,
	down=3
}

var actions = []
var blockAction = false
@export var tilemap: TileMapLayer

func getTransformVector(direction):
	var result = Vector2(0, 0)
	if direction == Direction.up:
		result.y -= tilemap.tile_set.tile_size.y
	if direction == Direction.down:
		result.y += tilemap.tile_set.tile_size.y
	if direction == Direction.left:
		result.x -= tilemap.tile_set.tile_size.x
	if direction == Direction.right:
		result.x += tilemap.tile_set.tile_size.x
		
	return result
	
func getTilemapPosition(globalPosition):
	var result = tilemap.local_to_map(globalPosition)
		
	return result
	
func getCurrentPosition():
	return getTilemapPosition(position)

func getNextPosition(direction):
	var nextPositionGlobal = position + getTransformVector(direction)
	
	return getTilemapPosition(nextPositionGlobal)



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

	var current = getCurrentPosition()
	var nextPosition = getNextPosition(action)
	var nextCellData = tilemap.get_cell_tile_data(nextPosition)
	print("Current: " + str(current))
	print("nextPosition: " + str(nextPosition))
	print("nextCellData: " + str(nextCellData))
	
	if nextCellData and nextCellData.get_custom_data("walkable"):
		position = position + getTransformVector(action)

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
