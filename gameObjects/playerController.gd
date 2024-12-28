extends Node2D

enum Direction {
	left=0,
	up=1,
	right=2,
	down=3
}

var actions = []
var blockAction = true
@export var tilemap: TileMapLayer
var turnManager
@onready var pointsLabel = $Camera2D/UI/RichTextLabel

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
	blockAction = true
	print("ready player")
	turnManager = get_node("/root/TurnManager")
	turnManager.onGravityCheck.connect(onGravityCheck)
	turnManager.onTurnStart.connect(unblockActions)

func unblockActions(turnIndex):
	blockAction = false

func startMove(direction):
	if direction not in actions:
		actions.append(direction)
		
func stopMove(direction):
	if direction in actions:
		actions.erase(direction)
	
func getPossibleActions():
	var current = getCurrentPosition()
	var currentCellData: TileData = tilemap.get_cell_tile_data(current)
	var result = []
	
	for action in actions:
		if action == Direction.left or action == Direction.right:
			var positionUnderPlayer = getNextPosition(Direction.down)
			var positionUnderCellData: TileData = tilemap.get_cell_tile_data(positionUnderPlayer)
			if currentCellData and currentCellData.get_custom_data("verticalMoving") \
			 or (not currentCellData or currentCellData.get_custom_data("empty")) \
			 and positionUnderCellData and not positionUnderCellData.get_custom_data("empty"):
				result.append(action)
		if action == Direction.up:
			var nextPosition = getNextPosition(action)
			var nextCellData: TileData = tilemap.get_cell_tile_data(nextPosition)
			if currentCellData and currentCellData.get_custom_data("verticalMoving") \
			 and nextCellData and nextCellData.get_custom_data("verticalMoving"):
				result.append(action)
			
		if action == Direction.down:
			if currentCellData and currentCellData.get_custom_data("verticalMoving"):
				result.append(action)

	
	return result
	
func isFalling():
	var current = getCurrentPosition()
	var currentCellData: TileData = tilemap.get_cell_tile_data(current)
	
	var positionUnderPlayer = getNextPosition(Direction.down)
	var positionUnderCellData: TileData = tilemap.get_cell_tile_data(positionUnderPlayer)
	
	if currentCellData and currentCellData.get_custom_data("verticalMoving"):
		return false
	
	if not positionUnderCellData:
		return true
	
		
	return positionUnderCellData.get_custom_data("empty")
	
func doAction(actions):
	var possibleActions = getPossibleActions()
	if blockAction:
		return
		
	if isFalling():
		blockAction = true
		turnManager.playerActionSelect.emit(tilemap)
		return
		
	if len(possibleActions) < 1:
		return
	
	
	var current = getCurrentPosition()
	var action = possibleActions[0]
	var nextPosition = getNextPosition(action)
	var nextCellData: TileData = tilemap.get_cell_tile_data(nextPosition)
	if not nextCellData or nextCellData.get_custom_data("empty"):
		blockAction = true
		position = position + getTransformVector(action)
		turnManager.playerActionSelect.emit(tilemap)
		return


func onGravityCheck(tileMap):
	if not isFalling():
		return
	var action = Direction.down
	var nextPosition = getNextPosition(action)
	var nextCellData: TileData = tileMap.get_cell_tile_data(nextPosition)
	if not nextCellData or nextCellData.get_custom_data("empty"):
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


func _on_button_pressed() -> void:
	print("kliklem")
	pointsLabel.isToggled = true
	await get_tree().create_timer(1.5).timeout
	pointsLabel.isToggled = false
	print("odklikuje")
