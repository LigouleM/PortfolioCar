extends VehicleBody3D

var maxRPM = 450
var maxTorque = 300
var turnSpeed = 3
var turnAmount = 0.3

func _physics_process(delta: float) -> void:
	$CameraArm.position = position
	
	var dir = Input.get_action_strength("Gas") - Input.get_action_strength("Brake")
	var steeringDir = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	
	var RPMLeft = abs($VehicleWheelBL.get_rpm())
	var RPMRight = abs($VehicleWheelBR.get_rpm())
	var RPM = (RPMLeft + RPMRight) / 2.0
	
	var torque = dir + maxTorque * (1 - RPM / maxRPM)
	
	engine_force = torque
	steering = lerp(steering, steeringDir * turnAmount, turnSpeed * delta)
	
	if dir == 0:
		brake = 2
	
	
