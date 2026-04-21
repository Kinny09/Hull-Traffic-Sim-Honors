extends Control

## Items Outside Itself
@onready var TrafficVisualization = $"../../../../TrafficSimulation/TrafficVisualization"
@onready var TimerNode = $"../../../../Timer"
@onready var TrafficSimulation = $"../../../../TrafficSimulation"

## Self Items
@onready var NumberOfAgentsLabel = $"../VListBox/NumberOfAgentsLabel"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await TrafficSimulation.TRAFFIC_SIMULATION_INITALIZATION_COMPLETE # Wait for all the precalculated routes
	TimerNode.TIME_CHANGED.connect(updateNumberOfAgents)
	pass # Replace with function body.

func updateNumberOfAgents(_newTime, _secondBeingAdded):
	NumberOfAgentsLabel.text = str(TrafficVisualization.arrayOfAgents.size())
