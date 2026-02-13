extends Node

var universe_seed: int = 12345
var current_system_index: int = 0
var selected_ship_model: String = "res://assets/models/Spaceships/craft_speederA.glb"
var current_planet_data: PlanetData = null


func set_universe_seed(new_seed: int) -> void:
	universe_seed = new_seed
	SignalBus.universe_seed_changed.emit(new_seed)


func get_current_system_seed() -> int:
	return SeedManager.get_system_seed(universe_seed, current_system_index)


func get_planet_seed(planet_index: int) -> int:
	return SeedManager.get_planet_seed(get_current_system_seed(), planet_index)


func travel_to_system(system_index: int) -> void:
	current_system_index = system_index
	SignalBus.system_changed.emit(system_index)
