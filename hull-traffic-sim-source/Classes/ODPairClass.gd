## A class that holds all the information for a specific origin-destination pair
class_name ODPair extends RefCounted

# Member Variables
var origin: Dictionary = {}
var destination: Dictionary = {}
var routeNodes: Array = []
var routeWays: Array = []
var agentsUsing: int = 0

# Constructor
func _init(_origin: Dictionary = {}, _destination: Dictionary = {}):
	origin = _origin
	destination = _destination
