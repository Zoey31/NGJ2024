extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"/root/TurnManager".onTurnChange.connect(fallAction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func fallAction(tilemap: TileMapLayer):
	print("rock " + name + " has started falling")
	

	var positionsToCheck = [
		position + Vector2.DOWN * tilemap.tile_set.tile_size.y,
		position + 2 * Vector2.DOWN * tilemap.tile_set.tile_size.y,
		position + 3 * Vector2.DOWN * tilemap.tile_set.tile_size.y
	]
	print(positionsToCheck)
	
	var nextPosition = position
	for positionToCheck in positionsToCheck:
		var possibleNextPosition = tilemap.local_to_map(positionToCheck)
		var cellData = tilemap.get_cell_tile_data(possibleNextPosition)
		if cellData and cellData.get_custom_data("walkable") and not cellData.get_custom_data("destructable"):
			nextPosition = positionToCheck
		else:
			break
	position = nextPosition
