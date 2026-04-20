extends Panel

# Items Outside Itself
@onready var RoadsNode = $"../../../Roads"
@onready var TrafficSimulation = $"../../../TrafficSimulation"
@onready var HTTPRequestNode = $"../../../HTTPRequestNode"

## Self Items
@onready var LoadingScreen = $"."
@onready var StatusLabel = $MarginContainer/VBoxContainer/Status
@onready var LoadingBar = $MarginContainer/VBoxContainer/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = true
	StatusLabel.text = "Sending API Calls and Getting Data..."
	LoadingBar.indeterminate = true
	while HTTPRequestNode.APIRequestDoneSuccessfully == false:
		await get_tree().create_timer(0.1).timeout
		StatusLabel.text = HTTPRequestNode.statusText
	StatusLabel.text = "Constructing Assets."
	
	var pathsToProcess: int = TrafficSimulation.tableOfODPairs.size()
	var pathProgress: int = TrafficSimulation.progressCount
	LoadingBar.indeterminate = false
	StatusLabel.text = "Precalculating Routes..."
	while pathProgress < pathsToProcess:
		await get_tree().create_timer(0.1).timeout
		pathsToProcess = TrafficSimulation.tableOfODPairs.size()
		pathProgress = TrafficSimulation.progressCount
		var barProgress: float = float(pathProgress) / float(pathsToProcess)
		LoadingBar.value = barProgress
		StatusLabel.text = "Precalculating Routes...\n" + str(pathProgress) + "/" + str(pathsToProcess) + "\n"
	LoadingScreen.free()

func updateLoadingBar(numberOfPathsProcessed):
	var pathsToProcess: int = TrafficSimulation.tableOfODPairs.size()
	LoadingBar.indeterminate = false
	StatusLabel.text = "Precalculating Routes..."
	var barProgress: float = float(numberOfPathsProcessed) / float(pathsToProcess)
	LoadingBar.Step = barProgress
	StatusLabel.Text = numberOfPathsProcessed + "/" + pathsToProcess
