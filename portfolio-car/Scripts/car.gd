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

func _on_cycle_change(is_night: bool) -> void:
	spotLight1.visible = is_night
	spotLight2.visible = is_night
