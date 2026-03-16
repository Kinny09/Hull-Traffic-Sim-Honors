extends Node

## Node Paths
@onready var TimerController = $"../UILayer/SimulationUI/DateContainer/DateController"

## Member Variables
var unixDateTime: int = Time.get_unix_time_from_datetime_string("2026-01-01T00:00:00")
var dateDictionary: Dictionary

## Important constants for handling adding time
const SECONDS_IN_MINUTES: int = 60
const SECONDS_IN_DAY: int = 24 * 60 * 60
const SECONDS_IN_WEEK: int = 7 * 24 * 60 * 60

## Member Variables
var timeBetweenUpdates = 1
var currentlyRunning = false
var secondToAddToTime = 1

## Signal used to keep in contact with the UI
signal TIME_CHANGED(newTime: Dictionary, secondBeingAddedToTime: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecting to the timer UI
	TimerController.TIMER_BUTTON_PRESSED.connect(updateTimerState)
	
	# Initalizing the date
	dateDictionary = Time.get_datetime_dict_from_unix_time(unixDateTime)

func updateTimerState(buttonPressed):
	match buttonPressed:
		"Reverse":
			secondToAddToTime -= SECONDS_IN_MINUTES
			TIME_CHANGED.emit(dateDictionary, secondToAddToTime)
			
		"PauseAndPlay":
			if currentlyRunning:
				currentlyRunning = false
			else:
				currentlyRunning = true
				runTheTimer()
			
		"Forward":
			secondToAddToTime += SECONDS_IN_MINUTES
			TIME_CHANGED.emit(dateDictionary, secondToAddToTime)
			
func runTheTimer():
	while currentlyRunning:
		unixDateTime += secondToAddToTime
		dateDictionary = Time.get_datetime_dict_from_unix_time(unixDateTime)
		TIME_CHANGED.emit(dateDictionary, secondToAddToTime)
		await get_tree().create_timer(timeBetweenUpdates).timeout
	
