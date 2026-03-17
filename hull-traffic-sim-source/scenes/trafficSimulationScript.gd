extends Node

## Getting the necessary nodes
@onready var Roads = $"../Roads"
@onready var Buildings = $"../Buildings"

## Member Variables 
var tableOfODPairs: Array[ODPair] = []
var thread: Thread
var progressCount: int = 0

## Signals
signal TRAFFIC_SIMULATION_INITALIZATION_COMPLETE

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	await Buildings.BUILDINGS_POPULATED # Waits for the buildings to be populated
	
	# Setting up the inital OD pairs
	for residentialBuilding: Dictionary in Roads["residentialBuildings"].values():
		var originID = residentialBuilding["accessNode"]
		var origin: Dictionary = Roads["roadNodes"][originID]
		residentialBuilding["originDestinationPairs"] = []
		
		for workplaceID in residentialBuilding["workplaces"]:
			var workplace: Dictionary = Roads["workplaceBuildings"][int(workplaceID)]
			var destinationID: String = str(workplace["accessNode"])
			var destination: Dictionary = Roads["roadNodes"][int(destinationID)]
			var initalNumberOfAgents: int = residentialBuilding["workplaces"][workplaceID]
			
			var rng = RandomNumberGenerator.new()
			var randomMinuteOffset = rng.randi_range(0, 10)
			var workTime = TimeOnly.new(6,49 + randomMinuteOffset,0)
			var homeTime = TimeOnly.new(7,30 + randomMinuteOffset,0)
			var newODPair = ODPair.new(origin, destination, workTime, homeTime)
			newODPair.agentsUsing = initalNumberOfAgents
			tableOfODPairs.append(newODPair)
			residentialBuilding["originDestinationPairs"].append(newODPair)
	
	#Finding the path each OD pair takes and adding congestion to it	
	thread = Thread.new()
	thread.start(initalize_the_paths_thread.bind())
	
# -----------------------------------------------------------------------------------------------------------------------------------------------------
# Thread Stuff
# -----------------------------------------------------------------------------------------------------------------------------------------------------

func initalize_the_paths_thread():
	#var count: int = 0
	for ODPairToPathFindFor in tableOfODPairs:
		var pathFound = a_star_pathfind(ODPairToPathFindFor, true) 
		if pathFound.size() > 0:
			ODPairToPathFindFor.routeNodes = pathFound
			add_congestion_to_ways(ODPairToPathFindFor)
		elif pathFound.size() <= 0:
			ODPairToPathFindFor.routeNodes = pathFound
		progressCount += 1
	call_thread_safe("finished_simulation_initilization")

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	thread.wait_to_finish()
	
func finished_simulation_initilization():
	TRAFFIC_SIMULATION_INITALIZATION_COMPLETE.emit()

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------------------------------------------------------------------------------

## Finds the best path for the ODPair given to it via the A* method, also accepts a secondary bool value that tells the function if it should factor in congestion or not
func a_star_pathfind(originDestinationPair: ODPair, factorInCongestion: bool = false) -> Array:
	# Creating the important variables for later
	var origin: Dictionary = originDestinationPair.origin
	var destination: Dictionary = originDestinationPair.destination
	var openList: Array[Dictionary] = [origin]
	var closedList: Array[Dictionary] = []
	
	# Setting information up for the inital node
	origin["incrementalCost"] = 0
	origin["estimatedDistanceCost"] = origin["position"].distance_to(destination["position"])
	origin["totalCost"] = origin["incrementalCost"] + origin["estimatedDistanceCost"]
	origin["parentNode"] = null
	
	# Continue searching until the openlist is empty
	while not openList.is_empty():
		# Remove the cheapest node from the open list and set it as the current node (OpenList is ordered by cost)
		var currentNode: Dictionary = openList.pop_front()
		
		# Checking if the current node is the destination
		if currentNode == destination:
			return reconstruct_a_star_path(currentNode)
			
		# Add the current node to the closed list
		closedList.append(currentNode)
		
		# Check all the neighbouring nodes and add them to the open list in cost order
		for neighbourNodeID in currentNode["adjacentNodes"]:
			var neighbourNode: Dictionary = Roads["roadNodes"][int(neighbourNodeID)]
			
			# Check if the neighbour node has already been calculated
			if neighbourNode in closedList:
				continue
			
			# Checking if congestion should be factored in
			var parentWay: Dictionary = neighbourNode["parentWay"][0]
			var congestion: float = 0
			if factorInCongestion == true:
				congestion = (float(parentWay["congestion"]) / float(parentWay["wayCapacity"])) * 20
			
			# Checking how many parent ways the node has and working out the cost accordingly
			var numberOfParentWays: int = neighbourNode.size()
			if numberOfParentWays <= 2:
				neighbourNode["incrementalCost"] = parentWay["baseMove"] + congestion
				neighbourNode["estimatedDistanceCost"] = neighbourNode["position"].distance_to(destination["position"])
				neighbourNode["totalCost"] = neighbourNode["incrementalCost"] + neighbourNode["estimatedDistanceCost"]
			
			else:
				neighbourNode["incrementalCost"] = 3 * numberOfParentWays + congestion
				neighbourNode["estimatedDistanceCost"] = neighbourNode["position"].distance_to(destination["position"])
				neighbourNode["totalCost"] = neighbourNode["incrementalCost"] + neighbourNode["estimatedDistanceCost"]
			
			var tentativeCost = currentNode["totalCost"] + neighbourNode["totalCost"]
			
			if not neighbourNode in openList:
				neighbourNode["parentNode"] = currentNode
				openList.append(neighbourNode)
				
			elif tentativeCost >= neighbourNode["totalCost"]:
				continue
			
			openList.sort_custom(func(a, b): return a["totalCost"] < b["totalCost"])
			neighbourNode["parentNode"] = currentNode
	return []

## Reconstructs the A* path
func reconstruct_a_star_path(currentNode: Dictionary) -> Array[Dictionary]:
	var path: Array[Dictionary] = []
	
	var nodeWorkingBackFrom = currentNode
	while nodeWorkingBackFrom != null:
		path.append(nodeWorkingBackFrom)
		nodeWorkingBackFrom = nodeWorkingBackFrom["parentNode"]

	return path

## Adds the congestion to the ways it travels on
func add_congestion_to_ways(originDestinationPairToAddCongestionTo: ODPair) -> void:
	for node in originDestinationPairToAddCongestionTo.routeNodes:
		for parentWay in node["parentWay"]:
			var numberOfLanesOnOneSide = parentWay["lanes"] / 2
			
			if numberOfLanesOnOneSide == 0:
				parentWay["congestion"] += originDestinationPairToAddCongestionTo.agentsUsing
				
			else:
				parentWay["congestion"] += originDestinationPairToAddCongestionTo.agentsUsing / numberOfLanesOnOneSide

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
