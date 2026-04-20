extends Control

## Items Outside Itself
@onready var ClickingDetector = $"../../../../ClickingDetection"
@onready var RoadsNode = $"../../../../Roads"

## Self Items
@onready var Title = $"../Margin/ListOfSelectionInformation/Header/Title"
@onready var CloseButton = $"../Margin/ListOfSelectionInformation/Header/CloseButton"
@onready var SelectionMenu = $".."
@onready var ListOfSelectionInformation = $"../Margin/ListOfSelectionInformation"

## Member Variables
var selectionBoxVisible: bool = false
var listOfInfoLabels: Array[Label] = []

func _ready():
	ClickingDetector.ITEM_SELECTED.connect(updateSelection)
	CloseButton.pressed.connect(toggleVisible.bind())
	
func updateSelection(_selectionType, selectedItem):
	if !selectionBoxVisible:
		toggleVisible()
		
	if listOfInfoLabels.size() > 0:
		for item in listOfInfoLabels:
			item.queue_free()
			listOfInfoLabels = []
	
	for typeOfInformation in selectedItem:
		var labelInstance = Label.new()
		match typeOfInformation:
			## Building Stuff
			"buildingType":
				var textForLabel: String = selectedItem[typeOfInformation]
				
				if textForLabel == "yes":
					textForLabel = "Workplace"
				
				Title.text = selectedItem[typeOfInformation]
				
			"buildingID", "id":
				labelInstance.text = "ID: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
			
			"numberOfResidents":
				labelInstance.text = "Residents: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
			
			"workplaces":
				labelInstance.text = "# of Different Workplaces: %s" % [selectedItem[typeOfInformation].size()] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			"originDestinationPairs":
				labelInstance.text = "Number of Related ODPairs: %s" % [selectedItem[typeOfInformation].size()] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			"employmentCapacity":
				labelInstance.text = "Max Employees: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			"numberOfEmployees":
				labelInstance.text = "Current Employees: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			## Road Stuff
			"name":
				Title.text = selectedItem[typeOfInformation]
				
			"speedLimit":
				labelInstance.text = "Speed Limit: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			"bridge":
				labelInstance.text = "Is Bridge: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			"bikeLane":
				labelInstance.text = "Has Bikelane: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			"lanes":
				labelInstance.text = "# of Lanes: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			"congestion":
				labelInstance.text = "Road Congestion: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
				
			"wayCapacity":
				labelInstance.text = "Road Capacity: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
			
			"oneWay":
				labelInstance.text = "One Way: %s" % [selectedItem[typeOfInformation]] 
				listOfInfoLabels.append(labelInstance.duplicate())
	
	for infoLabel in listOfInfoLabels:
		ListOfSelectionInformation.add_child(infoLabel)
	
func toggleVisible():
	if selectionBoxVisible:
		selectionBoxVisible = false
		SelectionMenu.visible = false
		
	elif !selectionBoxVisible:
		selectionBoxVisible = true
		SelectionMenu.visible = true
