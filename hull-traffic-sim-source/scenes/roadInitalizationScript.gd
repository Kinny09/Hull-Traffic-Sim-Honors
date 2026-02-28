extends Node

var roadInfoDictionary: Dictionary[String, Variant] = {
	"speedLimit": 60,
	"nodes": [],
	"oneWay": false,
	"bridge": false,
	"lit": false,
	"trafficCalming": false,
	"pavement": false,
	"bikeLane": false,
	"busLane": false,
	"name": "",
	"id": 0,
	"roadWidth": 0,
	"lanes": 2,
	"globalPosition": Vector2(0,0),
	"baseMovementCost": 0, 
	"congestion": 0,
}

var nodeInfoDictionary: Dictionary[String, Variant] = {
	"type": "node",
	"id": 0,
	"position": Vector2(0,0),
	"adjacentNodes": [],
	"parentWay": [],
}

var roadWays: Dictionary = {}
var roadNodes: Dictionary = {}

@onready var uninitalizedNodes = $"../UninitializedNodes".get_children()
@onready var uninitalizedWays = $"../UninitializedWays".get_children()

func _ready() -> void:	
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	## Initilizing the nodes and roads
	## -----------------------------------------------------------------------------------------------------------------------------------------------------

	# Iterating through each way and initalizing it
	for uninitilizedWay in uninitalizedWays:
		# Setting up important variables
		var newRoad: Dictionary = roadInfoDictionary.duplicate(true)
		var uninitilizedWayID:String = str(uninitilizedWay.name)
		
		
		# Setting up the road info
		for metaName in uninitilizedWay.get_meta_list():
			newRoad[metaName] = uninitilizedWay.get_meta(metaName)
		
		newRoad["id"] = uninitilizedWayID
		
		# Adding the road to the dictionary of roads
		roadWays[uninitilizedWayID] = newRoad
		
		
	# Initializing the nodes
	for uninitilizedNode in uninitalizedNodes:
		# Setting up important variables
		var newNode: Dictionary = nodeInfoDictionary.duplicate(true)
		var uninitilizedNodeID:String = str(uninitilizedNode.name)
		
		# Setting up the node info
		newNode["id"] = uninitilizedNode.name
		newNode["position"] = uninitilizedNode.position

		# Adding the node to the dictionary of nodes
		roadNodes[uninitilizedNodeID] = newNode
	
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	## Setting up the ways and nodes
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	for way in roadWays.values():
		# Calculating the base cost of moving inside this way
		var baseCost: int = 200 / way["speedLimit"] / (way["lanes"] / 2)
		way["baseMovementCost"] = baseCost
		
		# Finding out which nodes are adjacent to which
		for nodeListIndex in way["nodes"].size():
			var nodeID = str(way["nodes"][nodeListIndex])
			
			if nodeListIndex - 1 >= 0 and not way["oneWay"]:
				roadNodes[nodeID]["adjacentNodes"].append(way["nodes"][nodeListIndex - 1])
			
			if nodeListIndex + 1 <= way["nodes"].size() - 1:
				roadNodes[nodeID]["adjacentNodes"].append(way["nodes"][nodeListIndex + 1])
				
			# Setting the parent way pointer
			roadNodes[nodeID]["parentWay"].append(way)
			
			
			
		
		
		
