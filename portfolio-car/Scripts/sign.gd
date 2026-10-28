@tool
extends Node3D

enum ArrowDir { NINGUNA, IZQUIERDA, DERECHA, ABAJO }

# El "set(value)" hace que la función _update_boards() se ejecute 
# instantáneamente cada vez que cambias algo en el Inspector.
@export_multiline var text_left: String = "Proyectos":
	set(value):
		text_left = value
		_update_boards()

@export var arrow_left: ArrowDir = ArrowDir.NINGUNA:
	set(value):
		arrow_left = value
		_update_boards()

@export_multiline var text_right: String = "Sobre Mí":
	set(value):
		text_right = value
		_update_boards()

@export var arrow_right: ArrowDir = ArrowDir.NINGUNA:
	set(value):
		arrow_right = value
		_update_boards()
		
@export var text_size: int = 32:
	set(value):
		text_size = value
		_update_boards()

@onready var rightSign: Label3D = $"sign-highway/RightSign"
@onready var leftSign: Label3D = $"sign-highway/LeftSign"


func _ready() -> void:
	_update_boards()

func _update_boards() -> void:
	# Evita errores cuando el editor carga la escena por primera vez
	if not is_node_ready():
		return
		
	leftSign.text = _format_text(text_left, arrow_left)
	rightSign.text = _format_text(text_right, arrow_right)
	
	leftSign.font_size = text_size
	rightSign.font_size = text_size

func _format_text(base_text: String, arrow: ArrowDir) -> String:
	match arrow:
		ArrowDir.IZQUIERDA:
			return base_text + "\n←"
		ArrowDir.DERECHA:
			return base_text + "\n→"
		ArrowDir.ABAJO:
			return base_text + "\n↓"
		_:
			return base_text
