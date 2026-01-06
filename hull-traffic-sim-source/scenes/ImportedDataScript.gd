extends Node

## This script gets the Import Data for roads from OSM and turns it into a singleston that sits under the root, so the road data can be used later.
## It also transforms the data into a better format for the simulator to use

signal FINISHED_IMPORTING_DATA()

var importedRoadDataDictionary = {}
var importedBuildingDataDictionary = {}

var nodeData = {}
var waysData = {}
var buildingNodeData = {}
var buildingWaysData = {}

@onready var HTTPRequestNode = $"../HTTPRequestNode"

@onready var pathToRoadData = "res://OverpassAPIOSMData/RoadOSMData.json"
@onready var pathToBuildingData ="res://OverpassAPIOSMData/TestBuildingOSMData.json" 

## Two reference points that link the bounding box for the data to on screen coordinates
var topLeftReferencePoint =  {
	"screenX": -2000,
	"screenY": -2324,
	"latitude": 53.8109399,
	"longitude": -0.4836188,
	"globalX": 0,
	"globalY": 0
}

var bottomRightReferencePoint =  {
	"screenX": 2000,
	"screenY": 2324,
	"latitude": 53.715000,
	"longitude": -0.2109668,
	"globalX": 0,
	"globalY": 0
}

var radiusOfEarth = 6371

func _ready():
	await HTTPRequestNode.ALL_API_CALLS_DONE # Waits for all the API calls to be finished before starting
	
	var position = convertLongLatToGlobalXY(topLeftReferencePoint["latitude"], topLeftReferencePoint["longitude"])
	topLeftReferencePoint["globalX"] = position[0]
	topLeftReferencePoint["globalY"] = position[1]
	
	position = convertLongLatToGlobalXY(bottomRightReferencePoint["latitude"], bottomRightReferencePoint["longitude"])
	bottomRightReferencePoint["globalX"] = position[0]
	bottomRightReferencePoint["globalY"] = position[1]
	
	var data = loadImportedDataDictionary(importedRoadDataDictionary)
	nodeData = data[0]
	waysData = data[1]
	
	data = loadImportedDataDictionary(importedBuildingDataDictionary)
	buildingNodeData = data[0]
	buildingWaysData = data[1]
	
	# Tells all the scripts that the data is done being imported
	FINISHED_IMPORTING_DATA.emit()

func loadImportedDataDictionary(importedDataDictionary : Dictionary):
	if importedDataDictionary is Dictionary:
		var parsedNodes = {}
		var parsedWays = {}
		
		# Removing unnecassary data
		importedDataDictionary.erase("version")
		importedDataDictionary.erase("generator")
		importedDataDictionary.erase("osm3s")
		
		for object in importedDataDictionary.elements:	
			if object.type == "node":
				parsedNodes[object.id] = object.duplicate(true)
				var nodeBeingEdited = parsedNodes[object.id]
				
				# Converting the Longitude and Latitutde to X and Y
				var latitude = nodeBeingEdited["lat"] 
				var longitude = nodeBeingEdited["lon"]
				
				var position = convertLongLatToScreenXY(latitude, longitude)
				nodeBeingEdited["X"] = position[1]
				nodeBeingEdited["Y"] = position[0]
					
			elif object.type == "way":
				parsedWays[object.id] = object.duplicate(true)
		
		return [parsedNodes, parsedWays]
	else:
		print("Error reading imported data")

## https://stackoverflow.com/questions/16266809/convert-from-latitude-longitude-to-x-y

func convertLongLatToGlobalXY(longitude : float, latitude : float):
	var x = radiusOfEarth * longitude * cos((topLeftReferencePoint["latitude"] + bottomRightReferencePoint["latitude"])/2)
	var y = radiusOfEarth * latitude
	return [x, y]
	
func convertLongLatToScreenXY(longitude : float, latitude : float):
	var position = convertLongLatToGlobalXY(longitude, latitude)
	var x = ((position[0]-topLeftReferencePoint["globalX"])/(bottomRightReferencePoint["globalX"] - topLeftReferencePoint["globalX"]))
	var y = ((position[1]-topLeftReferencePoint["globalY"])/(bottomRightReferencePoint["globalY"] - topLeftReferencePoint["globalY"]))
	
	x = topLeftReferencePoint["screenX"] + (bottomRightReferencePoint["screenX"] - topLeftReferencePoint["screenX"]) * x
	y = topLeftReferencePoint["screenY"] + (bottomRightReferencePoint["screenY"] - topLeftReferencePoint["screenY"]) * y
	
	return [x, y]
