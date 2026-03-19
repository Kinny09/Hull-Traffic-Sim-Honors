## A class that holds all the information for a specific origin-destination pair
class_name ODPair extends RefCounted

# Member Variables
var origin: Dictionary = {}
var destination: Dictionary = {}
var routeNodes: Array = []
var routeWays: Array = []
var agentsUsing: int = 0
var workTime: TimeOnly
var homeTime: TimeOnly

# Constructor
func _init(_origin: Dictionary, _destination: Dictionary, _workTime: TimeOnly, _homeTime: TimeOnly):
	origin = _origin
	destination = _destination
	workTime = _workTime
	homeTime = _homeTime
