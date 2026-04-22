extends Control

## Items Outside Itself
@onready var TimerNode = $"../../../../Timer"

## Self Items
@onready var FPSCounterLabel = $"../List/FPSCounter"
@onready var FPSAverage = $"../List/FPSAverage"

## Member Variables
var arrayOfFPSMeasurments: Array[float]
var run: bool = false
var averageFPS: float = 0

#func _ready() -> void:
	#await TrafficSimulation.TRAFFIC_SIMULATION_INITALIZATION_COMPLETE # Wait for all the precalculated routes
	#run = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if TimerNode.currentlyRunning:
		averageFPS = 0
		arrayOfFPSMeasurments.append(Engine.get_frames_per_second())
		
		for number in arrayOfFPSMeasurments:
			averageFPS += number 
		averageFPS /= arrayOfFPSMeasurments.size()
		
		FPSCounterLabel.text = "FPS: %.2f" % [Engine.get_frames_per_second()]
		FPSAverage.text = "Average FPS: %.2f" % [averageFPS]
