class_name SpriteRenderer
extends Node2D

var sprite: Sprite2D
var animated_sprite: AnimatedSprite2D

const PAWN_TILESHEET = "res://assets/tiles/pawns_32x32_tilesheet.png"
const SPRITE_SIZE = 32 # Size of each sprite in the tilesheet

func _init(use_animated = false):
	if use_animated:
		animated_sprite = AnimatedSprite2D.new()
		add_child(animated_sprite)
		animated_sprite.z_index = 10 # High value to ensure it's on top
	else:
		sprite = Sprite2D.new()
		add_child(sprite)
		sprite.z_index = 10 # High value to ensure it's on top
	
	# Ensure it renders above terrain
	z_index = 10

func _ready():
	print("SpriteRenderer initialized!")

func set_texture(texture_path):
	if sprite:
		sprite.texture = load(texture_path)

func set_sprite_frames(frames):
	if animated_sprite:
		animated_sprite.sprite_frames = frames

func play_animation(anim_name):
	if animated_sprite:
		animated_sprite.play(anim_name)

func stop_animation():
	if animated_sprite:
		animated_sprite.stop()

func randomize_appearance_from_tilesheet():
	# Load the tilesheet
	var tilesheet = load(PAWN_TILESHEET)
	
	if sprite and tilesheet:
		sprite.texture = tilesheet
		sprite.visible = true
		
		# Enable region for selecting a specific sprite from the sheet
		sprite.region_enabled = true
		
		# Generate random sprite index (0-14 as you reserved)
		var random_index = randi() % 15
		
		# Calculate only the x position since all sprites are in the first row
		var x_pos = random_index * SPRITE_SIZE
		
		# Set the region to display only that sprite
		sprite.region_rect = Rect2(x_pos, 0, SPRITE_SIZE, SPRITE_SIZE)
		print("sprite.region_rect: ", sprite.region_rect)
		
		return random_index
	
	return 0


#func randomize_appearance_from_sprite():
	# Load a single sprite instead of a tilesheet
#	var single_sprite = load("res://assets/tiles/pawns_32x32_sprite.png") # Path to your 32x32 PNG
	
#	if sprite and single_sprite:
#		sprite.texture = single_sprite
#		sprite.visible = true
		
		# No need for region since we're using a single sprite
#		sprite.region_enabled = false
		
		# For debugging
#		print("Sprite loaded with dimensions: ", single_sprite.get_size())
#		print("Sprite position: ", sprite.global_position)
#		print("Sprite scale: ", sprite.scale)
		
#		return 0 # Since we're not selecting from multiple sprites
	
#	return 0
