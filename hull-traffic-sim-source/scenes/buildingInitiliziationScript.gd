extends Node

@onready var uninitalizedBuildings = $"../UninitalizedBuildings".get_children()

var residentialBuildings: Dictionary = {}
var workplaceBuildings: Dictionary = {}
var miscBuilding: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for uninitilizedBuilding in uninitalizedBuildings:
		# Setting up important variables
		var newBuilding: Dictionary = {}
		var uninitilizedBuildingID:String = str(uninitilizedBuilding.name)
		
		# Setting up the building info
		for metaName in uninitilizedBuilding.get_meta_list():
			newBuilding[metaName] = uninitilizedBuilding.get_meta(metaName)
		
		# Setting the ID of the building
		newBuilding["id"] = uninitilizedBuildingID
		
		# Adding the building to the correct dictionary of buildingsvv
		match uninitilizedBuilding.get_meta("buildingType"):
			"house", "apartments", "dormitory":
				residentialBuildings[uninitilizedBuildingID] = newBuilding
			
			
			"roof":
				miscBuilding[uninitilizedBuildingID] = newBuilding
				
			_:
				workplaceBuildings[uninitilizedBuildingID] = newBuilding
