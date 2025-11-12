extends Node

# This script gets the Import Data for roads from OSM and turns it into a singleston that sits under the root, so the road data can be used later.
# It also transforms the data into a better format for the simulator to use

var nodeData = {}
var waysData = {}
var finishedImporting = false

var pathToRoadData = "res://OverpassAPIOSMData/TestOSMImportData1.json"

func _ready():
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
						
				elif object.type == "way":
					parsedWays[object.id] = object.duplicate(true)
			
			return [parsedNodes, parsedWays]
		else:
			print("Error reading File")
	else:
		print("File dosen't exist")
