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
