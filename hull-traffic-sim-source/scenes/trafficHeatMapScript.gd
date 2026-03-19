extends Node

## Getting the necessary nodes
@onready var Roads = $"../../Roads"
@onready var ControlPanelController = $"../../UILayer/SimulationUI/ControlPanel/ControlPanelController"

## Member variables
var updateHeatMapThread: Thread
var tableOfHeatMapAssets: Array[HeatMapHelper] = []
var heatMapViewable: bool = false

## Main
func _ready() -> void:
	# Connecting the toggle button signal
	ControlPanelController.HEATMAP_BUTTON_TOGGLED.connect(ToggleHeatMapOnAndOff)
	
	# Initalizing
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

func ToggleHeatMapOnAndOff(toggleStatus: bool):
	if toggleStatus:
		UpdateHeatMap()
		self.visible = true
	else:
		self.visible = false

## An inner class for each way that helps with handling the heat map
class HeatMapHelper:
	var heatMapAsset: Line2D 
	var roadInfo: Dictionary
	var congestion: int
	var wayCapacity: int
