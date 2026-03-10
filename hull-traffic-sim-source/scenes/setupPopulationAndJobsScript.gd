extends Node

@onready var RoadsNode = $"../Roads"

signal BUILDINGS_POPULATED()

func _ready() -> void:
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	## Setup
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	# Getting the population figures
	var totalPopulation:int = get_meta("totalPopulation")
	var totalJobs:int = get_meta("totalJobs")
	
	# Instansiating important variables
	var roadsNode = $"../Roads"
	
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	## Actual Code
	## -----------------------------------------------------------------------------------------------------------------------------------------------------
	await RoadsNode.ASSETS_CONSTRUCTED # Waiting for the assets to be constructed
	
	# Getting the important tables
	var residentialBuildings: Dictionary = roadsNode["residentialBuildings"]
	var workplaceBuildings: Dictionary = roadsNode["workplaceBuildings"]
	
	# Prepering important variables
	var totalNumberOfHouses:int = 0
	var totalNumberOfHighDensity:int = 0
	var totalNumberOfWorkplaces: int = workplaceBuildings.size()
	var totalNumberOfBuildings: int = workplaceBuildings.size() + residentialBuildings.size()
	var workplaceBuildingsArray: Array[Dictionary] = []
	
	# Finding the numbers of the different types of housing and the number of workplaces
	for residentialBuilding in residentialBuildings.values():
		var buildingType:String = residentialBuilding["buildingType"]
		
		match buildingType:
			"house":
				totalNumberOfHouses += 1
				
			"apartments", "dormitory":
				totalNumberOfHighDensity += 1
	
	## Figuring out how many people should live and work in the places.
	@warning_ignore("integer_division")
	var peoplePerHighDensity:int =  totalPopulation * totalNumberOfHighDensity / totalNumberOfBuildings
	@warning_ignore("integer_division")
	var peoplePerHouse:int = (totalPopulation - peoplePerHighDensity)/totalNumberOfHouses
	@warning_ignore("integer_division")
	var peoplePerWorkplace:int = totalJobs/totalNumberOfWorkplaces
	
	 # Adding the people to residence
	for residentialBuilding in residentialBuildings.values():
		var buildingType:String = residentialBuilding["buildingType"]
		
		match buildingType:
			"house":
				residentialBuilding["numberOfResidents"] = peoplePerHouse
				
			"apartments", "dormitory":
				residentialBuilding["numberOfResidents"] = peoplePerHighDensity
		
	# Adding the workers to the workplaces
	for workplaceBuilding in workplaceBuildings.values():
		var buildingType:String = workplaceBuilding["buildingType"]
		workplaceBuildingsArray.append(workplaceBuilding)
		
		if buildingType != "roof":
			workplaceBuilding["employmentCapacity"] = peoplePerWorkplace
		
	## Giving residences their workplaces
	var workplaceIndex:int = 0
	
	for residentialBuilding in residentialBuildings.values():
		var numberOfResidenceToGiveJobsTo:int = residentialBuilding["numberOfResidents"]

		while numberOfResidenceToGiveJobsTo > 0 && workplaceIndex <= workplaceBuildingsArray.size() - 1:
			var workplaceCurrentlyBeingPopulated: Dictionary = workplaceBuildingsArray[workplaceIndex]
			var workplaceID: String = workplaceCurrentlyBeingPopulated["buildingID"]
			var numberOfOpenJobsForCurrentBuilding: int = workplaceCurrentlyBeingPopulated["employmentCapacity"] - workplaceCurrentlyBeingPopulated["numberOfEmployees"]
			
			# What to do if the workplace has more jobs than the residence can provide
			if numberOfResidenceToGiveJobsTo < numberOfOpenJobsForCurrentBuilding:
				workplaceCurrentlyBeingPopulated["numberOfEmployees"] += numberOfResidenceToGiveJobsTo
				residentialBuilding["workplaces"][workplaceID] = numberOfResidenceToGiveJobsTo
				numberOfResidenceToGiveJobsTo = 0
			
			# What to do if the workplace has the same amount of jobs as the residence can provide
			elif numberOfResidenceToGiveJobsTo == numberOfOpenJobsForCurrentBuilding:
				workplaceCurrentlyBeingPopulated["numberOfEmployees"] += numberOfResidenceToGiveJobsTo
				residentialBuilding["workplaces"][workplaceID] = numberOfResidenceToGiveJobsTo
				numberOfResidenceToGiveJobsTo = 0
				workplaceIndex += 1
				
			# What to do if the workplace has less jobs than the residence can provide
			elif numberOfResidenceToGiveJobsTo > numberOfOpenJobsForCurrentBuilding:
				workplaceCurrentlyBeingPopulated["numberOfEmployees"] += numberOfOpenJobsForCurrentBuilding
				residentialBuilding["workplaces"][workplaceID] = numberOfOpenJobsForCurrentBuilding
				numberOfResidenceToGiveJobsTo -= numberOfOpenJobsForCurrentBuilding
				workplaceIndex += 1
				
	#BUILDINGS_POPULATED.emit()
