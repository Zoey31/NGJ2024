extends Node

var currentTurn = 0
signal playerActionSelect(tileMap)
signal onTurnChange(tileMap)
signal onTurnStart(currentTurnIndex)

var gameStarted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerActionSelect.connect(changeTurn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gameStarted == false:
		gameStarted = true
		onTurnStart.emit(currentTurn)

func changeTurn(tileMap):
	onTurnChange.emit(tileMap)
	print("Turn " + str(currentTurn) + " has ended")
	currentTurn += 1
	onTurnStart.emit(currentTurn)
