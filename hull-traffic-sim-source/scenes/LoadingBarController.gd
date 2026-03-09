extends Control

@onready var CounterLabel =  $"../Background/Counter"
@onready var TrafficSimulation = $"../../../../TrafficSimulation"

## Member Variables
var BuildingCount: int = 0
var WorkedThroughCount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("test")
	BuildingCount = TrafficSimulation["tableOfODPairs"].size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	print("test2")
	WorkedThroughCount += 1
	CounterLabel.text = str(WorkedThroughCount) + "/" + str(BuildingCount)
