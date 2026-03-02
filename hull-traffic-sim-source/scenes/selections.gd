extends Node

@onready var ClickingDetector = $"../ClickingDetection"
@onready var RoadsNode = $"../Roads"

func _ready():
	ClickingDetector.ITEM_SELECTED.connect(itemClicked)
	
func itemClicked(selectionType, selection):
	# Clearing the selections
	for selectionGraphic in self.get_children():
		selectionGraphic.queue_free()
	
	#If the selection is a building
	if selectionType == "Buildings":
		# The main selection
		var buildingID = selection["buildingID"]
		var mainSelectionShape = get_node("../Buildings/" +  buildingID + "/shape").duplicate()
		mainSelectionShape.color = Color(0.8, 0, 0.2, 0.9)
		mainSelectionShape.z_index += 10
		mainSelectionShape.position = get_node("../Buildings/" +  buildingID).position
		add_child(mainSelectionShape)
		
		# The access road secondary graphic
		if selection["buildingType"] != "roof":
			var accessNodeID = selection["accessNode"]
			var accessNodePosition: Vector2 = RoadsNode["roadNodes"][accessNodeID]["position"]
			var nodeSelectionGraphic: Polygon2D = get_node("../DebuggingTools/Marker").duplicate()
			nodeSelectionGraphic.set_global_position(accessNodePosition)
			nodeSelectionGraphic.visible = true
			add_child(nodeSelectionGraphic)
			
		# The workplace secondary graphic
		if selection["buildingType"] in ["house", "apartments", "dormitory"]:
			for workplaceID in selection["workplaces"]:
				var workplacePosition = get_node("../Buildings/" +  workplaceID).position
				var workplaceSelectionShape = get_node("../Buildings/" +  workplaceID + "/shape").duplicate()
				workplaceSelectionShape.color = Color(0.3, 0, 0.2, 0.9)
				workplaceSelectionShape.z_index +=  10
				workplaceSelectionShape.position = workplacePosition
				add_child(workplaceSelectionShape)
	
	#If the selection is a road
	elif selectionType == "Roads":
		var roadID = selection["id"]
		var mainSelectionShape = get_node("../Roads/" +  roadID + "/pavement").duplicate()
		mainSelectionShape.set_default_color(Color(0.8, 0, 0.2, 0.9))
		mainSelectionShape.z_index += 10
		mainSelectionShape.position = get_node("../Roads/" +  roadID).position
		add_child(mainSelectionShape)
