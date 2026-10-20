extends Area3D

@export var url_to_open: String = "https://github.com/tu-usuario"
@export var model_scene: PackedScene 

@export var rotation_speed: float = 1.5
@export var float_speed: float = 3.0
@export var float_height: float = 0.2

var pivot: Node3D
var current_model: Node3D
var time_passed: float = 0.0
var base_y: float = 0.0
var can_trigger: bool = true

func _ready() -> void:
	body_exited.connect(_on_body_exited)
	$pivot/Sketchfab_Scene.visible = false
	if model_scene:
		# 1. Creamos el pivote maestro y lo añadimos a la caja de colisión
		pivot = $pivot
		base_y = pivot.position.y
		
		# 2. Instanciamos tu logo y lo hacemos hijo del pivote
		current_model = model_scene.instantiate()
		pivot.add_child(current_model)
		
		# 3. Aplicamos el desfase local para corregir el origen descentrado
		current_model.position = Vector3(0, -3, -6)

func _process(delta: float) -> void:
	# 4. Toda la matemática de movimiento se aplica al pivote
	if pivot:
		time_passed += delta
		pivot.rotation.y += rotation_speed * delta
		pivot.position.y = base_y + (sin(time_passed * float_speed) * float_height)

func _on_body_entered(body: Node3D) -> void:
	if can_trigger and body.name == "Car":
		can_trigger = false
		OS.shell_open(url_to_open)
		
		# Ocultamos el pivote entero
		if pivot:
			pivot.visible = false

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Car":
		can_trigger = true
		
		if pivot:
			pivot.visible = true
