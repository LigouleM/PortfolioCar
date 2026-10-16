extends DirectionalLight3D

@export var cycle_duration: float = 600.0 # 10 minutos en total (600 segundos)
@export var time_multiplier: float = 1.0  # ¡Súbelo a 60.0 para testear rápido!

# Colores de las fases
@export var day_color: Color = Color("ffffff") # Blanco puro
@export var transition_color: Color = Color("ff7700") # Naranja de amanecer/atardecer
@export var night_color: Color = Color("1a1a33") # Azul oscuro/violáceo

# Intensidad de la luz
@export var day_energy: float = 1.0
@export var night_energy: float = 0.05

var time_passed: float = 0.0

signal cycleChange(is_night: bool)

func _process(delta: float) -> void:
	# time_multiplier te permite acelerar el tiempo para probar sin esperar 10 mins
	time_passed += delta * time_multiplier 
	
	# Reiniciar el ciclo al llegar a los 10 minutos
	if time_passed >= cycle_duration:
		time_passed -= cycle_duration

	# 1. ROTACIÓN FÍSICA DEL SOL
	# El sol da una vuelta de 360 grados. 
	# Empezamos en -20 grados (sol apenas sobre el horizonte, terminando de amanecer)
	var time_ratio = time_passed / cycle_duration
	rotation_degrees.x = lerp(-20.0, -380.0, time_ratio)

	# 2. CONTROL DE FASES (Luz y Color)
	if time_passed < 240.0:
		# DÍA (0 a 4 minutos)
		light_color = day_color
		light_energy = day_energy
		
	elif time_passed < 300.0:
		# ATARDECER (4 a 5 minutos)
		var t = (time_passed - 240.0) / 60.0 # 't' va de 0.0 a 1.0 durante este minuto
		if t < 0.5:
			# Primera mitad del minuto: Blanco a Naranja
			light_color = day_color.lerp(transition_color, t * 2.0)
		else:
			# Segunda mitad del minuto: Naranja a Azul Oscuro
			light_color = transition_color.lerp(night_color, (t - 0.5) * 2.0)
		
		light_energy = lerp(day_energy, night_energy, t)
		cycleChange.emit(true)
		
	elif time_passed < 540.0:
		# NOCHE (5 a 9 minutos)
		light_color = night_color
		light_energy = night_energy
		
	else:
		# AMANECER (9 a 10 minutos)
		var t = (time_passed - 540.0) / 60.0 # 't' va de 0.0 a 1.0 durante este minuto
		if t < 0.5:
			# Primera mitad: Azul a Naranja
			light_color = night_color.lerp(transition_color, t * 2.0)
		else:
			# Segunda mitad: Naranja a Blanco
			light_color = transition_color.lerp(day_color, (t - 0.5) * 2.0)
			
		light_energy = lerp(night_energy, day_energy, t)
		cycleChange.emit(false)
