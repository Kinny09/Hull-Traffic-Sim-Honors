extends Node

@onready var Roads = $"../Roads"
@onready var Buildings = $"../Buildings"

## Member Variables
var tableOfODPairs: Array[ODPair] = []
var test = null

## Main function
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
			
	for ODPairToPathFindFor in tableOfODPairs:
		var pathFound: Array = A_Star_Pathfind(ODPairToPathFindFor)
		ODPairToPathFindFor.routeNodes = pathFound




## Finds the best path for the ODPair given to it
func A_Star_Pathfind(originDestinationPair: ODPair) -> Array:
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
			return reconstruct_A_Star_Path(currentNode)
			
		# Add the current node to the closed list
		closedList.append(currentNode)
		
		# Check all the neighbouring nodes and add them to the open list in cost order
		for neighbourNodeID in currentNode["adjacentNodes"]:
			var neighbourNode: Dictionary = Roads["roadNodes"][str(neighbourNodeID)]
			
			# Check if the neighbour node has already been calculated
			if neighbourNode in closedList:
				continue
			
			# Checking how many parent ways the node has and working out the cost accordingly
			var numberOfParentWays: int = neighbourNode.size()
			if numberOfParentWays <= 2:
				var parentWay: Dictionary = neighbourNode["parentWay"][0]
				neighbourNode["incrementalCost"] = parentWay["baseMove"] + parentWay["congestion"]
				neighbourNode["estimatedDistanceCost"] = neighbourNode["position"].distance_to(destination["position"])
				neighbourNode["totalCost"] = neighbourNode["incrementalCost"] + neighbourNode["estimatedDistanceCost"]
			else:
				neighbourNode["incrementalCost"] = 3 * numberOfParentWays
				neighbourNode["estimatedDistanceCost"] = neighbourNode["position"].distance_to(destination["position"])
				neighbourNode["totalCost"] = neighbourNode["incrementalCost"] + neighbourNode["estimatedDistanceCost"]
			
			var tentativeCost = currentNode["totalCost"] + neighbourNode["totalCost"]
			
			if not neighbourNode in openList:
				openList.append(neighbourNode)
			elif tentativeCost >= neighbourNode["totalCost"]:
				continue
		
			neighbourNode["parentNode"] = currentNode
	return []

func reconstruct_A_Star_Path(currentNode: Dictionary) -> Array:
	var path: Array[Dictionary] = []
	
	var nodeWorkingBackFrom = currentNode
	while nodeWorkingBackFrom != null:
		path.append(nodeWorkingBackFrom)
		nodeWorkingBackFrom = nodeWorkingBackFrom["parentNode"]
		
	return path








## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
