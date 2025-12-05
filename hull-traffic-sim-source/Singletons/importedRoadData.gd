extends Node

# This script gets the Import Data for roads from OSM and turns it into a singleston that sits under the root, so the road data can be used later.
# It also transforms the data into a better format for the simulator to use

var nodeData = {}
var waysData = {}
var finishedImporting = false

var pathToRoadData = "res://OverpassAPIOSMData/TestOSMData1.json"

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
	var position = convertLongLatToGlobalXY(topLeftReferencePoint["latitude"], topLeftReferencePoint["longitude"])
	topLeftReferencePoint["globalX"] = position[0]
	topLeftReferencePoint["globalY"] = position[1]
	
	position = convertLongLatToGlobalXY(bottomRightReferencePoint["latitude"], bottomRightReferencePoint["longitude"])
	bottomRightReferencePoint["globalX"] = position[0]
	bottomRightReferencePoint["globalY"] = position[1]
	
	var data = loadJsonFile(pathToRoadData)
	nodeData = data[0]
	waysData = data[1]
	finishedImporting = true

func loadJsonFile(filePath : String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			var parsedNodes = {}
			var parsedWays = {}
			
			# Removing unnecassary data
			parsedResult.erase("version")
			parsedResult.erase("generator")
			parsedResult.erase("osm3s")
			
			for object in parsedResult.elements:	
				if object.type == "node":
					parsedNodes[object.id] = object.duplicate(true)
					var nodeBeingEdited = parsedNodes[object.id]
					
					# converting the Longitude and Latitutde to X and Y
					var latitude = nodeBeingEdited["lat"] 
					var longitude = nodeBeingEdited["lon"]
					
					var position = convertLongLatToScreenXY(latitude, longitude)
					nodeBeingEdited["X"] = position[1]
					nodeBeingEdited["Y"] = position[0]
						
				elif object.type == "way":
					parsedWays[object.id] = object.duplicate(true)
			
			return [parsedNodes, parsedWays]
		else:
			print("Error reading File")
	else:
		print("File dosen't exist")

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
