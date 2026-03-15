extends Panel

@onready var LoadingScreen = $"."
@onready var RoadsNode = $"../../../Roads"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = true
	await RoadsNode.ASSETS_CONSTRUCTED # Waiting for the assets to be constructed
	LoadingScreen.free()
