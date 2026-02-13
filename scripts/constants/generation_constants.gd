class_name GenerationConstants
extends RefCounted

# Planet count range per system
const MIN_PLANETS: int = 2
const MAX_PLANETS: int = 8

# Orbital distance range (units from star center)
const MIN_ORBIT_RADIUS: float = 80.0
const MAX_ORBIT_RADIUS: float = 500.0

# Planet size range (mesh radius)
const MIN_PLANET_RADIUS: float = 5.0
const MAX_PLANET_RADIUS: float = 25.0

# Star defaults
const STAR_RADIUS: float = 30.0
const STAR_LIGHT_ENERGY: float = 8.0
const STAR_LIGHT_RANGE: float = 1500.0

# Placeholder planet colors (8 options)
const PLANET_COLORS: Array[Color] = [
	Color(0.2, 0.5, 0.8),   # Ocean blue
	Color(0.8, 0.4, 0.2),   # Mars red-orange
	Color(0.3, 0.7, 0.3),   # Forest green
	Color(0.7, 0.7, 0.5),   # Sandy tan
	Color(0.5, 0.3, 0.6),   # Purple haze
	Color(0.6, 0.8, 0.9),   # Ice blue
	Color(0.8, 0.6, 0.3),   # Desert gold
	Color(0.4, 0.4, 0.5),   # Rocky gray
]

# Placeholder star colors
const STAR_COLORS: Array[Color] = [
	Color(1.0, 0.95, 0.8),  # Yellow-white (G-type)
	Color(1.0, 0.8, 0.5),   # Orange (K-type)
	Color(1.0, 0.6, 0.4),   # Red-orange (M-type)
	Color(0.8, 0.85, 1.0),  # Blue-white (A-type)
	Color(1.0, 1.0, 0.9),   # White (F-type)
]

# Biome types (placeholder for Stage 4)
const BIOME_COUNT: int = 8
