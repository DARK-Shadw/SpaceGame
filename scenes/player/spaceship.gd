extends Node3D

@onready var model_container: Node3D = $ModelContainer
@onready var camera: Camera3D = $ThirdPersonCamera


func _ready() -> void:
	_load_ship_model()
	camera.look_at(global_position)
	camera.current = true


func _load_ship_model() -> void:
	var model_scene: PackedScene = load(GameManager.selected_ship_model)
	if model_scene:
		var model_instance := model_scene.instantiate()
		model_container.add_child(model_instance)
		model_instance.scale = Vector3(5, 5, 5)
		# Center model on visual bounds (fixes off-origin mesh pivot in .glb)
		var center := _get_visual_center(model_instance)
		model_instance.position = -center * model_instance.scale


func _get_visual_center(root: Node3D) -> Vector3:
	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(root, meshes)
	if meshes.is_empty():
		return Vector3.ZERO
	var combined := AABB()
	var first := true
	for mesh in meshes:
		var aabb := mesh.get_aabb()
		# Transform AABB corners from mesh-local space → root-local space
		var xform := root.global_transform.affine_inverse() * mesh.global_transform
		for i in 8:
			var corner := aabb.position + aabb.size * Vector3(
				float(i & 1), float((i >> 1) & 1), float((i >> 2) & 1)
			)
			var p := xform * corner
			if first:
				combined = AABB(p, Vector3.ZERO)
				first = false
			else:
				combined = combined.expand(p)
	return combined.get_center()


func _collect_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		_collect_meshes(child, result)
