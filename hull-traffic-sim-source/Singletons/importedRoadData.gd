extends Node

# This script gets the Import Data for roads from OSM and turns it into a singleston that sits under the root, so the road data can be used later.
# It also transforms the data into a better format for the simulator to use

var roadData = {}

var pathToRoadData = "res://OverpassAPIOSMData/TestOSMImportData1.json"

func _ready():
	roadData = loadJsonFile(pathToRoadData)

func loadJsonFile(filePath : String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error reading File")
	else:
		print("File dosen't exist")
