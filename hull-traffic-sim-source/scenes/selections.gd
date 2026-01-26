extends Node

@onready var ClickingDetector = $"../ClickingDetection"

func _ready():
	ClickingDetector.ITEM_SELECTED.connect(itemClicked)
	
func itemClicked(selectedItemID):
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
		
	elif splitString[0] == "Roads":
		itemID = splitString[2]
		origonalNodePosition = get_node("../Roads/" +  itemID).position
		selectionShape = get_node("../Roads/" +  itemID + "/pavement").duplicate()
		selectionShape.set_default_color(Color(0.8, 0, 0.2, 0.9))
	
	selectionShape.z_index = selectionShape.z_index + 10
	selectionShape.position = origonalNodePosition
	add_child(selectionShape)
