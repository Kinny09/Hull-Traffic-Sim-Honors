extends Node2D

## Getting important nodes
@onready var SimulationTimer = $"../../Timer"
@onready var TrafficSimulation = $".."
@onready var CarAsset = $"../CarAsset"

## Member Variables
var arrayOfAgents: Array[Agent] = []
var tableOfODPairs: Array[ODPair]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await TrafficSimulation.TRAFFIC_SIMULATION_INITALIZATION_COMPLETE # Wait for all the precalculated routes
	
	# Initalizing the table of OD pairs
	tableOfODPairs = TrafficSimulation.tableOfODPairs
	
	# Initalizing the Agents 
	var totalNumberOfAgents: int = 0
	for odPair in tableOfODPairs:
		if odPair.routeNodes.size() > 0:
			for count in odPair.agentsUsing:
				var newAgent: Agent = Agent.new(odPair, CarAsset.duplicate(true), "car")
				newAgent.agentAsset.global_position = newAgent.nextNode["position"]
				arrayOfAgents.append(newAgent)
				add_child(newAgent.agentAsset)
				newAgent.agentAsset.visible = true
	print(totalNumberOfAgents)
	
	# Connecting the timer and the updateVisulization function
	SimulationTimer.TIME_CHANGED.connect(updateVisulization)

func updateVisulization(_newTime: Dictionary, secondBeingAddedToTime: int):
	for agent in arrayOfAgents:
		if agent.pathToTake.size() > 0:
			agent.moveAgentToNextNode(secondBeingAddedToTime)
		else:
			agent.agentAsset.visible = false
		
		

## A class representing an Agent
class Agent:
	extends Node2D
	var parentODPair: ODPair
	var pathToTake: Array[Dictionary]
	var nextNode: Dictionary
	var agentAsset: Polygon2D
	var agentType: String
	
	func _init(_parentODPair: ODPair, _agentAsset: Polygon2D, _agentType: String):
		parentODPair = _parentODPair
		pathToTake = _parentODPair.routeNodes.duplicate()
		nextNode = pathToTake.pop_back()
		agentAsset = _agentAsset
		agentType = _agentType
		
		agentAsset.rotate(agentAsset.global_position.angle_to_point(nextNode["position"]))
		var rng = RandomNumberGenerator.new()
		var R = rng.randf_range(0.0, 1.0)
		var G = rng.randf_range(0.0, 1.0)
		var B = rng.randf_range(0.0, 1.0)
		agentAsset.color = Color(R, G, B, 1)
		
	func moveAgentToNextNode(speedMultiplier: int):
		var currentPosition: Vector2 = agentAsset.global_position
		var tweener: Tween = agentAsset.get_tree().create_tween()
		var speedLimitOfWay = nextNode["parentWay"][0]["speedLimit"]
		var agentSpeed: float = (speedLimitOfWay / 10) * speedMultiplier
		
		if currentPosition != nextNode["position"]:
			var positionToMoveTo = currentPosition.move_toward(nextNode["position"], agentSpeed)
			tweener.tween_property(agentAsset, "global_position", positionToMoveTo, 1.0)
			
		elif currentPosition == nextNode["position"]:
			nextNode = pathToTake.pop_back()
			var positionToMoveTo = currentPosition.move_toward(nextNode["position"], agentSpeed)
			tweener.tween_property(agentAsset, "global_position", positionToMoveTo, 1.0)
			var nextNodeAngle: float = currentPosition.angle_to_point(nextNode["position"])
			agentAsset.rotation = nextNodeAngle
