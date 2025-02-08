extends RigidBody2D

var time_elapsed = 0
var movement_type = 0 
var original_x = 0
var amplitude = 100 
var frequency = 2 
var base_velocity = Vector2.ZERO

func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])
	add_to_group("mob")
	movement_type = randi() % 3  # Random number between 0 and 2
	original_x = position.x
	amplitude = randf_range(50, 150)
	frequency = randf_range(1, 3)
	# Store the initial vertical velocity
	base_velocity = linear_velocity

func _integrate_forces(state):
	time_elapsed += state.step
	var velocity = base_velocity
	
	match movement_type:
		0:  # Straight line
			pass
		1:  # Sine wave
			velocity.x = cos(time_elapsed * frequency) * amplitude * frequency
		2:  # Zigzag
			var t = fmod(time_elapsed * frequency, 2)
			if t < 1.0:
				velocity.x = amplitude * frequency
			else:
				velocity.x = -amplitude * frequency
	
	state.linear_velocity = velocity

func hit():
	$CollisionShape2D.set_deferred("disabled", true)
	hide()
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
