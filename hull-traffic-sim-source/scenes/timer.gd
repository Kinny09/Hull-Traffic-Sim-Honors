extends Node

## Node Paths
@onready var TimerController = $"../UILayer/SimulationUI/DateContainer/DateController"
@onready var RoadsNode = $"../Roads"

## Member Variables
var unixDateTime: int = Time.get_unix_time_from_datetime_string("2026-01-01T08:00:00")
var dateDictionary: Dictionary

## Important constants for handling adding time
const SECONDS_IN_MINUTES: int = 60
const SECONDS_IN_DAY: int = 24 * 60 * 60
const SECONDS_IN_WEEK: int = 7 * 24 * 60 * 60

## Member Variables
var timeBetweenUpdates: float = 1
var currentlyRunning = false
var secondToAddToTime = 1

## Signal used to keep in contact with the UI
signal TIME_CHANGED(newTime: Dictionary, secondsBetweenTimerUpdates: float)
signal TIME_SPEED_CHANGED(secondsBetweenTimerUpdates: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await RoadsNode.ASSETS_CONSTRUCTED # Waiting for the assets to be constructed
	
	# Connecting to the timer UI
	TimerController.TIMER_BUTTON_PRESSED.connect(updateTimerState)
	TimerController.TIMER_EDITED.connect(updateTime)
	
	# Initalizing the date
	dateDictionary = Time.get_datetime_dict_from_unix_time(unixDateTime)
	TIME_CHANGED.emit(dateDictionary, timeBetweenUpdates)

func updateTimerState(buttonPressed):
	match buttonPressed:
		"Reverse":
			if timeBetweenUpdates < 2:
				timeBetweenUpdates *= 2
				TIME_SPEED_CHANGED.emit(timeBetweenUpdates)
			
		"PauseAndPlay":
			if currentlyRunning:
				currentlyRunning = false
			else:
				currentlyRunning = true
				runTheTimer()
			
		"Forward":
			if timeBetweenUpdates > 0.0625:
				timeBetweenUpdates /= 2
				TIME_SPEED_CHANGED.emit(timeBetweenUpdates)
			
func runTheTimer():
	while currentlyRunning:
		unixDateTime += secondToAddToTime
		dateDictionary = Time.get_datetime_dict_from_unix_time(unixDateTime)
		TIME_CHANGED.emit(dateDictionary, timeBetweenUpdates)
		await get_tree().create_timer(timeBetweenUpdates).timeout
		
func updateTime(newTime):
	unixDateTime = Time.get_unix_time_from_datetime_dict(newTime)
	dateDictionary = Time.get_datetime_dict_from_unix_time(unixDateTime)
	TIME_CHANGED.emit(dateDictionary, timeBetweenUpdates)
	
