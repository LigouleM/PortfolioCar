extends Area3D

enum ActionType { ABRIR_PESTANA, ABRIR_POPUP_REACT }
@export var action_type: ActionType = ActionType.ABRIR_PESTANA

@export var url_to_open: String = "https://github.com/tu-usuario"
@export var url_param_key: String = "github"
@export var react_popup_id: String = "sobre_mi"

# Propiedades del Modelo 3D
@export var model_scene: PackedScene 
@export var model_offset: Vector3 = Vector3.ZERO
@export var model_scale: Vector3 = Vector3(1.0, 1.0, 1.0) # Útil para corregir modelos GLTF puros

@export var rotation_speed: float = 1.5
@export var float_speed: float = 3.0
@export var float_height: float = 0.2

var logic_pivot: Node3D # Renombrado para no chocar con el nodo del editor
var current_model: Node3D
var time_passed: float = 0.0
var base_y: float = 0.0
var can_trigger: bool = true

func _ready() -> void:
	# 1. OCULTAMOS LOS PLACEHOLDERS DE FORMA SEGURA
	# Solo los oculta si existen, evitando que el juego se rompa
	if has_node("pivot"):
		$pivot.visible = false
	if has_node("CSGBox3D"):
		$CSGBox3D.visible = false

	if OS.has_feature("web"):
		var js_code = "new URLSearchParams(window.location.search).get('%s');" % url_param_key
		var override_url = JavaScriptBridge.eval(js_code)
		if typeof(override_url) == TYPE_STRING and override_url.length() > 0:
			url_to_open = override_url

	body_exited.connect(_on_body_exited)
	
	# 2. INSTANCIAMOS EL MODELO PARAMÉTRICO
	if model_scene:
		logic_pivot = Node3D.new()
		add_child(logic_pivot)
		base_y = logic_pivot.position.y
		
		current_model = model_scene.instantiate()
		logic_pivot.add_child(current_model)
		
		# Le aplicamos la posición y la escala paramétrica
		current_model.position = model_offset
		current_model.scale = model_scale

func _process(delta: float) -> void:
	if logic_pivot:
		time_passed += delta
		logic_pivot.rotation.y += rotation_speed * delta
		logic_pivot.position.y = base_y + (sin(time_passed * float_speed) * float_height)

func _on_body_entered(body: Node3D) -> void:
	if can_trigger and body.name == "Car":
		can_trigger = false
		
		match action_type:
			ActionType.ABRIR_PESTANA:
				OS.shell_open(url_to_open)
				
			ActionType.ABRIR_POPUP_REACT:
				if OS.has_feature("web"):
					var js_code = "window.parent.postMessage({ type: 'GODOT_POPUP', id: '%s' }, '*');" % react_popup_id
					JavaScriptBridge.eval(js_code)
				else:
					print("Test local: Disparando popup de React con ID -> ", react_popup_id)

		if logic_pivot:
			logic_pivot.visible = false

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Car":
		can_trigger = true
		if logic_pivot:
			logic_pivot.visible = true
