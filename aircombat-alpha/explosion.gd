extends Node2D
@export var explosion_sound : AudioStream

func _ready():
	# Get all available explosion animations
	var explosion_animations = ["explode", "explode1", "explode2"]
	
	# Pick a random animation from the available ones
	var random_explosion = explosion_animations[randi() % explosion_animations.size()]
	
	# Play the randomly selected animation once
	$AnimatedSprite2D.play(random_explosion)
	
	# Connect to the animation_finished signal
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	
	 # Create audio player for explosion if not already in scene
	if !has_node("ExplosionSound"):
		var audio = AudioStreamPlayer.new()
		audio.name = "ExplosionSound"
		add_child(audio)
	
	# Play explosion sound
	if has_node("ExplosionSound") and explosion_sound:
		$ExplosionSound.stream = explosion_sound
		$ExplosionSound.play()

func _on_animation_finished():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
