extends Node2D

## Getting important nodes
@onready var SimulationTimer = $"../../Timer"
@onready var TrafficSimulation = $".."
@onready var CarAsset = $"../CarAsset"

## Member Variables
var arrayOfAgents: Array[Agent] = []
var timetableOfAgents: Dictionary[String, Array]
var tableOfODPairs: Array[ODPair]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await TrafficSimulation.TRAFFIC_SIMULATION_INITALIZATION_COMPLETE # Wait for all the precalculated routes
	
	# Initalizing the table of OD pairs
	tableOfODPairs = TrafficSimulation.tableOfODPairs
	
	# Initalizing the agents and the agent timetable
	for odPair in tableOfODPairs:
		if odPair.routeNodes.size() > 0:
			var pathToTake = odPair.routeNodes.duplicate()
			var odPairWorkTime: String = "%s:%s:%s" % [odPair.workTime.hours, odPair.workTime.minutes, odPair.workTime.seconds]
			var odPairHomeTime: String = "%s:%s:%s" % [odPair.homeTime.hours, odPair.homeTime.minutes, odPair.homeTime.seconds]
		
			for count in odPair.agentsUsing:		
				if pathToTake.duplicate().pop_front() == null:
					print(pathToTake)
				
				if !timetableOfAgents.has(odPairHomeTime):
					timetableOfAgents[odPairHomeTime] = []
					
				var newAgentToHome: UninitalizedAgent = UninitalizedAgent.new(odPair, "car", pathToTake.duplicate())
				timetableOfAgents[odPairHomeTime].append(newAgentToHome)
				#var newAgentToHome: Agent = Agent.new(odPair, CarAsset.duplicate(), "car", pathToTake.duplicate())
				#newAgentToHome.agentAsset.global_position = newAgentToHome.nextNode["position"]
				#timetableOfAgents[odPairHomeTime].append(newAgentToHome)
					
				if !timetableOfAgents.has(odPairWorkTime):
					timetableOfAgents[odPairWorkTime] = []
				
				pathToTake.reverse()
				var newAgentToWork: UninitalizedAgent = UninitalizedAgent.new(odPair, "car", pathToTake.duplicate())
				timetableOfAgents[odPairWorkTime].append(newAgentToWork)
				#var newAgentToWork: Agent = Agent.new(odPair, CarAsset.duplicate(), "car", pathToTake.duplicate())
				#newAgentToWork.agentAsset.global_position = newAgentToWork.nextNode["position"]
				#timetableOfAgents[odPairWorkTime].append(newAgentToWork)

	# Connecting the timer and the updateVisulization function
	SimulationTimer.TIME_CHANGED.connect(updateVisulization)

## The main function that updates all the agents positions and such
func updateVisulization(newTime: Dictionary, timeBetweenUpdates: float):
	# Check that the time is the time the cars should be going
	var newTimeAsString: String = "%s:%s:%s" % [newTime["hour"], newTime["minute"], newTime["second"]]
	
	# Checks the timetable of agents to find if it should spawn new agents
	if timetableOfAgents.has(newTimeAsString):
		for agentToSpawn in timetableOfAgents[newTimeAsString]:
			var spawnedAgent: Agent = Agent.new(agentToSpawn.parentODPair, CarAsset.duplicate(), agentToSpawn.agentType, agentToSpawn.pathToTake.duplicate())
			arrayOfAgents.append(spawnedAgent)
			spawnedAgent.agentAsset.global_position = spawnedAgent.nextNode["position"]
			add_child(spawnedAgent.agentAsset)
			spawnedAgent.agentAsset.visible = true

	# Tells the agents to move
	var arrayOfAgentsToDelete: Array[Agent] = []
	for agent in arrayOfAgents:
		if agent.pathToTake.size() > 0:
			agent.moveAgentToNextNode(timeBetweenUpdates)
		else:
			arrayOfAgentsToDelete.append(agent)
	
	for agentToDelete in arrayOfAgentsToDelete:
		arrayOfAgents.erase(agentToDelete)
		agentToDelete.agentAsset.queue_free()
		agentToDelete.queue_free()
			
			
			
## A class for keeping track of when agents need to be spawned
class UninitalizedAgent:
	var parentODPair: ODPair
	var pathToTake: Array[Dictionary]
	var agentType: String
	
	func _init(_parentODPair: ODPair, _agentType: String, _pathToTake: Array[Dictionary]):
		parentODPair = _parentODPair
		_agentType = _agentType
		pathToTake = _pathToTake
				
## A class representing an Agent
class Agent:
	extends Node2D
	var parentODPair: ODPair
	var pathToTake: Array[Dictionary]
	var nextNode: Dictionary
	var agentAsset: Polygon2D
	var agentType: String
	
	func _init(_parentODPair: ODPair, _agentAsset: Polygon2D, _agentType: String, _pathToTake: Array[Dictionary]):
		parentODPair = _parentODPair
		pathToTake = _pathToTake
		nextNode = pathToTake.pop_front()
		agentAsset = _agentAsset
		agentType = _agentType
		
		agentAsset.rotate(agentAsset.global_position.angle_to_point(nextNode["position"]))
		var rng = RandomNumberGenerator.new()
		var R = rng.randf_range(0.0, 1.0)
		var G = rng.randf_range(0.0, 1.0)
		var B = rng.randf_range(0.0, 1.0)
		agentAsset.color = Color(R, G, B, 1)
		
	func moveAgentToNextNode(timeBetweenUpdates: float):
		var currentPosition: Vector2 = agentAsset.global_position
		var tweener: Tween = agentAsset.get_tree().create_tween()
		var speedLimitOfWay = nextNode["parentWay"][0]["speedLimit"]
		var agentSpeed: float = (speedLimitOfWay / 10)
		
		if currentPosition != nextNode["position"]:
			var positionToMoveTo = currentPosition.move_toward(nextNode["position"], agentSpeed)
			tweener.tween_property(agentAsset, "global_position", positionToMoveTo, timeBetweenUpdates)
			
		elif currentPosition == nextNode["position"]:
			nextNode = pathToTake.pop_front()
			var positionToMoveTo = currentPosition.move_toward(nextNode["position"], agentSpeed)
			tweener.tween_property(agentAsset, "global_position", positionToMoveTo, timeBetweenUpdates)
			var nextNodeAngle: float = currentPosition.angle_to_point(nextNode["position"])
			agentAsset.rotation = nextNodeAngle
