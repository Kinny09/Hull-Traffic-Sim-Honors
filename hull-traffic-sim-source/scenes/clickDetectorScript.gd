extends Area2D

func _ready():
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var collisonShapeID = shape_find_owner(shape_idx)
		var shapeNode = shape_owner_get_owner(collisonShapeID)
		print("Clicked on:", shapeNode.name)
