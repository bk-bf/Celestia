## Noise generator class for procedural terrain generation.
## Manages multiple noise layers for different aspects of terrain generation.
##
## Properties:
## - terrain_noise: Primary noise used for basic terrain layout
## - detail_noise: Secondary noise used for terrain subtypes and details
##
## Methods:
## - get_terrain_noise: Returns the primary terrain noise value at a position
## - get_detail_noise: Returns the secondary detail noise value at a position

class_name NoiseGenerator
extends Node

# Main noise generators
var terrain_noise: FastNoiseLite # For primary terrain types
var detail_noise: FastNoiseLite # For terrain details and subtypes

# Default noise presets
const DEFAULT_TERRAIN_SEED: int = 12345
const DEFAULT_DETAIL_SEED: int = 67890

# Configuration values
const TERRAIN_NOISE_FREQUENCY: float = 0.005
const DETAIL_NOISE_FREQUENCY: float = 0.05
const TERRAIN_OCTAVES: int = 5
const TERRAIN_LACUNARITY: float = 2.0
const TERRAIN_GAIN: float = 0.6

# Initialize noise generators with specified or default seeds
func _init(terrain_seed: int = DEFAULT_TERRAIN_SEED, detail_seed: int = DEFAULT_DETAIL_SEED) -> void:
    initialize_terrain_noise(terrain_seed)
    initialize_detail_noise(detail_seed)

# Initialize the primary terrain noise generator
func initialize_terrain_noise(seed_value: int) -> void:
    terrain_noise = FastNoiseLite.new()
    terrain_noise.seed = seed_value
    terrain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    terrain_noise.frequency = TERRAIN_NOISE_FREQUENCY
    terrain_noise.fractal_octaves = TERRAIN_OCTAVES # More detail layers
    terrain_noise.fractal_lacunarity = TERRAIN_LACUNARITY
    terrain_noise.fractal_gain = TERRAIN_GAIN # Stronger features

# Initialize the secondary detail noise generator
func initialize_detail_noise(seed_value: int) -> void:
    detail_noise = FastNoiseLite.new()
    detail_noise.seed = seed_value
    detail_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    detail_noise.frequency = DETAIL_NOISE_FREQUENCY # Higher frequency for smaller details

# Get the terrain noise value at a specific position
func get_terrain_noise(x: float, y: float) -> float:
    return terrain_noise.get_noise_2d(x, y)

# Get the detail noise value at a specific position
func get_detail_noise(x: float, y: float) -> float:
    return detail_noise.get_noise_2d(x, y)

# Create a domain-warped version of the terrain noise for specialized features
func get_warped_noise(x: float, y: float, warp_amount: float = 30.0) -> float:
    # Calculate warping offset based on a different noise
    var warp_x = detail_noise.get_noise_2d(x + 500, y + 500) * warp_amount
    var warp_y = detail_noise.get_noise_2d(x - 500, y - 500) * warp_amount

    # Sample the main noise at the warped coordinates
    return terrain_noise.get_noise_2d(x + warp_x, y + warp_y)

# Get combined noise for terrain features (useful for rivers, ridges, etc.)
func get_combined_noise(x: float, y: float, weight: float = 0.5) -> float:
    var t_noise = get_terrain_noise(x, y)
    var d_noise = get_detail_noise(x, y)

    # Linear interpolation between terrain and detail noise
    return t_noise * (1.0 - weight) + d_noise * weight

# Get ridged noise (useful for mountains, ridges)
func get_ridged_noise(x: float, y: float) -> float:
    var noise = get_terrain_noise(x, y)
    return 1.0 - abs(noise) # Convert to ridged noise

# Get terrace noise (useful for plateau terrain)
func get_terrace_noise(x: float, y: float, steps: int = 5) -> float:
    var noise = get_terrain_noise(x, y)
    var normalized = (noise + 1.0) / 2.0 # Convert from -1..1 to 0..1

    # Create terraces
    var stepped = floor(normalized * steps) / steps

    # Convert back to -1..1 range
    return stepped * 2.0 - 1.0