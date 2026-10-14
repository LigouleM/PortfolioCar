@tool
extends EditorScript

func _run() -> void:
	var root = get_scene()
	if not root:
		print("Abre la escena de la librería primero.")
		return

	var nodos_procesados = 0
	var counter = 1 

	for node in root.get_children():
		var mesh_instance = _find_mesh(node)
		
		if mesh_instance:
			var new_mesh = MeshInstance3D.new()
			new_mesh.mesh = mesh_instance.mesh
			new_mesh.name = "roadTile" + str(counter).pad_zeros(3)
			counter += 1
			
			root.add_child(new_mesh)
			new_mesh.owner = root 
			
			# --- CENTRADO AUTOMÁTICO ---
			# 1. Obtenemos las dimensiones físicas reales de la malla
			var aabb = new_mesh.mesh.get_aabb()
			
			# 2. Desplazamos el nodo en dirección contraria al centro de su geometría.
			# Dejamos la Y en 0 para no alterar la altura del piso.
			new_mesh.position = Vector3(-aabb.get_center().x, 0, -aabb.get_center().z)
			# ---------------------------

			new_mesh.create_trimesh_collision()
			
			for child in new_mesh.get_children():
				child.owner = root
				for subchild in child.get_children():
					subchild.owner = root

			node.queue_free()
			nodos_procesados += 1
			
	print("¡Proceso completado y centrado! Se extrajeron " + str(nodos_procesados) + " mallas.")

func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D: return node
	for child in node.get_children():
		var found = _find_mesh(child)
		if found: return found
	return null
