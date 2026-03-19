## A custom class that holds information about a specific Time. Only allows valid times to be made, does not have any dynamic properties
class_name TimeOnly extends RefCounted

# Member Variables
var hours: int
var minutes: int
var seconds: int

# Constants
const ERROR_STRING = "The time %02d:%02d:%02d is not a valid time"

# Constructor
func _init(_hours: int, _minutes: int, _seconds: int):
	if _hours > 23 or _minutes > 60 or _seconds > 60 or _hours < 0 or _minutes < 0 or _seconds < 0:
		var errorString: String = "The time %02d:%02d:%02d is not a valid time" % [_hours, _minutes, _seconds]
		assert(false, errorString)
		
	hours = _hours
	minutes =  _minutes
	seconds = _seconds
	
func returnUnixTimePlusGivenData():
	pass
