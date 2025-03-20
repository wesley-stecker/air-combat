extends Node2D

func _ready():
	# Get all available explosion animations
	var explosion_animations = ["explode", "explode1", "explode2"]
	
	# Pick a random animation from the available ones
	var random_explosion = explosion_animations[randi() % explosion_animations.size()]
	
	# Play the randomly selected animation once
	$AnimatedSprite2D.play(random_explosion)
	
	# Connect to the animation_finished signal
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
