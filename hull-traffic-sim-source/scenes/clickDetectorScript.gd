extends Area2D

signal ITEM_SELECTED(selectedItemID : String)

func _ready():
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var collisonShapeID = shape_find_owner(shape_idx)
		var shapeNode = shape_owner_get_owner(collisonShapeID)
		ITEM_SELECTED.emit(shapeNode)
