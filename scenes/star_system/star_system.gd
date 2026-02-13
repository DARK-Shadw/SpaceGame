extends Node3D

const StarBodyScene: PackedScene = preload("res://scenes/star/star_body.tscn")
const PlanetBodyScene: PackedScene = preload("res://scenes/planet/planet_body.tscn")

@onready var star_container: Node3D = $StarContainer
@onready var planet_container: Node3D = $PlanetContainer


func _ready() -> void:
	_generate_system()


func _generate_system() -> void:
	var system_seed := GameManager.get_current_system_seed()
	var system_data := StarSystemGenerator.generate(system_seed)

	# Spawn star
	var star_body := StarBodyScene.instantiate()
	star_container.add_child(star_body)
	star_body.configure(system_data.star)

	# Spawn planets
	for planet_data in system_data.planets:
		var planet_body := PlanetBodyScene.instantiate()
		planet_container.add_child(planet_body)
		planet_body.configure(planet_data)

	print("Star system generated | seed: %d | planets: %d" % [system_seed, system_data.planets.size()])
