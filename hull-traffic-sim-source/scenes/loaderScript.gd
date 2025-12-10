extends Node

func _ready() -> void:
	# -----------------------------------------------------------------------------------------------------------------------------------------------------
	# Loading the Roads
	# -----------------------------------------------------------------------------------------------------------------------------------------------------
	for way in importedRoadData.waysData.values():
		# Creating the road nodes and adding their meta data
		var newRoad = Node2D.new()
		newRoad.name = str(way["id"])
		
		# Sorting out the road tags so the simulator can understand them
		var roadTags = way["tags"]
		
		#Setting default values for the road meta data
		newRoad.set_meta("name", str(way["id"]))
		newRoad.set_meta("speedLimit", 60)
		newRoad.set_meta("nodes", {})
		newRoad.set_meta("adjacentRoads", [])
		newRoad.set_meta("lanes", 2)
		newRoad.set_meta("lengthOfRoad", 0.0)
		newRoad.set_meta("oneWay", false)
		newRoad.set_meta("bridge", false)
		newRoad.set_meta("lit", false)
		newRoad.set_meta("trafficCalming", false)
		newRoad.set_meta("pavement", false)
		newRoad.set_meta("bikeLane", false)
		newRoad.set_meta("busLane", false)
		
		# Checking if the roads have any road specific data to adjust
		for tagName in way["tags"]:
			match tagName:
				"name":
					newRoad.set_meta("name", roadTags["name"])
					
				"maxspeed":
					var speed = roadTags["maxspeed"]
					speed = int(speed.get_slice(" ", 0))
					newRoad.set_meta("speedLimit", speed)
					
				"lanes":
					newRoad.set_meta("lanes", roadTags[tagName])
					
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
	
		# Drawing the Road
		var newPavementLine = get_node("../LaneAssets/pavement").duplicate()
		newPavementLine.clear_points()
		
		var newCarLine = get_node("../LaneAssets/car_lane").duplicate()
		newCarLine.clear_points()
		
		var newDividerLine = get_node("../LaneAssets/car_lane_divider").duplicate()
		newDividerLine.clear_points()
		
		var zIndexAdditon = 0
		if newRoad.get_meta("bridge") == true:
			zIndexAdditon = zIndexAdditon + 4
		newPavementLine.z_index = newPavementLine.z_index + zIndexAdditon
		newCarLine.z_index = newCarLine.z_index + zIndexAdditon
		newDividerLine.z_index = newDividerLine.z_index + zIndexAdditon
		
		var dictionaryOfNodes = {}
		var oldVector = Vector2(0, 0)
		var roadLength = 0.0
		var adjacentRoads = []
		for nodeID in way["nodes"]:
			var node = importedRoadData.nodeData[nodeID]
			var currentVector = Vector2(node.X, node.Y)
			node.erase("type")
			node.erase("lat")
			node.erase("lon")
			dictionaryOfNodes[nodeID] = node
			
			newPavementLine.width = 6
			newPavementLine.add_point(currentVector)
			newPavementLine.visible = true
			
			newCarLine.width = 4
			newCarLine.add_point(currentVector)
			newCarLine.visible = true

			newDividerLine.width = 0.2
			newDividerLine.add_point(currentVector)
			newDividerLine.visible = true
			
			# Calculating the length between two points
			if oldVector != Vector2(0, 0):
				roadLength = roadLength + oldVector.distance_to(currentVector)
				
			# Checking for adjacent roads
			#for wayToCheck in importedRoadData.waysData.values():
				#if nodeID in wayToCheck["nodes"]:
					#adjacentRoads.append(way["id"])
			
			oldVector = Vector2(node.X, node.Y)
		newRoad.add_child(newPavementLine)
		newRoad.add_child(newCarLine)
		newRoad.add_child(newDividerLine)
		add_child(newRoad)
		
		# Adding all the nodes for this road to the road meta data
		newRoad.set_meta("nodes", dictionaryOfNodes)
		
		# Adding the length of the road to the road meta data
		newRoad.set_meta("lengthOfRoad", roadLength)
		
		# Adding the adjacent roads to the road meta data
		newRoad.set_meta("adjacentRoads", adjacentRoads)
		
	# -----------------------------------------------------------------------------------------------------------------------------------------------------
	# Loading the Buildings
	# -----------------------------------------------------------------------------------------------------------------------------------------------------
	var buildingCount = 0
	var buildingsNode = $"../Buildings"
	var roadNode = $"../Roads"

	for buildingWay in importedRoadData.buildingWaysData.values():
		# Declaring Important Variables
		var buildingType = buildingWay["tags"]["building"]
		var newBuilding = null
		buildingCount = buildingCount + 1
		
		#Sorting the buildings into their respective types
		match buildingType:
			"house", "apartments", "dormitory":
				newBuilding = get_node("../BuildingAssets/residential").duplicate()
			"roof":
				newBuilding = get_node("../BuildingAssets/place").duplicate()
			_:
				newBuilding = get_node("../BuildingAssets/workplace").duplicate()
				
		# Moving the building to a place near it's real position
		var randomNode = importedRoadData.buildingNodeData[buildingWay["nodes"][0]]
		var globalBuildingPosition = Vector2(randomNode["X"], randomNode["Y"])
		newBuilding.set_global_position(globalBuildingPosition)
		
		# Drawing the buildings shape
		var buildingShape = newBuilding.get_node("shape")
		var arrayOfVectors = []
		for nodeID in buildingWay["nodes"]:
			var node = importedRoadData.buildingNodeData[nodeID]
			var currentVector = Vector2(node.X, node.Y) - globalBuildingPosition
			arrayOfVectors.append(currentVector)
		buildingShape.set_polygon(arrayOfVectors)
		
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
	importedRoadData.queue_free()
		
func figureOutBoolValueForMetaData(valueToInterpret: String):
	valueToInterpret.to_lower()

	if valueToInterpret == "no":
		return false
	else:
		return true
