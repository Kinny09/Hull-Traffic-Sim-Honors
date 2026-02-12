extends Node

@onready var ClickingDetector = $"../ClickingDetection"
@onready var RoadsNode = $"../Roads"

func _ready():
	ClickingDetector.ITEM_SELECTED.connect(itemClicked)
	
func itemClicked(selectedItemID):
	var buildingWaysDictionary = RoadsNode["buildingWays"]
	#var roadWaysDictionary = RoadsNode["roadWays"]
	
	
	for selectionGraphic in self.get_children():
		selectionGraphic.queue_free()
	
	var splitString = selectedItemID.name.split("|")
	var origonalNodePosition = Vector2(0,0)
	var selectionShape = null
	var itemID = ""

	if splitString[0] == "Buildings":
		itemID = splitString[1]
		origonalNodePosition = get_node("../Buildings/" +  itemID).position
		selectionShape = get_node("../Buildings/" +  itemID + "/shape").duplicate()
		selectionShape.color = Color(0.8, 0, 0.2, 0.9)
		
		## Creating the access road selection box if needed
		if buildingWaysDictionary[itemID]["buildingType"] != "roof":
			var accessRoadID:String = buildingWaysDictionary[itemID]["accessRoad"]
			var accessRoadOrigonalNodePosition = get_node("../Roads/" +  accessRoadID).position
			var accessRoadSelectionShape = get_node("../Roads/" +  accessRoadID + "/pavement").duplicate()
			accessRoadSelectionShape.set_default_color(Color(0.3, 0, 0.2, 0.9))
			accessRoadSelectionShape.z_index = selectionShape.z_index + 10
			accessRoadSelectionShape.position = accessRoadOrigonalNodePosition
			add_child(accessRoadSelectionShape)
		
		## Creating and showing the workplaces a residence works at when their selected
		if buildingWaysDictionary[itemID]["buildingType"] in ["house", "apartments", "dormitory"]:
			for workplaceID in buildingWaysDictionary[itemID]["workplaces"]:
				var workplacePosition = get_node("../Buildings/" +  workplaceID).position
				var workplaceSelectionShape = get_node("../Buildings/" +  workplaceID + "/shape").duplicate()
				workplaceSelectionShape.color = Color(0.3, 0, 0.2, 0.9)
				workplaceSelectionShape.z_index = selectionShape.z_index + 10
				workplaceSelectionShape.position = workplacePosition
				add_child(workplaceSelectionShape)
		
	elif splitString[0] == "Roads":
		itemID = splitString[2]
		origonalNodePosition = get_node("../Roads/" +  itemID).position
		selectionShape = get_node("../Roads/" +  itemID + "/pavement").duplicate()
		selectionShape.set_default_color(Color(0.8, 0, 0.2, 0.9))
	
	selectionShape.z_index = selectionShape.z_index + 10
	selectionShape.position = origonalNodePosition
	add_child(selectionShape)
