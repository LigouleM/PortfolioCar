extends VehicleBody3D

var maxRPM = 450
var maxTorque = 350
var turnSpeed = 3.5
var turnAmount = 0.5
var smokeChangeSpeed = 1.5
@onready var smokeParts: GPUParticles3D = $SmokeParts
@onready var spotLight1: SpotLight3D = $SpotLight3D2
@onready var spotLight2: SpotLight3D = $SpotLight3D3
@export var sun: DirectionalLight3D
@onready var engine: AudioStreamPlayer3D = $engine
@onready var honk: AudioStreamPlayer3D = $honk
@onready var screech: AudioStreamPlayer3D = $screech
var base_pitch: float = 0.8
var max_pitch: float = 1.6
var max_speed_for_audio: float = 25.0 # Ajusta esto a la velocidad máxima aproximada de tu auto

func _ready():
	if sun:
		sun.cycleChange.connect(_on_cycle_change)

func _physics_process(delta: float) -> void:
	var dir = Input.get_action_strength("Gas") - Input.get_action_strength("Brake")
	var steeringDir = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	
	var RPMLeft = abs($VehicleWheelBL.get_rpm())
	var RPMRight = abs($VehicleWheelBR.get_rpm())
	var RPM = (RPMLeft + RPMRight) / 2.0
	
	# Reemplazamos el '+' por '*' para que el torque dependa del input
	var torque = dir * maxTorque * (1 - RPM / maxRPM)
	
	steering = lerp(steering, steeringDir * turnAmount, turnSpeed * delta)
	# Manejamos el freno y el motor de forma independiente
	if dir == 0:
		engine_force = 0.0 # Apagamos el motor
		brake = 5.0        # Frenamos el auto (puedes subir este valor si frena lento)
		smokeParts.amount_ratio = lerp(smokeParts.amount_ratio, 0.2, smokeChangeSpeed * delta)
	else:
		engine_force = torque
		brake = 0.0        # Quitamos el freno por completo para avanzar
		smokeParts.amount_ratio = lerp(smokeParts.amount_ratio, 1.0, smokeChangeSpeed * delta)

	# Obtenemos la velocidad real en metros por segundo
	var speed = linear_velocity.length()
	
	# 1. Motor (Tono y Volumen)
	# Calculamos un porcentaje de 0.0 a 1.0 basado en la velocidad actual vs la máxima
	var speed_ratio = clamp(speed / max_speed_for_audio, 0.0, 1.0)
	
	# Interpolamos el tono (pitch) para hacerlo más agudo al acelerar
	engine.pitch_scale = lerp(base_pitch, max_pitch, speed_ratio)
	
	# Interpolamos el volumen. -10 dB es más silencioso (ralentí), 0 dB es volumen completo
	engine.volume_db = lerp(-10.0, 0.0, speed_ratio)

	# 2. Bocina
	if Input.is_action_just_pressed("Honk"):
		honk.play()

	# 3. Derrape / Frenada brusca
	# Consideramos una maniobra "violenta" si va a más de 10 m/s y el volante 
	# está girado más del 60% de su capacidad total (turnAmount * 0.6)
	var is_drifting = speed > 10.0 and abs(steering) > (turnAmount * 0.7)
	
	# También podemos sumar la condición de que si presiona el freno mientras va rápido, suene
	var is_hard_braking = speed > 8.0 and brake > 0.0
	
	if is_drifting or is_hard_braking:
		# Solo le damos play si no estaba sonando ya, para no reiniciar el audio en cada frame
		if not screech.playing:
			screech.play()
	else:
		# Lo detenemos suavemente en cuanto se estabiliza la dirección o se frena por completo
		if screech.playing:
			screech.stop()
			
func _on_cycle_change(is_night: bool) -> void:
	spotLight1.visible = is_night
	spotLight2.visible = is_night
