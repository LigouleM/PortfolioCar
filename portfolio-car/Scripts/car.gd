extends VehicleBody3D

var maxRPM = 450
var maxTorque = 350
var turnSpeed = 3.5
var turnAmount = 0.5

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
	else:
		engine_force = torque
		brake = 0.0        # Quitamos el freno por completo para avanzar
	
	
