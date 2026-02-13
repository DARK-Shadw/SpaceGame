extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var omni_light: OmniLight3D = $OmniLight3D


func configure(data: StarData) -> void:
	# Mesh
	var sphere := SphereMesh.new()
	sphere.radius = data.radius
	sphere.height = data.radius * 2.0
	mesh_instance.mesh = sphere

	# Emissive material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = data.color
	mat.emission_enabled = true
	mat.emission = data.color
	mat.emission_energy_multiplier = 2.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = mat

	# Light
	omni_light.light_energy = data.light_energy
	omni_light.omni_range = GenerationConstants.STAR_LIGHT_RANGE
	omni_light.omni_attenuation = 0.5
	omni_light.light_color = data.color
