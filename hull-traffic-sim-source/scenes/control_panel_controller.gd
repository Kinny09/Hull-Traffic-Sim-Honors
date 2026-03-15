extends Control

## Getting important nodes
@onready var HeatmapToggleButton = $"../ControlPanelHider/HeatmapToggle/CheckButton"

## Setting up the signals
signal HEATMAP_BUTTON_TOGGLED(buttonStatus: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecting the heat map toggle button to the function
	HeatmapToggleButton.toggled.connect(HeatmapToggle.bind())

## Function that is fired whenever the HeatmapToggleButton is toggled
func HeatmapToggle(buttonStatus: bool):
	HEATMAP_BUTTON_TOGGLED.emit(buttonStatus)
