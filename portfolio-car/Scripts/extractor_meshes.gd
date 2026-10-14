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
			# 1. Nombre único para esta pieza
			var unique_name = "roadTile" + str(counter).pad_zeros(3)
			
			# 2. Contenedor exterior (Node3D)
			var item_root = Node3D.new()
			item_root.name = unique_name + "_container"
			root.add_child(item_root)
			item_root.owner = root
			
			# 3. Malla INTERNA (Esta es la que Godot usa como nombre en la librería)
			var new_mesh = MeshInstance3D.new()
			new_mesh.mesh = mesh_instance.mesh
			new_mesh.name = unique_name # ¡AQUÍ ESTABA EL ERROR! Ahora cada malla interna tiene nombre único
			item_root.add_child(new_mesh)
			new_mesh.owner = root 
			
			# 4. Centrado automático
			var aabb = new_mesh.mesh.get_aabb()
			new_mesh.position = Vector3(-aabb.get_center().x, 0, -aabb.get_center().z)
			
			# 5. Colisiones
			new_mesh.create_trimesh_collision()
			
			for child in new_mesh.get_children():
				child.owner = root
				for subchild in child.get_children():
					subchild.owner = root

			# Borramos el original
			node.queue_free()
			nodos_procesados += 1
			counter += 1
			
	print("¡Listo! Se extrajeron " + str(nodos_procesados) + " mallas con nombres únicos.")

func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D: return node
	for child in node.get_children():
		var found = _find_mesh(child)
		if found: return found
	return null
