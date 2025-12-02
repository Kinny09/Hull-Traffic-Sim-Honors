extends Node

func _ready() -> void:
	for way in importedRoadData.waysData.values():
		# Creating the road nodes and adding their meta data
		var newRoad = Node2D.new()
		newRoad.name = str(way["id"])
		
		var roadTags = way["tags"]
		#newRoad.set_meta("Name", roadTags["name"])
		#newRoad.set_meta("LaneTypes", DictonaryForBasicRoads[roadTags["highway"]])
		#newRoad.set_meta("SpeedLimit", int(roadTags["maxspeed"].replace(" mph","")))
		#newRoad.set_meta("Surface", roadTags["asphalt"])
	
		# Drawing the Road
		var newPavementLine = get_node("../LaneAssets/pavement").duplicate()
		newPavementLine.clear_points()
		
		var newCarLine = get_node("../LaneAssets/car_lane").duplicate()
		newCarLine.clear_points()
		
		var newDividerLine = get_node("../LaneAssets/car_lane_divider").duplicate()
		newDividerLine.clear_points()
		
		for nodeID in way["nodes"]:
			var node = importedRoadData.nodeData[nodeID]
			
			newPavementLine.width = 6
			newPavementLine.add_point(Vector2(node.X, node.Y))
			newPavementLine.visible = true
			
			newCarLine.width = 4
			newCarLine.add_point(Vector2(node.X, node.Y))
			newCarLine.visible = true

			newDividerLine.width = 0.2
			newDividerLine.add_point(Vector2(node.X, node.Y))
			newDividerLine.visible = true
			
		newRoad.add_child(newPavementLine)
		newRoad.add_child(newCarLine)
		newRoad.add_child(newDividerLine)
		add_child(newRoad)
		
