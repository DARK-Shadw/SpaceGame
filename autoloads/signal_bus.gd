extends Node

signal universe_seed_changed(new_seed: int)
signal system_changed(system_index: int)
signal planet_selected(planet_data: PlanetData)
signal planet_entered(planet_data: PlanetData)
signal planet_exited()
