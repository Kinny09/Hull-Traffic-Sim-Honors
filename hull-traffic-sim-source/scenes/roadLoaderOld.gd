extends Node
#
##enum LaneType {pavement, car_lane_left, car_lane_right}
#
#var DictonaryForBasicRoads = {
	#"tertiary" = ["pavement", "car_lane_left", "car_lane_right", "pavement"],
	#"residential" = ["pavement", "car_lane_left", "car_lane_right", "pavement"],
	#"testAsymmetricRoad" = ["pavement", "car_lane_left", "car_lane_left", "car_lane_right", "pavement"]
#}
#
#func _ready() -> void:
	#for way in importedRoadData.waysData.values():
		## Creating the road nodes and adding their meta data
		#var newRoad = Node2D.new()
		#newRoad.name = str(way["id"])
		#
		#var roadTags = way["tags"]
		#newRoad.set_meta("Name", roadTags["name"])
		#newRoad.set_meta("LaneTypes", DictonaryForBasicRoads[roadTags["highway"]])
		#newRoad.set_meta("SpeedLimit", int(roadTags["maxspeed"].replace(" mph","")))
		##newRoad.set_meta("Surface", roadTags["asphalt"])
		#
		## Drawing the Road
		#var arrayOfLanes = newRoad.get_meta("LaneTypes")
		#var roadWidth = 0
		#
		## Finding out the road width
		#for lane in arrayOfLanes:
			#var laneWidth = get_node("../LaneAssets/" + lane).width
			#roadWidth =  roadWidth + laneWidth
		#
		## Working out the math for drawing the lane, and then drawing the lane
		#var laneCount = 0
		#var numberOfLanes = arrayOfLanes.size()
		#
		#for lane in arrayOfLanes:
			#var newLane = get_node("../LaneAssets/" + lane).duplicate()
			#newLane.clear_points()
			#newLane.name = lane
			#newLane.visible = true
			#
			#var offsetForLane = roadWidth/2 - newLane.width/2
			#if laneCount <= floor(numberOfLanes/2):
				#offsetForLane = -offsetForLane
			#
			#var secondIndex = 1
			#for firstIndex in way.nodes.size() - 1:
				#var firstNode = importedRoadData.nodeData[way.nodes[firstIndex]]
				#var secondNode = importedRoadData.nodeData[way.nodes[secondIndex]]
				#
				#var newVectors = getParallelLine(Vector2(firstNode.X, firstNode.Y), Vector2(secondNode.X, secondNode.Y), offsetForLane)
#
				#newLane.add_point(newVectors[0])
				#secondIndex = secondIndex + 1
				#
				#if firstIndex == way.nodes.size() - 2:
					#newLane.add_point(newVectors[1])
				#
			#laneCount = laneCount + 1
			#newRoad.add_child(newLane)
		#add_child(newRoad)
		#
#func getParallelLine(p1: Vector2, p2: Vector2, distance: float):
	#var dir = p2 - p1
	#var perp = Vector2(-dir.y, dir.x)
	#perp = perp.normalized()
	#var offset = perp * distance
	#var new_p1 = p1 + offset
	#var new_p2 = p2 + offset
#
	#return [new_p1, new_p2]
