extends SpringArm3D

var MouseSensitivity = 0.1

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_as_top_level(true)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * MouseSensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90, -10)
		
		rotation_degrees.y -= event.relative.x * MouseSensitivity
		rotation_degrees.y = clamp(rotation_degrees.y, 0, 360)
