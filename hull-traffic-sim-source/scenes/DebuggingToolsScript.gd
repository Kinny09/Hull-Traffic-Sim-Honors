extends Node
@onready var RoadsData = $"../Roads"
@onready var ImportedData = $"../ImportedData"

func _ready() -> void:
	await ImportedData.FINISHED_IMPORTING_DATA # Waiting for the data to be imported before constructing the roads and buildings
	await get_tree().create_timer(1).timeout
	#checkAdjacentNodes(9617190856)
	#checkAdjacentNodes(258353993)
	pass

func checkAdjacentNodes(NodeID : int):
	var adjacentNodes = RoadsData["roadNodes"][NodeID]["adjacentNodes"]
	var marker = get_node("./Marker")
	
	var positionOfRootNode = Vector2(RoadsData["roadNodes"][NodeID]["X"], RoadsData["roadNodes"][NodeID]["Y"])
	var newMarker = marker.duplicate()
	newMarker.set_global_position(positionOfRootNode)
	newMarker.color = Color(1, 0, 1, 1)
	newMarker.visible = true
	add_child(newMarker)
	
	for node in adjacentNodes:
		var positionOfAdjacents = Vector2(RoadsData["roadNodes"][node]["X"], RoadsData["roadNodes"][node]["Y"])
		
		newMarker = marker.duplicate()
		newMarker.set_global_position(positionOfAdjacents)
		newMarker.visible = true
		add_child(newMarker)
