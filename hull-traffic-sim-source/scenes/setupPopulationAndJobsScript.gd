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
	var arrayOfResidentialBuildings: Array[Dictionary] = []
	var arrayOfWorkplaceBuildings: Array[Dictionary] = []
	
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
				arrayOfResidentialBuildings.append(building)
				
			"apartments", "dormitory":
				totalNumberOfHighDensity += 1
				arrayOfResidentialBuildings.append(building)
			
			_ when buildingType != "roof":
				totalNumberOfWorkplaces += 1
				arrayOfWorkplaceBuildings.append(building)
	
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
				
	# Giving residences their Workplaces
	var workplaceIndex:int = 0
	
	for residence in arrayOfResidentialBuildings:
		var numberOfResidenceToGiveJobsTo:int = residence["numberOfResidents"]

		while numberOfResidenceToGiveJobsTo > 0:
			var workplaceCurrentlyBeingPopulated:Dictionary = arrayOfWorkplaceBuildings[workplaceIndex]
			var workplaceID:String = workplaceCurrentlyBeingPopulated["buildingID"]
			var numberOfOpenJobsForCurrentBuilding:int = workplaceCurrentlyBeingPopulated["employmentCapacity"] - workplaceCurrentlyBeingPopulated["numberOfEmployees"]
			
			# What to do if the workplace has more jobs than the residence can provide
			if numberOfResidenceToGiveJobsTo < numberOfOpenJobsForCurrentBuilding:
				workplaceCurrentlyBeingPopulated["numberOfEmployees"] += numberOfResidenceToGiveJobsTo
				residence["workplaces"][workplaceID] = numberOfResidenceToGiveJobsTo
				numberOfResidenceToGiveJobsTo = 0
			
			# What to do if the workplace has the same amount of jobs as the residence can provide
			elif numberOfResidenceToGiveJobsTo == numberOfOpenJobsForCurrentBuilding:
				workplaceCurrentlyBeingPopulated["numberOfEmployees"] += numberOfResidenceToGiveJobsTo
				residence["workplaces"][workplaceID] = numberOfResidenceToGiveJobsTo
				numberOfResidenceToGiveJobsTo = 0
				workplaceIndex += 1
				
			# What to do if the workplace has less jobs than the residence can provide
			elif numberOfResidenceToGiveJobsTo > numberOfOpenJobsForCurrentBuilding:
				workplaceCurrentlyBeingPopulated["numberOfEmployees"] += numberOfOpenJobsForCurrentBuilding
				residence["workplaces"][workplaceID] = numberOfOpenJobsForCurrentBuilding
				numberOfResidenceToGiveJobsTo -= numberOfOpenJobsForCurrentBuilding
				workplaceIndex += 1
