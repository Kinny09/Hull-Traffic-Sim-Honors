extends MarginContainer

## Important Nodes
@onready var TimerNode = $"../../../../Timer"
@onready var DateLabel = $Dates/Date
@onready var TimeLabel = $Dates/TimerHolder/Timer
@onready var SpeedLabel = $Dates/TimerHolder/SpeedArrow
@onready var Buttons = $Dates/Controls

## Defining Important Constants
const DATE_STRING_FORMAT: String = "%02d/%02d/%s"
const TIME_STRING_FORMAT: String = "%02d:%02d:%02d"

## Member Variables
var speedString: String = "->"

## Signals
signal TIMER_BUTTON_PRESSED(buttonPressed: String)

## Setting up the date changed event
func _ready():
	# Creating the connections for the buttons that control the timer
	for child in Buttons.get_children():
		child.pressed.connect(ButtonPressed.bind(child))
	
	# Creating the connection nthat is fired every time the timer updates
	TimerNode.TIME_CHANGED.connect(updateTimer)
	TimerNode.TIME_SPEED_CHANGED.connect(timerSpeedChanged)

## Gets fired every time the time changes, it then updates the timer labels to the new dates and times
func updateTimer(newTime, _secondBeingAdded):
	var dateString: String = DATE_STRING_FORMAT % [newTime["day"], newTime["month"], newTime["year"]]
	var timeString: String = TIME_STRING_FORMAT % [newTime["hour"], newTime["minute"], newTime["second"]]
	DateLabel.text = dateString
	TimeLabel.text = timeString
	
func timerSpeedChanged(newTimerSpeed):
	match newTimerSpeed:
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
			else:
				buttonPressed.text = "Pause"
			await get_tree().create_timer(0.1).timeout
			buttonPressed.disabled = false
		"Forward":
			pass
