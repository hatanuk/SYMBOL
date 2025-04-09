extends SubViewportContainer

var target_rot_x: float
var target_rot_y: float
var rot_x: float
var rot_y: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rot_x != 0 or rot_y != 0 or target_rot_x != 0 or target_rot_y != 0:
		var speed = 5
		rot_x = lerp(rot_x, target_rot_x, speed * delta)
		rot_y = lerp(rot_y, target_rot_y, speed * delta)	
		set_shader_rotation(rot_x, rot_y)

func set_shader_rotation(x: float, y: float, tween: bool = false) -> void:
	material.set_shader_parameter("x_rot", y)
	material.set_shader_parameter("y_rot", x)
