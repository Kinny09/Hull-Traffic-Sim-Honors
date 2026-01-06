extends Node

@onready var http_request = $HTTPRequest
@onready var ImportedData = $"../ImportedData"

var max_retries := 10
var retry_delay := 1.5  # seconds
var retry_count := 0

var query = ""
var returnedJson = JSON.new()

signal API_CALL_DONE()
signal ALL_API_CALLS_DONE()

func _ready() -> void:	
	http_request.request_completed.connect(_on_request_completed)
	query = """
		[out:json][timeout:50];
		(
			way(53.715000,-0.4836188,53.8109399,-0.2109668)
			["highway"~"^(motorway|trunk|primary|secondary|tertiary|motorway_link|trunk_link|primary_link|secondary_link|tertiary_link|residential|unclassified|living_street)$"];
			>;
		);
		out;
	"""
	send_overpass_request(query)
	await API_CALL_DONE
	ImportedData.roadJSON = returnedJson

	query = """
		[out:json][timeout:50];
		(
		  way(53.76953,-0.38532,53.78109,-0.35163)["building"];>;
		);
		out;
	"""
	send_overpass_request(query)
	await API_CALL_DONE
	ImportedData.buildingJSON = returnedJson
	
	ALL_API_CALLS_DONE.emit()
	
func send_overpass_request(query):
	var body = "data=" + query.uri_encode()

	http_request.request(
		"https://overpass-api.de/api/interpreter",
		["Content-Type: application/x-www-form-urlencoded"],
		HTTPClient.METHOD_POST,
		body
	)

func _on_request_completed(result, response_code, headers, body):
	print("Response:", response_code)

	# Overpass "busy" responses
	var busy_codes = [429, 504, 502, 503]

	if response_code in busy_codes:
		if retry_count < max_retries:
			retry_count += 1
			print("Server busy. Retrying in %s seconds…" % retry_delay)
			await get_tree().create_timer(retry_delay).timeout
			retry_delay *= 1.5  # exponential backoff
			send_overpass_request(query)
			return
		else:
			print("Max retries reached. Giving up.")
			return

	# If we get here, the request succeeded
	retry_count = 0
	retry_delay = 1.5

	var text = body.get_string_from_utf8()
	returnedJson = JSON.parse_string(text)

	if returnedJson == null:
		print("JSON parse error. Raw body:")
		print(text)
	else:
		API_CALL_DONE.emit()
		
