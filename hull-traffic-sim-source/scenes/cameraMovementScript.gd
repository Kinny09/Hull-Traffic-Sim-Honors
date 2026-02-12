extends Camera2D


const MOVE_SPEED = 500.0

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		position.x -= MOVE_SPEED * delta
	if Input.is_action_pressed("ui_right"):
		position.x += MOVE_SPEED * delta
	if Input.is_action_pressed("ui_up"):
		position.y -= MOVE_SPEED * delta
	if Input.is_action_pressed("ui_down"):
		position.y += MOVE_SPEED * delta

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(0.1, 0.1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(0.1, 0.1)
	zoom = zoom.clamp(Vector2(0.2, 0.2), Vector2(11.0, 11.0))
