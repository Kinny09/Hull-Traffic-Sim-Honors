extends Control

@onready var ClickingDetector = $"../../../../ClickingDetection"
@onready var ItemsList = $"../SelectionInfoBox/Background/Items"

func _ready():
	ClickingDetector.ITEM_SELECTED.connect(itemClicked)
	
func itemClicked(selectedItemID):
	for informationLabel in ItemsList.get_children():
		informationLabel.queue_free()
	
	var splitString = selectedItemID.name.split("|")
	var itemsToBeDisplayed = {}
	var node = null
	var itemID = ""
	
	if splitString[0] == "Buildings":
		itemID = splitString[1]
		node = get_node("../../../../Buildings/" +  itemID)
		itemsToBeDisplayed = node.get_meta_list()
		
	elif splitString[0] == "Roads":
		itemID = splitString[2]
		node = get_node("../../../../Roads/" +  itemID)
		itemsToBeDisplayed = node.get_meta_list()
	
	for information in itemsToBeDisplayed:
		if information not in "nodes":
			var newInformationLabel = Label.new()
			newInformationLabel.text = information + ": " + str(node.get_meta(information))
			ItemsList.add_child(newInformationLabel)
			
			
# Make it so the code dosen't have to physcially go into the nodes to get this information, move it all to the road and building head nodes.
		
