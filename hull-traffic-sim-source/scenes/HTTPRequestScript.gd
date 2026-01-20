extends Node

# Getting necessary nodes
@onready var http_request = $HTTPRequest
@onready var ImportedData = $"../ImportedData"

# The varibles which control the retry logic for the API calls
var max_retries := 10
var retry_delay := 1.5  # seconds
var retry_count := 0

# Global variables used by the whole script
var query = ""
var returnedJson = JSON.new()

# Signals for tracking when things are done
signal API_CALL_DONE()
signal ALL_API_CALLS_DONE()

func _ready() -> void:	
	# Connecting to the _on_request_completed method so the code knows when an API call is finished
	http_request.request_completed.connect(_on_request_completed)
	
	# For just the Uni and Area:
	# way(53.76953,-0.38532,53.78109,-0.35163)
	
	# For all of Hull
	# way(53.715000,-0.4836188,53.8109399,-0.2109668)
	
	# The roads API call
	query = """
		[out:json][timeout:50];
		(
			way(53.76953,-0.38532,53.78109,-0.35163)
			["highway"~"^(motorway|trunk|primary|secondary|tertiary|motorway_link|trunk_link|primary_link|secondary_link|tertiary_link|residential|unclassified|living_street)$"];
			>;
		);
		out;
	"""
	send_overpass_request()
	await API_CALL_DONE
	ImportedData.importedRoadDataDictionary = returnedJson
	
	# The buildings API call
	query = """
		[out:json][timeout:50];
		(
			way(53.76953,-0.38532,53.78109,-0.35163)
			["building"];>;
		);
		out;
	"""
	send_overpass_request()
	await API_CALL_DONE
	ImportedData.importedBuildingDataDictionary = returnedJson
	
	# Tells the other scripts that the API calls are all done
	ALL_API_CALLS_DONE.emit()
	
# A function that sends the API call
func send_overpass_request():
	var body = "data=" + query.uri_encode()

	http_request.request(
		"https://overpass-api.de/api/interpreter",
		["Content-Type: application/x-www-form-urlencoded"],
		HTTPClient.METHOD_POST,
		body
	)

# The function and process the API calls response. If the API call is a busy code, it then attempt to try the call again 10 more times before giving up.
func _on_request_completed(_result, response_code, _headers, body):
	print("Response:", response_code)

	# List of code numbers that mean the OverpassAPI server is busy
	var busy_codes = [429, 504, 502, 503]
	
	if response_code in busy_codes:
		if retry_count < max_retries:
			retry_count += 1
			print("Server busy. Retrying in %s seconds…" % retry_delay)
			await get_tree().create_timer(retry_delay).timeout
			retry_delay *= 1.5  # Exponential delay to prevent spamming of the API server
			send_overpass_request()
			return
		else:
			print("Max retries reached. Giving up.")
			return

	# Resets the variables for the retry logic as the call was a success
	retry_count = 0
	retry_delay = 1.5
	
	# Turns the JSON into a dictionary
	var text = body.get_string_from_utf8()
	returnedJson = JSON.parse_string(text)

	if returnedJson == null:
		print("JSON parse error. Raw body:")
		print(text)
	else:
		API_CALL_DONE.emit() # Tells the script that the API call is done and it can move onto the next one.
		
