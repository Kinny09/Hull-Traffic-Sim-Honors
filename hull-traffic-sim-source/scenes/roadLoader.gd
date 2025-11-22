extends Node

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	for way in importedRoadData.waysData.values():
		var newRoad = Line2D.new()
		newRoad.width = 1
		for nodeID in way.nodes:
			var node = importedRoadData.nodeData[nodeID]
			newRoad.add_point(Vector2(node.X, node.Y))
		add_child(newRoad)
