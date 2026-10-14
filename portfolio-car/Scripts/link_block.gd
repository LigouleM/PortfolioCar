extends Area3D

# Al usar @export, podrás escribir la URL directamente desde el 
# Inspector de Godot sin tener que abrir el código para cada caja distinta.
@export var url_to_open: String = "https://github.com/LigouleM"

func _on_body_entered(body: Node3D) -> void:
	print("Colisión")
	# Verificamos que el objeto que atravesó la caja sea tu auto
	if body.name == "Car":
		print("Autito")
		OS.shell_open(url_to_open)
		
		# Destruimos la caja instantáneamente tras el impacto.
		# Si no haces esto, Godot detectará colisiones continuas en cada frame 
		# mientras el auto la atraviesa y te abrirá docenas de pestañas de golpe.
		queue_free()
