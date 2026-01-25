extends Node

@onready var ImportedData = $"../ImportedData"
@onready var ClickingDetection = $"../ClickingDetection"

var roadNodes = {}
var globalRoadPosition = Vector2(0,0)

func _ready() -> void:
	await ImportedData.FINISHED_IMPORTING_DATA # Waiting for the data to be imported before constructing the roads and buildings
	
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	## Loading the Roads
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	# Getting the road node data where it should be
	roadNodes = ImportedData.roadNodeData.duplicate(true)
	
	for way in ImportedData.roadWaysData.values():
		# Creating the new road asset node
		var newRoad = get_node("../LaneAssets/road").duplicate()
		newRoad.name = str(way["id"])
		
		# Setting the tags that need to always be changed from their defaults
		newRoad.set_meta("name", str(way["id"]))
		newRoad.set_meta("nodes", way["nodes"])
		
		# Sorting the roads tags
		var roadTags = way["tags"]
		
		for tagName in way["tags"]:
			match tagName:
				"name":
					newRoad.set_meta("name", roadTags["name"])
				"maxspeed":
					var speed = roadTags["maxspeed"]
					speed = int(speed.get_slice(" ", 0))
					newRoad.set_meta("speedLimit", speed)
					
				"lanes":
					newRoad.set_meta("lanes", int(roadTags[tagName]))
					
				"oneway":
					newRoad.set_meta("oneWay", figureOutBoolValueForMetaData(roadTags[tagName]))
					
				"bridge":
					newRoad.set_meta("bridge", figureOutBoolValueForMetaData(roadTags[tagName]))
					
				"lit":
					newRoad.set_meta("lit", figureOutBoolValueForMetaData(roadTags[tagName]))
					
				"traffic_calming":
					newRoad.set_meta("trafficCalming", figureOutBoolValueForMetaData(roadTags[tagName]))
				
				"sidewalk", "sidewalk:left", "sidewalk:right" when newRoad.get_meta("pavement") == false:
					newRoad.set_meta("pavement", figureOutBoolValueForMetaData(roadTags[tagName]))
						
				"cycleway", "cycleway:both", "cycleway:right", "cycleway:left" when newRoad.get_meta("bikeLane") == false:
					newRoad.set_meta("bikeLane", figureOutBoolValueForMetaData(roadTags[tagName]))
					
				"busway" when newRoad.get_meta("busLane") == false:
					newRoad.set_meta("busLane", figureOutBoolValueForMetaData(roadTags[tagName]))
		
		# Moving the road to a place near it's real position
		var randomNode = roadNodes[way["nodes"][0]]
		globalRoadPosition = Vector2(randomNode["X"], randomNode["Y"])
		newRoad.set_global_position(globalRoadPosition)
			
		# Drawing the road
		var totalNumberOfLanes = newRoad.get_meta("lanes")
		var roadWidth = 0 
		var layerNumber = 0
		var isBridge = newRoad.get_meta("bridge")
		var newLane = null
		
		if totalNumberOfLanes % 2 == 0: # If the number of lanes is even
			# Creating the lane divider
			newLane = get_node("../LaneAssets/car_lane_divider").duplicate()
			laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
			
			# Creating all the lanes
			for laneNumber in totalNumberOfLanes / 2:
				layerNumber = layerNumber + 1
				newLane = get_node("../LaneAssets/car_lane").duplicate()
				laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
				roadWidth = roadWidth + (newLane.width - roadWidth)
				
		elif totalNumberOfLanes % 2 == 1: # If the number of lanes is odd
			# Creating the middle lane
			newLane = get_node("../LaneAssets/car_lane").duplicate()
			laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
			roadWidth = roadWidth + (newLane.width - roadWidth)
			
			# Creating all the lanes
			for laneNumber in totalNumberOfLanes / 2:
				layerNumber = layerNumber + 1
				newLane = get_node("../LaneAssets/car_lane_divider").duplicate()
				laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
				roadWidth = roadWidth + (newLane.width - roadWidth)
				
				layerNumber = layerNumber + 1
				newLane = get_node("../LaneAssets/car_lane").duplicate()
				laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
				roadWidth = roadWidth + (newLane.width - roadWidth)
				
		# Creating the pavement
		newLane = get_node("../LaneAssets/pavement").duplicate()
		laneLineConstructorEven(newRoad, newLane, layerNumber, roadWidth, way["nodes"], isBridge)
		roadWidth = roadWidth + (newLane.width - roadWidth)
		
		# Creating the click detection zones for the road
		var clickSegmentCount = 0
			
		# Adding the road to the roads node		
		add_child(newRoad)	
		
		# Adding way nodes to the nodes list
		var listOfNodesInWay = way["nodes"]
		
		# Creating the click detectors for the roads
		for nodeIndex in listOfNodesInWay.size():
			if nodeIndex + 1 <= listOfNodesInWay.size() - 1:
				var newClickSegment = CollisionShape2D.new()
				var currentNode = roadNodes[listOfNodesInWay[nodeIndex]]
				var nodeAhead = roadNodes[listOfNodesInWay[nodeIndex + 1]]
				
				var currentNodeVector = Vector2(currentNode["X"], currentNode["Y"])
				var nodeAheadVector =  Vector2(nodeAhead["X"], nodeAhead["Y"])
				
				newClickSegment.shape = RectangleShape2D.new()
				newClickSegment.name = "road|"+ str(clickSegmentCount) + "|" + str(newRoad.name)
				newClickSegment.set_global_position((currentNodeVector + nodeAheadVector) / 2)
				clickSegmentCount = clickSegmentCount + 1
				
				newClickSegment.shape.size = Vector2(currentNodeVector.distance_to(nodeAheadVector), roadWidth)
				newClickSegment.rotation = (currentNodeVector.angle_to_point(nodeAheadVector))
				
				ClickingDetection.add_child(newClickSegment)
		
		# Finding nodes that are adjacent to each other and documenting that
		for nodeIndex in listOfNodesInWay.size():
			var nodeID = listOfNodesInWay[nodeIndex]
			if nodeIndex - 1 >= 0 and not newRoad.get_meta("oneWay"):
				roadNodes[nodeID]["adjacentNodes"].append(listOfNodesInWay[nodeIndex - 1])
			
			if nodeIndex + 1 <= listOfNodesInWay.size() - 1:
				roadNodes[nodeID]["adjacentNodes"].append(listOfNodesInWay[nodeIndex + 1])
					
	# -----------------------------------------------------------------------------------------------------------------------------------------------------
	# Loading the Buildings
	# -----------------------------------------------------------------------------------------------------------------------------------------------------
	var buildingCount = 0
	var buildingsNode = $"../Buildings"

	for buildingWay in ImportedData.buildingWaysData.values():
		# Declaring Important Variables
		var buildingType = buildingWay["tags"]["building"]
		var newBuilding = null
		buildingCount = buildingCount + 1
		
		# Sorting the buildings into their respective types
		match buildingType:
			"house", "apartments", "dormitory":
				newBuilding = get_node("../BuildingAssets/residential").duplicate()
			"roof":
				newBuilding = get_node("../BuildingAssets/place").duplicate()
			_:
				newBuilding = get_node("../BuildingAssets/workplace").duplicate()
				
		# Moving the building to a place near it's real position
		var randomBuildingNode = ImportedData.buildingNodeData[buildingWay["nodes"][0]]
		var globalBuildingPosition = Vector2(randomBuildingNode["X"], randomBuildingNode["Y"])
		newBuilding.set_global_position(globalBuildingPosition)
		
		# Creating the click detection zone for the building
		var newClickZone = CollisionPolygon2D.new()
		newClickZone.name = "building|" + str(buildingCount)
		newClickZone.set_global_position(globalBuildingPosition)
		newClickZone.z_index = 50
		
		# Drawing the buildings shape
		var buildingShape = newBuilding.get_node("shape")
		var arrayOfVectors = []
		for nodeID in buildingWay["nodes"]:
			var node = ImportedData.buildingNodeData[nodeID]
			var currentVector = Vector2(node.X, node.Y) - globalBuildingPosition
			arrayOfVectors.append(currentVector)
		buildingShape.set_polygon(arrayOfVectors)
		newClickZone.set_polygon(arrayOfVectors)
		ClickingDetection.add_child(newClickZone)
		
		# Finding the nearest road to set as the access road
		#for roads in roadNode.get_children():
			#pass
		
		# Setting non-building specific meta data
		newBuilding.name = str(buildingCount)
		newBuilding.set_meta("buildingID", buildingCount)
		newBuilding.set_meta("buildingType", buildingType)
		newBuilding.set_meta("nodes", buildingWay["nodes"])
		
		# Making the building visible
		newBuilding.visible = true
		
		# Adding buildings to the building node
		buildingsNode.add_child(newBuilding)
		
	# Removing the imported data node as it is no longer needed
	#ImportedData.queue_free()
		
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
		var currentVector = Vector2(node.X, node.Y) - globalRoadPosition
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
