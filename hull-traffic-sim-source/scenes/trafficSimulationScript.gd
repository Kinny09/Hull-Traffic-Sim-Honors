extends Node

## Getting the necessart nodes
@onready var Roads = $"../Roads"
@onready var Buildings = $"../Buildings"

## Member Variables
var tableOfODPairs: Array[ODPair] = []
#var test = null

## Main
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout # Replace this with a proper signal
	
	# Setting up the inital OD pairs
	for residentialBuilding: Dictionary in Buildings["residentialBuildings"].values():
		var originID: String = str(residentialBuilding["accessNode"])
		var origin: Dictionary = Roads["roadNodes"][originID]
		
		for workplaceID in residentialBuilding["workplaces"]:
			var workplace: Dictionary = Buildings["workplaceBuildings"][workplaceID]
			var destinationID: String = str(workplace["accessNode"])
			var destination: Dictionary = Roads["roadNodes"][destinationID]
			var initalNumberOfAgents: int = residentialBuilding["workplaces"][workplaceID]
			var newODPair = ODPair.new(origin, destination)
			newODPair.agentsUsing = initalNumberOfAgents
			tableOfODPairs.append(newODPair)
	
	# Doing the inital pass through of ODPairs and figuring out where they go without factoring in congestion
	for ODPairToPathFindFor in tableOfODPairs:
		var pathFound: Array[Dictionary] = a_star_pathfind(ODPairToPathFindFor)
		ODPairToPathFindFor.routeNodes = pathFound
		add_congestion_to_ways(ODPairToPathFindFor)

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
			var neighbourNode: Dictionary = Roads["roadNodes"][str(neighbourNodeID)]
			
			# Check if the neighbour node has already been calculated
			if neighbourNode in closedList:
				continue
			
			# Checking if congestion should be factored in
			var parentWay: Dictionary = neighbourNode["parentWay"][0]
			var congestion: int = 0
			if factorInCongestion == true:
				congestion = parentWay["congestion"]
			
			# Checking how many parent ways the node has and working out the cost accordingly
			var numberOfParentWays: int = neighbourNode.size()
			if numberOfParentWays <= 2:
				neighbourNode["incrementalCost"] = parentWay["baseMove"] + congestion
				neighbourNode["estimatedDistanceCost"] = neighbourNode["position"].distance_to(destination["position"])
				neighbourNode["totalCost"] = neighbourNode["incrementalCost"] + neighbourNode["estimatedDistanceCost"]
			else:
				neighbourNode["incrementalCost"] = 3 * numberOfParentWays
				neighbourNode["estimatedDistanceCost"] = neighbourNode["position"].distance_to(destination["position"])
				neighbourNode["totalCost"] = neighbourNode["incrementalCost"] + neighbourNode["estimatedDistanceCost"]
			
			var tentativeCost = currentNode["totalCost"] + neighbourNode["totalCost"]
			
			if not neighbourNode in openList:
				openList.append(neighbourNode)
				openList.sort_custom(func(a, b): return a["totalCost"] > b["totalCost"])
				
			elif tentativeCost >= neighbourNode["totalCost"]:
				continue

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

func add_congestion_to_ways(originDestinationPairToAddCongestionTo: ODPair) -> void:
	for node in originDestinationPairToAddCongestionTo.routeNodes:
		for parentWay in node["parentWay"]:
			parentWay["congestion"] += originDestinationPairToAddCongestionTo.agentsUsing






## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
