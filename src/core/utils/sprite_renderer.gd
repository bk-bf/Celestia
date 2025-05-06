class_name SpriteRenderer
extends Node2D

var sprite: Sprite2D
var animated_sprite: AnimatedSprite2D

func _init(use_animated = false):
	if use_animated:
		animated_sprite = AnimatedSprite2D.new()
		add_child(animated_sprite)
	else:
		sprite = Sprite2D.new()
		add_child(sprite)
	
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

# Add this to your SpriteRenderer class
func randomize_appearance():
	# Generate a random color with full opacity
	var random_color = Color(
		randf(), # Random red component (0-1)
		randf(), # Random green component (0-1)
		randf(), # Random blue component (0-1)
		1.0 # Full opacity
	)
	
	# Apply the color to the appropriate sprite
	if sprite:
		sprite.modulate = random_color
	elif animated_sprite:
		animated_sprite.modulate = random_color
	
	# Return the color so the Pawn can store it if needed
	return random_color
