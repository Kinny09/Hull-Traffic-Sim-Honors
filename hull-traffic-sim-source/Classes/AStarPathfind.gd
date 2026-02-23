## Defining the class name
class_name AStarPathfinder extends RefCounted

# Member Variables

# Constructor
#func _init():

## Finds the best path for the ODPair given to it
func A_Star_Pathfind(originDestinationPair: ODPair) -> void:
	# Creating the important variables for later
	var origin: Dictionary = originDestinationPair.origin
	var destination: Dictionary = originDestinationPair.destination
	var openList: Array[Dictionary] = [origin]
	var closedList: Array[Dictionary] = []
	
	# Continue searching until the openlist is empty
	while not openList.is_empty():
		


func findLowestMoveCost()

## The inner node class used by the AStar algorithm to search the network
class AStarNode:
	var cost: int
	var cost
