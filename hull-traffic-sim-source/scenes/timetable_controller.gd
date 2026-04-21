extends Control

@onready var TrafficVisualization = $"../../../../TrafficSimulation/TrafficVisualization"
@onready var ControlPanelController = $"../../ControlPanel/ControlPanelController"
@onready var TimetableList = $"../TimetableMargin/VSplitContainer/TimetableScroller/ItemList"
@onready var ExampleItem = $"../TimetableMargin/VSplitContainer/TimetableScroller/ItemList/ExampleItem"
@onready var Timetable = $".."
@onready var TimetableCloseButton = $"../TimetableMargin/VSplitContainer/Header/CloseButton"

## Member Variables
var timeTableVisible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ControlPanelController.TIMETABLE_TOGGLED.connect(toggleTimetable)
	TimetableCloseButton.pressed.connect(toggleTimetable.bind())

func toggleTimetable():
	if timeTableVisible:
		Timetable.visible = false
		timeTableVisible = false
		
		for time in TimetableList.get_children():
			time.queue_free()
	
	elif !timeTableVisible:
		var trafficTimetable: Dictionary = TrafficVisualization["timetableOfAgents"]
		var timetableRowFactory: TimetableRowFactory = TimetableRowFactory.new()
		
		for time in trafficTimetable:
			var newItem = timetableRowFactory.MakeAnItem(time, trafficTimetable[time].size())
			TimetableList.add_child(newItem)
		
		Timetable.visible = true
		timeTableVisible = true
	
class TimetableRowFactory:
	var ItemContainer: PanelContainer
	var ItemRow: HBoxContainer
	var ScheduledTime: Label
	var Seperator: Label
	var NumberOfAgents: Label
	
	func _init():
		ItemContainer = PanelContainer.new()
		ItemRow = HBoxContainer.new()
		ScheduledTime = Label.new()
		Seperator = Label.new()
		NumberOfAgents = Label.new()
		
		var styleBox = StyleBoxFlat.new() 
		ItemContainer.add_theme_stylebox_override("panel", styleBox)
		ItemContainer.self_modulate = Color(0.352,0.352,0.352)
		
		ItemContainer.size_flags_horizontal = 3
		ItemRow.size_flags_horizontal = 3
		ScheduledTime.size_flags_horizontal = 3
		NumberOfAgents.size_flags_horizontal = 3
		
		ScheduledTime.add_theme_font_size_override("font_size", 14)
		Seperator.add_theme_font_size_override("font_size", 14)
		NumberOfAgents.add_theme_font_size_override("font_size", 14)
		
		ItemContainer.add_child(ItemRow)
		ItemRow.add_child(ScheduledTime)
		ItemRow.add_child(Seperator)
		ItemRow.add_child(NumberOfAgents)
		
	func MakeAnItem(_ScheduledTime: String, _NumberOfAgents: int) -> PanelContainer:
		ScheduledTime.text = _ScheduledTime
		NumberOfAgents.text = str(_NumberOfAgents)
		
		return ItemContainer.duplicate(true)
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
