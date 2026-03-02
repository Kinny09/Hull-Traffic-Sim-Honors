extends Node

## Getting the necessary nodes
@onready var Roads = $"../../Roads"

# This script will need to be completely recoded for the actual simulation

# Member variables
var updateHeatMapThread: Thread
var tableOfHeatMapAssets: Array[HeatMapHelper] = []
var updateTimer: int = 2 # Replace this with a signal from the traffic simulation that fires every time it updates

## Main
func _ready() -> void:
	await Roads.ASSETS_CONSTRUCTED # Waiting for the assets to be constructed
	
	# Initalizing the heatmap assets
	for wayID in Roads["roadWays"]:
		var wayIDString: String = str(wayID)
		var newHeatMapHelper: HeatMapHelper = HeatMapHelper.new()
		newHeatMapHelper.heatMapAsset = get_node("../../Roads/" +  wayIDString + "/pavement").duplicate(true)
		newHeatMapHelper.heatMapAsset.z_index += 50
		newHeatMapHelper.heatMapAsset.position = get_node("../../Roads/" +  wayIDString).position
		newHeatMapHelper.roadInfo = Roads["roadWays"][wayID]
		newHeatMapHelper.congestion = newHeatMapHelper.roadInfo["congestion"]
		newHeatMapHelper.wayCapacity = newHeatMapHelper.roadInfo["wayCapacity"]
		add_child(newHeatMapHelper.heatMapAsset)
		tableOfHeatMapAssets.append(newHeatMapHelper)
		
	while true:
		await get_tree().create_timer(updateTimer).timeout # Replace this with a signal from the traffic simulation that fires every time it updates
		UpdateHeatMap()
		
	
func UpdateHeatMap() -> void:
	# Updating the congestion values
	for heatMapHelperToUpdate in tableOfHeatMapAssets:
		heatMapHelperToUpdate.congestion = heatMapHelperToUpdate.roadInfo["congestion"]
		heatMapHelperToUpdate.wayCapacity = heatMapHelperToUpdate.roadInfo["wayCapacity"]
	
	# Sorting the array by congestion
	tableOfHeatMapAssets.sort_custom(func(a, b): return a.congestion > b.congestion)
	
	# Getting a baseline for the most congested road that all the others will be based off of
	var redChannelBaseline: float = 1
	
	# Iterating through the assets, working out their relative congestion and figuring out the colour they should be
	for heatMapHelperToCheck in tableOfHeatMapAssets:
		var redChannel: float = float(heatMapHelperToCheck.congestion) / float(heatMapHelperToCheck.wayCapacity)
		var greenChannel: float = redChannelBaseline - redChannel
		heatMapHelperToCheck.heatMapAsset.set_default_color(Color(redChannel, greenChannel, 0, 0.3))	
	
## An inner class for each way that helps with handling the heat map
class HeatMapHelper:
	var heatMapAsset: Line2D 
	var roadInfo: Dictionary
	var congestion: int
	var wayCapacity: int
