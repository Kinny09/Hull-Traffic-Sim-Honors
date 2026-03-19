extends MarginContainer

## Important Nodes
@onready var TimerNode = $"../../../../Timer"
@onready var DateLabel = $Dates/Date
@onready var SpeedLabel = $Dates/TimerHolder/SpeedArrow
@onready var Buttons = $Dates/Controls
@onready var HoursTextEdit = $Dates/TimerHolder/Hours
@onready var MinutesTextEdit = $Dates/TimerHolder/Minutes
@onready var SecondsTextEdit = $Dates/TimerHolder/Seconds
@onready var RoadsNode = $"../../../../Roads"

## Defining Important Constants
const DATE_STRING_FORMAT: String = "%02d/%02d/%s"
const TIME_STRING_FORMAT: String = "%02d:%02d:%02d"

## Member Variables
var speedString: String = "->"
var currentTime: Dictionary = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_datetime_string("2026-01-01T00:00:00"))

## Signals
signal TIMER_BUTTON_PRESSED(buttonPressed: String)
signal TIMER_EDITED(newTime: Dictionary)

## Setting up the date changed event
func _ready():
	# Creating the connections for the buttons that control the timer
	for child in Buttons.get_children():
		child.pressed.connect(ButtonPressed.bind(child))
	
	# Creating the connections for the line edits that allow the time to be changed
	HoursTextEdit.editing_toggled.connect(TimeEdited.bind())
	MinutesTextEdit.editing_toggled.connect(TimeEdited.bind())
	SecondsTextEdit.editing_toggled.connect(TimeEdited.bind())
	
	# Creating the connection nthat is fired every time the timer updates
	TimerNode.TIME_CHANGED.connect(updateTimer)
	TimerNode.TIME_SPEED_CHANGED.connect(timerSpeedChanged)

## Gets fired every time the time changes, it then updates the timer labels to the new dates and times
func updateTimer(newTime, _secondBeingAdded):
	currentTime = newTime
	var dateString: String = DATE_STRING_FORMAT % [newTime["day"], newTime["month"], newTime["year"]]
	DateLabel.text = dateString
	HoursTextEdit.text = "%02d" % [newTime["hour"]]
	MinutesTextEdit.text = "%02d" % [newTime["minute"]]
	SecondsTextEdit.text = "%02d" % [newTime["second"]]
	
func timerSpeedChanged(newTimerSpeed):
	match newTimerSpeed:
		0.0625:
			speedString = "----->"
		0.125:
			speedString = "---->"
		0.25:
			speedString = "--->"
		0.5:
			speedString = "-->"
		1.0:
			speedString = "->"
		2.0:
			speedString = ">"
	SpeedLabel.text = speedString

func ButtonPressed(buttonPressed):
	TIMER_BUTTON_PRESSED.emit(buttonPressed.name)
		
	match buttonPressed.name:
		"Reverse":
			pass	
		"PauseAndPlay":
			buttonPressed.disabled = true
			if buttonPressed.text == "Pause":
				buttonPressed.text = "Play"
				HoursTextEdit.editable = true
				MinutesTextEdit.editable = true
				SecondsTextEdit.editable = true
				HoursTextEdit.flat = false
				MinutesTextEdit.flat = false
				SecondsTextEdit.flat = false
			else:
				buttonPressed.text = "Pause"
				HoursTextEdit.editable = false
				MinutesTextEdit.editable = false
				SecondsTextEdit.editable = false
				HoursTextEdit.flat = true
				MinutesTextEdit.flat = true
				SecondsTextEdit.flat = true
			await get_tree().create_timer(0.1).timeout
			buttonPressed.disabled = false
		"Forward":
			pass
			
func TimeEdited(textBeingEdited):
	if !textBeingEdited:
		var newHours = HoursTextEdit.text
		var newMinutes = MinutesTextEdit.text
		var newSeconds = SecondsTextEdit.text
		if !newHours.is_valid_int() or !newMinutes.is_valid_int() or !newSeconds.is_valid_int():
			HoursTextEdit.text = "%02d" % [currentTime["hour"]]
			MinutesTextEdit.text = "%02d" % [currentTime["minute"]]
			SecondsTextEdit.text = "%02d" % [currentTime["second"]]
		else:
			newHours = clamp(int(newHours), 0, 23)
			newMinutes = clamp(int(newMinutes), 0, 59)
			newSeconds = clamp(int(newSeconds), 0, 59)
			currentTime["hour"] = newHours
			currentTime["minute"] = newMinutes
			currentTime["second"] = newSeconds
			TIMER_EDITED.emit(currentTime)
