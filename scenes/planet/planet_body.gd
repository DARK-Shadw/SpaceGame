extends Node3D

var planet_data: PlanetData

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func configure(data: PlanetData) -> void:
	planet_data = data

	# Position
	position = data.position

	# Mesh
	var sphere := SphereMesh.new()
	sphere.radius = data.radius
	sphere.height = data.radius * 2.0
	mesh_instance.mesh = sphere

	# Material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = data.color
	mesh_instance.material_override = mat
