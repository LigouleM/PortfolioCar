extends Camera3D

# Ajustes de posición
var follow_distance: float = 4.5
var follow_height: float = 3.5
var follow_speed: float = 6.0

# Ajustes de Zoom / FOV
var min_fov: float = 75.0
var max_fov: float = 95.0
var fov_speed: float = 3.0

# Ajustes de enfoque visual
var look_shift: float = -3.0

var car: VehicleBody3D

func _ready() -> void:
	# Independiza la cámara del transform del padre, evitando que herede los rebotes.
	car = get_parent()
	set_as_top_level(true)

func _physics_process(delta: float) -> void:
	if not car: return

	# 1. Movimiento suave y sin rebotes
	# Calculamos el punto ideal detrás del auto basándonos en su orientación global
	var target_pos = car.global_position - (car.global_transform.basis.z * follow_distance)
	target_pos.y = car.global_position.y + follow_height
	
	# Interpolamos la posición global para suavizar el seguimiento
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	# 2. Efecto de zoom dinámico (FOV)
	# Calculamos la velocidad real del auto para ajustar el FOV al acelerar o frenar
	var speed = car.linear_velocity.length()
	var target_fov = clamp(min_fov + (speed * 0.8), min_fov, max_fov)
	fov = lerp(fov, target_fov, fov_speed * delta)

	# 3. Cambio de foco al doblar
	# Desplazamos el punto de mira en el eje X local del auto en base a cuánto está girando
	var steering_offset = car.global_transform.basis.x * (-car.steering * look_shift)
	var look_target = car.global_position + steering_offset
	
	# Obligamos a la cámara a mirar siempre al auto + el leve desplazamiento lateral
	look_at(look_target, Vector3.UP)
