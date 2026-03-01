extends Control

@onready var ClickingDetector = $"../../../../ClickingDetection"
@onready var ItemsList = $"../SelectionInfoBox/Background/Items"
@onready var RoadsNode = $"../../../../Roads"

func _ready():
	ClickingDetector.ITEM_SELECTED.connect(itemClicked)
	
func itemClicked(_selectionType, selection):
	for informationLabel in ItemsList.get_children():
		informationLabel.queue_free()
	
	var itemsToBeDisplayed = selection
	
	for information in itemsToBeDisplayed:
		if information not in "nodes":
			var newInformationLabel = Label.new()
			newInformationLabel.text = information + ": " + str(itemsToBeDisplayed[information])
			ItemsList.add_child(newInformationLabel)
