class_name StarSystemGenerator
extends RefCounted

## Generates a complete StarSystemData from a system seed.
## Pure function: same seed always produces the same result.
static func generate(system_seed: int) -> StarSystemData:
	var data := StarSystemData.new()
	data.seed_value = system_seed

	# Generate star
	data.star = _generate_star(system_seed)

	# Determine planet count
	var system_rng := SeedManager.create_rng(system_seed)
	var planet_count: int = system_rng.randi_range(
		GenerationConstants.MIN_PLANETS,
		GenerationConstants.MAX_PLANETS
	)

	# Generate planets
	data.planets = []
	for i in range(planet_count):
		var planet := _generate_planet(system_seed, i, planet_count)
		data.planets.append(planet)

	return data


static func _generate_star(system_seed: int) -> StarData:
	var star_seed := SeedManager.get_star_seed(system_seed)
	var rng := SeedManager.create_rng(star_seed)

	var star := StarData.new()
	star.seed_value = star_seed
	star.radius = GenerationConstants.STAR_RADIUS
	star.color = GenerationConstants.STAR_COLORS[
		rng.randi_range(0, GenerationConstants.STAR_COLORS.size() - 1)
	]
	star.light_energy = GenerationConstants.STAR_LIGHT_ENERGY
	return star


static func _generate_planet(system_seed: int, planet_index: int, planet_count: int) -> PlanetData:
	var planet_seed := SeedManager.get_planet_seed(system_seed, planet_index)
	var rng := SeedManager.create_rng(planet_seed)

	var planet := PlanetData.new()
	planet.seed_value = planet_seed
	planet.index = planet_index

	# Orbital distance: divide orbital band into equal slots, jitter within each
	var orbit_range: float = GenerationConstants.MAX_ORBIT_RADIUS - GenerationConstants.MIN_ORBIT_RADIUS
	var slot_size: float = orbit_range / planet_count
	var slot_start: float = GenerationConstants.MIN_ORBIT_RADIUS + slot_size * planet_index
	var jitter_margin: float = slot_size * 0.15  # Keep 15% margin on each side
	planet.orbit_radius = rng.randf_range(slot_start + jitter_margin, slot_start + slot_size - jitter_margin)

	# Random angle on orbit
	planet.orbit_angle = rng.randf() * TAU

	# Convert polar to cartesian on XZ plane
	planet.position = Vector3(
		cos(planet.orbit_angle) * planet.orbit_radius,
		0.0,
		sin(planet.orbit_angle) * planet.orbit_radius
	)

	# Planet size
	planet.radius = rng.randf_range(
		GenerationConstants.MIN_PLANET_RADIUS,
		GenerationConstants.MAX_PLANET_RADIUS
	)

	# Color from palette
	planet.color = GenerationConstants.PLANET_COLORS[
		rng.randi_range(0, GenerationConstants.PLANET_COLORS.size() - 1)
	]

	# Biome type placeholder
	planet.biome_type = rng.randi_range(0, GenerationConstants.BIOME_COUNT - 1)

	return planet
