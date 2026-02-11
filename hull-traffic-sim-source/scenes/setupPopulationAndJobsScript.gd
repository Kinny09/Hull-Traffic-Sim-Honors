extends Node

@onready var RoadsNode = $"../Roads"

func _ready() -> void:
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	## Setup
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	# Getting the population figures
	var totalPopulation:int = get_meta("totalPopulation")
	var totalJobs:int = get_meta("totalJobs")
	
	# Instansiating important variables
	var totalNumberOfHouses:int = 0
	var totalNumberOfHighDensity:int = 0
	var totalNumberOfWorkplaces:int = 0
	var totalNumberOfBuildings:int = 0
	
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	## Actual Code
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	await RoadsNode.ASSETS_CONSTRUCTED # Waiting for the assets to be constructed
	
	# Getting the necessary tables
	var buildingWays:Dictionary = RoadsNode["buildingWays"]
	
	# Finding the numbers of the different types of housing and the number of workplaces
	for building in buildingWays.values():
		var buildingType:String = building["buildingType"]
		
		match buildingType:
			"house":
				totalNumberOfHouses += 1
				
			"apartments", "dormitory":
				totalNumberOfHighDensity += 1
			
			_ when buildingType != "roof":
				totalNumberOfWorkplaces += 1
	
	# Figuring out how many people should live and work in the places.
	totalNumberOfBuildings = buildingWays.size()
	@warning_ignore("integer_division")
	var peoplePerHighDensity:int =  totalPopulation * totalNumberOfHighDensity / totalNumberOfBuildings
	@warning_ignore("integer_division")
	var peoplePerHouse:int = (totalPopulation - peoplePerHighDensity)/totalNumberOfHouses
	@warning_ignore("integer_division")
	var peoplePerWorkplace:int = totalJobs/totalNumberOfWorkplaces
	
	# Adding the people to residence and workplaces
	for building in buildingWays.values():
		var buildingType:String = building["buildingType"]
		
		match buildingType:
			"house":
				building["numberOfResidents"] = peoplePerHouse
				
			"apartments", "dormitory":
				building["numberOfResidents"] = peoplePerHighDensity
			
			_ when buildingType != "roof":
				building["employmentCapacity"] = peoplePerWorkplace
