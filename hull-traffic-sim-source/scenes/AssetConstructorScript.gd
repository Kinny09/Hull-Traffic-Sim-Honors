extends Node

@onready var ImportedData = $"../ImportedData"
@onready var ClickingDetection = $"../ClickingDetection"

## Signal to tell the simulation when all the assets have been constructed
signal ASSETS_CONSTRUCTED()

var roadNodes: Dictionary = {}
var roadWays: Dictionary = {}
var buildingWays: Dictionary = {}
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
	"congestion": 0.0,
	"wayCapacity": 0.0
}
var placeInfoDictionary: Dictionary[String, Variant] = {
	"buildingType": "",
	"buildingID": 0,
	"nodes": [],
	"globalPosition": Vector2(0,0)
}
var residentialInfoDictionary: Dictionary[String, Variant] = {
	"buildingType": "",
	"buildingID": 0,
	"nodes": [],
	"accessRoad": 0,
	"numberOfResidents": 0,
	"workplaces": {},
	"globalPosition": Vector2(0,0)
}
var workplaceInfoDictionary: Dictionary[String, Variant] = {
	"buildingType": "",
	"buildingID": 0,
	"nodes": [],
	"accessRoad": 0,
	"employmentCapacity": 0,
	"numberOfEmployees": 0,
	"globalPosition": Vector2(0,0)
}
var globalRoadPosition = Vector2(0,0)

