# NoiseGenerator.gd
extends Node
class_name NoiseGenerator

var terrain_noise: FastNoiseLite
var detail_noise: FastNoiseLite

func _init(terrain_seed: int = 12345, detail_seed: int = 67890):
	# First-tier noise for terrain clusters
	terrain_noise = FastNoiseLite.new()
	terrain_noise.seed = terrain_seed
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	terrain_noise.frequency = 0.01  # Lower frequency for larger features
	
	# Second-tier noise for terrain subtypes within terrain
	detail_noise = FastNoiseLite.new()
	detail_noise.seed = detail_seed
	detail_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	detail_noise.frequency = 0.05  # Higher frequency for smaller details
	
func get_terrain_noise(x: float, y: float) -> float:
	return terrain_noise.get_noise_2d(x, y)
	
func get_detail_noise(x: float, y: float) -> float:
	return detail_noise.get_noise_2d(x, y)
