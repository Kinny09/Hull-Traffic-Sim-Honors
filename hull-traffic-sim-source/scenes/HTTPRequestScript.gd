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
var APIRequestDoneSuccessfully: bool = false
var statusText: String = "Sending API Calls and Getting Data..."

# Signals for tracking when things are done
signal API_CALL_DONE()
signal ALL_API_CALLS_DONE()

func _ready() -> void:	
	# Connecting to the on_request_completed method so the code knows when an API call is finished
	http_request.request_completed.connect(on_request_completed)
	
	# For just the Uni and Area:
	# way(53.75980,-0.39443,53.78318,-0.35470)
	
	# For all of Hull
	# way(53.715000,-0.4836188,53.8109399,-0.2109668)
	
	# for designed example area
	# way(53.7490293,-0.3974381,53.7510890,-0.3922175)
	
	# The roads API call
	query = """
		[out:json][timeout:50];
		(
			way(53.7490293,-0.3974381,53.7510890,-0.3922175)
			["highway"~"^(motorway|trunk|primary|secondary|tertiary|motorway_link|trunk_link|primary_link|secondary_link|tertiary_link|residential|unclassified|living_street|service)$"];
			>;
		);
		out;
	"""
	statusText += "\nGetting Road Data."
	send_overpass_request()
	await API_CALL_DONE
	ImportedData.importedRoadDataDictionary = returnedJson
	
	# The buildings API call
	query = """
		[out:json][timeout:50];
		(
			way(53.7490293,-0.3974381,53.7510890,-0.3922175)
			["building"];>;
		);
		out;
	"""
	statusText += "\nGetting Building Data."
	send_overpass_request()
	await API_CALL_DONE
	ImportedData.importedBuildingDataDictionary = returnedJson
	
	# Tells the other scripts that the API calls are all done
	APIRequestDoneSuccessfully = true
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
func on_request_completed(_result, response_code, _headers, body):
	statusText += "\nResponse: %s" % [response_code]

	# List of code numbers that mean the OverpassAPI server is busy
	var busy_codes = [429, 504, 502, 503]
	
	if response_code in busy_codes:
		if retry_count < max_retries:
			retry_count += 1
			statusText += "\nServer busy. Retrying in %s seconds..." % [retry_delay]
			await get_tree().create_timer(retry_delay).timeout
			retry_delay *= 1.5  # Exponential delay to prevent spamming of the API server
			send_overpass_request()
			return
		else:
			statusText += "\nMax retries reached. Giving up. Restart Program"
			return
	elif response_code not in busy_codes and response_code != 200:
		statusText = "Error occured with Overpass API, error code: %s. Restart the program and check your connected to the internet." % [response_code]
		return

	# Resets the variables for the retry logic as the call was a success
	retry_count = 0
	retry_delay = 1.5
	
	# Turns the JSON into a dictionary
	var text = body.get_string_from_utf8()
	returnedJson = JSON.parse_string(text)

	if returnedJson == null:
		statusText += "\nJSON parse error. Raw body:\n %s" % [text]
	else:
		statusText += "\nSuccessfully Complete."
		API_CALL_DONE.emit() # Tells the script that the API call is done and it can move onto the next one.
		