func _ready() -> void:
	await ImportedData.FINISHED_IMPORTING_DATA # Waiting for the data to be imported before constructing the roads and buildings
	
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	## Loading the Roads
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	# Getting the road node data where it should be
	roadNodes = ImportedData.roadNodeData.duplicate(true)
	
	for way in ImportedData.roadWaysData.values():
		# Setting the ways ID variable
		var wayID: String = str(way["id"])
		
		# Creating the new road asset node
		var newRoad = get_node("../LaneAssets/road").duplicate()
		newRoad.name = wayID
		
		# Setting the tags that need to always be changed from their defaults
		var newRoadInfoDictionary: Dictionary = roadInfoDictionary.duplicate(true)
		roadWays[wayID] = newRoadInfoDictionary
		newRoadInfoDictionary["name"] = wayID
		newRoadInfoDictionary["id"] = wayID
		newRoadInfoDictionary["nodes"] = way["nodes"]
		
		# Sorting the roads tags
		var roadTags = way["tags"]
		
		for tagName in way["tags"]:
			match tagName:
				"name":
					newRoadInfoDictionary["name"] = roadTags["name"]
					
				"maxspeed":
					var speed = roadTags["maxspeed"]
					speed = int(speed.get_slice(" ", 0))
					newRoadInfoDictionary["speedLimit"] = speed
					
				"lanes":
					newRoadInfoDictionary["lanes"] = int(roadTags[tagName])
					
				"oneway":
					newRoadInfoDictionary["oneWay"] = figureOutBoolValueForMetaData(roadTags[tagName])
					
				"bridge":
					newRoadInfoDictionary["bridge"] = figureOutBoolValueForMetaData(roadTags[tagName])
					
				"lit":
					newRoadInfoDictionary["lit"] = figureOutBoolValueForMetaData(roadTags[tagName])
					
				"traffic_calming":
					newRoadInfoDictionary["trafficCalming"] = figureOutBoolValueForMetaData(roadTags[tagName])
				
				"sidewalk", "sidewalk:left", "sidewalk:right" when roadWays[wayID]["pavement"] == false:
					newRoadInfoDictionary["pavement"] = figureOutBoolValueForMetaData(roadTags[tagName])
						
				"cycleway", "cycleway:both", "cycleway:right", "cycleway:left" when roadWays[wayID]["bikeLane"] == false:
					newRoadInfoDictionary["bikeLane"] = figureOutBoolValueForMetaData(roadTags[tagName])
					
				"busway" when roadWays[wayID]["busLane"] == false:
					newRoadInfoDictionary["busLane"] = figureOutBoolValueForMetaData(roadTags[tagName])
		
		# Moving the road to a place near it's real position
		var randomNode = roadNodes[way["nodes"][0]]
		globalRoadPosition = randomNode["position"]
		newRoad.set_global_position(globalRoadPosition)
		newRoadInfoDictionary["globalPosition"] = globalRoadPosition
		
		# Drawing the road
		var totalNumberOfLanes = roadWays[wayID]["lanes"]
		var roadWidth = 0
		var layerNumber = 0
		var isBridge = roadWays[wayID]["bridge"]
		var newLane = null
		
		if totalNumberOfLanes % 2 == 0: # If the number of lanes is even
			# Creating the lane divider
			newLane = get_node("../LaneAssets/car_lane_divider").duplicate()
			laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
			roadWidth = newLane.width
			
			# Creating all the lanes
			for laneNumber in totalNumberOfLanes / 2:
				layerNumber = layerNumber + 1
				newLane = get_node("../LaneAssets/car_lane").duplicate()
				laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
				roadWidth = newLane.width
				
		elif totalNumberOfLanes % 2 == 1: # If the number of lanes is odd
			# Creating the middle lane
			newLane = get_node("../LaneAssets/car_lane").duplicate()
			laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
			roadWidth = newLane.width
			
			# Creating all the lanes
			for laneNumber in totalNumberOfLanes / 2:
				layerNumber = layerNumber + 1
				newLane = get_node("../LaneAssets/car_lane_divider").duplicate()
				laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
				roadWidth = newLane.width
				
				layerNumber = layerNumber + 1
				newLane = get_node("../LaneAssets/car_lane").duplicate()
				laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
				roadWidth = newLane.width
		
		# Creating the Bikelanes if needed
		if roadWays[wayID]["bikeLane"]:
			layerNumber = layerNumber + 1
			newLane = get_node("../LaneAssets/bike_lane").duplicate()
			laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
			roadWidth = newLane.width
				
		# Creating the pavement
		layerNumber = layerNumber + 1
		newLane = get_node("../LaneAssets/pavement").duplicate()
		laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
		roadWidth = newLane.width
		
		# Setting the width of the road
		newRoadInfoDictionary["roadWidth"] = roadWidth
		
		# Adding the road to the roads node		
		add_child(newRoad)	
		
		# Adding way nodes to the nodes list
		var listOfNodesInWay = way["nodes"]
		
		# Creating the click detectors for the roads
		var clickSegmentCount = 0
		
		for nodeIndex in listOfNodesInWay.size():
			if nodeIndex + 1 <= listOfNodesInWay.size() - 1:
				var newClickSegment = CollisionShape2D.new()
				var currentNode = roadNodes[listOfNodesInWay[nodeIndex]]
				var nodeAhead = roadNodes[listOfNodesInWay[nodeIndex + 1]]
				
				var currentNodeVector = currentNode["position"]
				var nodeAheadVector =  nodeAhead["position"]
				
				newClickSegment.shape = RectangleShape2D.new()
				newClickSegment.name = "Roads|"+ str(clickSegmentCount) + "|" + str(newRoad.name)
				newClickSegment.set_global_position((currentNodeVector + nodeAheadVector) / 2)
				clickSegmentCount = clickSegmentCount + 1
				
				newClickSegment.shape.size = Vector2(currentNodeVector.distance_to(nodeAheadVector), roadWidth)
				newClickSegment.rotation = (currentNodeVector.angle_to_point(nodeAheadVector))
				
				ClickingDetection.add_child(newClickSegment)
		
		# Finding nodes that are adjacent to each other and documenting that, also adding the nodes parent
		for nodeIndex in listOfNodesInWay.size():
			var nodeID = listOfNodesInWay[nodeIndex]
			if nodeIndex - 1 >= 0 and not roadWays[wayID]["oneWay"]:
				roadNodes[nodeID]["adjacentNodes"].append(listOfNodesInWay[nodeIndex - 1])
			
			if nodeIndex + 1 <= listOfNodesInWay.size() - 1:
				roadNodes[nodeID]["adjacentNodes"].append(listOfNodesInWay[nodeIndex + 1])
				
			roadNodes[nodeID]["parentWay"].append(roadNodes[nodeID])
			
		# Calculating the base cost of moving inside this way
		var wayCapacity: int = 0
		var baseCost: int = 0
		
		if roadWays[wayID]["lanes"] / 2 != 0:
			wayCapacity = 500 * (roadWays[wayID]["lanes"] / 2) * (roadWays[wayID]["speedLimit"] / 4)
			baseCost = 500 / roadWays[wayID]["speedLimit"] / (roadWays[wayID]["lanes"] / 2)
			
		else:
			wayCapacity = 500 * (roadWays[wayID]["lanes"]) * (roadWays[wayID]["speedLimit"] / 4)
			baseCost = 500 / roadWays[wayID]["speedLimit"] / (roadWays[wayID]["lanes"])
		
		roadWays[wayID]["wayCapacity"] = wayCapacity
		roadWays[wayID]["baseMovementCost"] = baseCost
		
		
					
	# -----------------------------------------------------------------------------------------------------------------------------------------------------
	# Loading the Buildings
	# -----------------------------------------------------------------------------------------------------------------------------------------------------
	var buildingCount = 0
	var buildingsNode = $"../Buildings"
	var placeInfo = null;

	for buildingWay in ImportedData.buildingWaysData.values():
		# Declaring Important Variables
		var buildingType = buildingWay["tags"]["building"]
		var newBuilding = null
		buildingCount = buildingCount + 1
		
		# Sorting the buildings into their respective types
		match buildingType:
			"house", "apartments", "dormitory":
				newBuilding = get_node("../BuildingAssets/residential").duplicate()
				placeInfo = residentialInfoDictionary.duplicate(true)
			"roof":
				newBuilding = get_node("../BuildingAssets/place").duplicate()
				placeInfo = placeInfoDictionary.duplicate(true)
			_:
				newBuilding = get_node("../BuildingAssets/workplace").duplicate()
				placeInfo = workplaceInfoDictionary.duplicate(true)
				
		# Moving the building to a place near it's real position
		var randomBuildingNode = ImportedData.buildingNodeData[buildingWay["nodes"][0]]
		var globalBuildingPosition = randomBuildingNode["position"]
		newBuilding.set_global_position(globalBuildingPosition)
		
		# Creating the click detection zone for the building
		var newClickZone = CollisionPolygon2D.new()
		newClickZone.name = "Buildings|" + str(buildingCount)
		newClickZone.set_global_position(globalBuildingPosition)
		newClickZone.z_index = 50
		
		# Drawing the buildings shape
		var buildingShape = newBuilding.get_node("shape")
		var arrayOfVectors = []
		for nodeID in buildingWay["nodes"]:
			var node = ImportedData.buildingNodeData[nodeID]
			var currentVector = node["position"] - globalBuildingPosition
			arrayOfVectors.append(currentVector)
		buildingShape.set_polygon(arrayOfVectors)
		newClickZone.set_polygon(arrayOfVectors)
		ClickingDetection.add_child(newClickZone)
		
		# Potentially edit this to be based of node position instead of road position. This would mean that nodes need to know what Ways their apart of.
		# Finding the nearest road to set as the access road
		if buildingType != "roof":
			var closestDistance: float = 1000000
			for roadID in roadWays:
				var placePosition: Vector2 = globalBuildingPosition
				var roadPosition: Vector2 = roadWays[str(roadID)]["globalPosition"]
				var distanceFound: float = placePosition.distance_squared_to(roadPosition)
				
				if distanceFound < closestDistance:
					closestDistance = distanceFound
					placeInfo["accessRoad"] = roadWays[str(roadID)]["id"]
		
		# Setting non-building specific meta data
		newBuilding.name = str(buildingCount)
		placeInfo["buildingID"] = str(buildingCount)
		placeInfo["buildingType"] = buildingType
		placeInfo["nodes"] = buildingWay["nodes"]
		placeInfo["globalPosition"] = globalBuildingPosition
		
		# Making the building visible
		newBuilding.visible = true
		
		# Adding buildings to the building node
		buildingWays[str(buildingCount)] = placeInfo
		buildingsNode.add_child(newBuilding)
		
	# Removing the imported data node as it is no longer needed
	ImportedData.queue_free()
	
	# Telling the rest of the simulation the asset constructing is done
	ASSETS_CONSTRUCTED.emit()
		
func figureOutBoolValueForMetaData(valueToInterpret: String):
	valueToInterpret.to_lower()

	if valueToInterpret == "no":
		return false
	else:
		return true
		
func laneLineConstructorEven(newRoad : Node2D, laneBeingConstructed : Line2D, layerNumber : int, roadWidth : int, listOfNodes : Array, isBridge : bool):
	var laneWidth = laneBeingConstructed.width
	
	# Clearing the lines points
	laneBeingConstructed.clear_points()
	
	# Adding the points for the line
	for nodeID in listOfNodes:
		var node = roadNodes[nodeID]
		var currentVector = node["position"] - globalRoadPosition
		laneBeingConstructed.add_point(currentVector)
	
	# Sorting out the width of the line and Zindex
	if layerNumber != 0:
		laneBeingConstructed.width = roadWidth + laneWidth * 2
		laneBeingConstructed.z_index = laneBeingConstructed.z_index - layerNumber
	
	if isBridge == true:
		laneBeingConstructed.z_index = laneBeingConstructed.z_index + 10
		
	# Making the line visible
	laneBeingConstructed.visible = true
	
	# Adding the lane to the road node
	newRoad.add_child(laneBeingConstructed)
