class_name SeedManager
extends RefCounted

## Derives a child seed from a parent seed and a key.
## Uses Godot's built-in hash() which is deterministic within a session.
static func derive_seed(parent_seed: int, key: Variant) -> int:
	return hash([parent_seed, key])


## Derives a star system seed from the universe seed and system index.
static func get_system_seed(universe_seed: int, system_index: int) -> int:
	return derive_seed(universe_seed, system_index)


## Derives a star seed from its parent system seed.
static func get_star_seed(system_seed: int) -> int:
	return derive_seed(system_seed, "star")


## Derives a planet seed from its parent system seed and planet index.
static func get_planet_seed(system_seed: int, planet_index: int) -> int:
	return derive_seed(system_seed, planet_index)


## Creates a seeded RandomNumberGenerator. Caller uses it then discards it.
static func create_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng
