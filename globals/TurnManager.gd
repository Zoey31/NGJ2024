extends Node

var currentTurn = 0
signal playerActionSelect(tileMap)
signal playerRayCast()
signal onTurnChange(tileMap)
signal onGravityCheck(tileMap)
signal onTurnStart(currentTurnIndex)

var gameStarted: bool = false
var counter = 0
var timeToSleep = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("_ready TimeManager")
	playerActionSelect.connect(changeTurn)
	counter = timeToSleep


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if counter < timeToSleep:
		counter += delta
	if gameStarted == false and counter >= timeToSleep:
		print("start turn: " + str(counter))
		gameStarted = true
		
		onTurnStart.emit(currentTurn)

func changeTurn(tileMap):
	onTurnChange.emit(tileMap)
	onGravityCheck.emit(tileMap)
	print("Turn " + str(currentTurn) + " has ended")
	currentTurn += 1
	gameStarted = false
	counter = 0
