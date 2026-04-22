extends Control

## Items Outside Itself
@onready var TrafficVisualization = $"../../../../TrafficSimulation/TrafficVisualization"
@onready var TimerNode = $"../../../../Timer"
@onready var TrafficSimulation = $"../../../../TrafficSimulation"

## Self Items
@onready var MaxNumberOfAgents = $"../MaxNumberOfAgents"

## Member Variables
var agentMaxCounter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await TrafficSimulation.TRAFFIC_SIMULATION_INITALIZATION_COMPLETE # Wait for all the precalculated routes
	TimerNode.TIME_CHANGED.connect(updateCounter)

func updateCounter(_newTime, _secondBeingAdded):
	var currentNumberOfAgents: int = TrafficVisualization.arrayOfAgents.size()
	
	if currentNumberOfAgents > agentMaxCounter:
		agentMaxCounter = currentNumberOfAgents
		MaxNumberOfAgents.text = "Max Number of Agents at Any One Time\n%s" % [currentNumberOfAgents]
