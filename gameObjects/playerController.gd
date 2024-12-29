extends Node2D

enum Direction {
	left=0,
	up=1,
	right=2,
	down=3
}

@export var tilemap: TileMapLayer

@onready var sprite := $AnimatedSprite2D
@onready var pointsLabel := $Camera2D/UI/RichTextLabel
@onready var turnManager := get_node("/root/TurnManager")

signal ShootRay()

var actions = []
var blockAction := true
var digging := false
var lookDir := Direction.right
var isAlive := true
var isRockInfrontOfMe := false

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
	return tilemap.local_to_map(globalPosition)
	
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
	
	turnManager.onGravityCheck.connect(onGravityCheck)
	turnManager.onTurnStart.connect(unblockActions)
	ShootRay.connect(isNextCellOccupied)

func unblockActions(turnIndex):
	blockAction = false
	if digging:
		digging = false
		
		# sprite.stop()
		# tilemap.erase_cell(nextPosition)

func startMove(direction):
	if direction not in actions:
		actions.append(direction)
		sprite.play("move")
		lookDir = direction
		
func stopMove(direction):
	if direction in actions:
		actions.erase(direction)
		sprite.play("dig")
	
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
	if blockAction:
		return
		
	if isFalling():
		blockAction = true
		turnManager.playerActionSelect.emit(tilemap)
		return
		
	var possibleActions = getPossibleActions()
	if len(possibleActions) < 1:
		return
	
	var action = possibleActions[0]
	var nextPosition = getNextPosition(action)
	var nextCellData: TileData = tilemap.get_cell_tile_data(nextPosition)

		
	
	if not nextCellData or nextCellData.get_custom_data("empty"):
		blockAction = true
		
		position = position + getTransformVector(action)
		
		turnManager.playerActionSelect.emit(tilemap)
		isRockInfrontOfMe = isNextCellOccupied()
	
	prints("isRockInfrontOfMe", isRockInfrontOfMe)
	if isRockInfrontOfMe:
		var target = $RayCast2D.get_collider()
		print(target.name)
		if sprite.flip_h:
			target.get_parent().global_position -= Vector2(32,0)
		else:
			target.get_parent().global_position += Vector2(32,0)
		
	if nextCellData and nextCellData.get_custom_data("destructable"):
		startDigging(nextPosition)
	
	
	#if nextCellData and isNextCellOccupied(nextPosition):
		#pass

func onGravityCheck(tileMap):
	if not isFalling():
		return
	var action = Direction.down
	var nextPosition = getNextPosition(action)
	var nextCellData: TileData = tileMap.get_cell_tile_data(nextPosition)
	if not nextCellData or nextCellData.get_custom_data("empty"):
		position = position + getTransformVector(action)

func  _updateSprite():
	if sprite == null:
		return
	
	sprite.flip_h = lookDir == Direction.left

func _updateRayCast():
	if sprite == null:
		return
	
	if sprite.flip_h:
		$RayCast2D.position = Vector2(-18,0)
		$RayCast2D.target_position = Vector2(-20,0)
	else:
		$RayCast2D.position = Vector2(18,0)
		$RayCast2D.target_position = Vector2(20,0)
	
func startDigging(cellPos: Vector2i):
	digging = true
	sprite.animation_finished.connect(finishDigging.bind([cellPos]))
	sprite.play("dig")
	$DigSound.play()

	# fajnie by było dać to po animacji ale nie działa :(
	tilemap.erase_cell(cellPos)

func finishDigging(cellPos: Vector2i):
	digging = false
	tilemap.erase_cell(cellPos)
	sprite.stop()
	
func isNextCellOccupied():
	if $RayCast2D.get_collider():
		return true
	else:
		return false
	prints("isOccupied = ", isRockInfrontOfMe)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_updateSprite()
	_updateRayCast()
	doAction(actions)
	
func _input(event):
	if not isAlive:
		return
	#TODO: zrobić jakoś żeby trzymanie nie działało
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

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("AreaPlayer in!", area.position, " My pos is", position)
	if not isRockInfrontOfMe:
		print("Got crashed!")
		actions = []
		isAlive = false
	
