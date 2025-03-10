extends RigidBody2D
@export var PowerUp : PackedScene
@export var ExplosionScene : PackedScene
@export var MobBullet : PackedScene

const powerup_chance = .1
var time_elapsed = 0
var movement_type = 0 
var original_x = 0
var amplitude = 100 
var frequency = 2 
var base_velocity = Vector2.ZERO
var can_shoot = false
var shoot_cooldown = 2.0 
var shoot_timer = 0.0

# New variables for swim mob movement
var swim_phase = 0  # 0 = initial descent, 1 = side-to-side, 2 = final descent
var swim_phase_timer = 0.0
var initial_descent_time = 1.0  # Time for initial descent
var side_to_side_time = 3.0  # Time for side-to-side movement
var side_movement_direction = 1  # 1 for right, -1 for left
var side_movement_amplitude = 0  # Will be randomized for each side-to-side movement
var side_movement_time = 0  # Time for each direction change
var direction_change_timer = 0  # Timer for changing directions

func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	var selected_animation = mob_types[randi() % mob_types.size()]
	$AnimatedSprite2D.play(selected_animation)
	
	# Set ability to shoot based on animation type
	can_shoot = (selected_animation == "swim")
	
	add_to_group("mob")
	
	# If it's a swim type, set movement_type to 3, otherwise random between 0-2
	if can_shoot:
		movement_type = 3  # Special movement for swim mobs
		# Randomize side movement direction
		side_movement_direction = 1 if randf() > 0.5 else -1
		# Initialize random side movement values
		randomize_side_movement()
	else:
		movement_type = randi() % 3
	
	original_x = position.x
	amplitude = randf_range(50, 150)
	frequency = randf_range(1, 3)
	
	base_velocity = linear_velocity

# Function to randomize side movement parameters
func randomize_side_movement():
	side_movement_amplitude = randf_range(80, 200)  # Random amplitude
	side_movement_time = randf_range(0.5, 1.2)      # Random time before changing direction
	side_movement_direction = 1 if randf() > 0.5 else -1  # Random initial direction

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
		3:  # Special movement for swim mobs
			swim_phase_timer += state.step
			
			if swim_phase == 0:  # Initial descent
				# Just move down
				velocity.x = 0
				if swim_phase_timer >= initial_descent_time:
					swim_phase = 1
					swim_phase_timer = 0.0
					randomize_side_movement()  # Set initial random movement
			elif swim_phase == 1:  # Side-to-side movement
				# Update direction change timer
				direction_change_timer += state.step
				
				# If it's time to change direction, do so and reset timer
				if direction_change_timer >= side_movement_time:
					direction_change_timer = 0
					side_movement_direction *= -1  # Reverse direction
					# Get new random values for next movement
					side_movement_amplitude = randf_range(80, 200)
					side_movement_time = randf_range(0.5, 1.2)
				
				# Apply horizontal movement with current amplitude
				velocity.x = side_movement_direction * side_movement_amplitude
				
				# Only slight downward movement during this phase
				velocity.y = base_velocity.y * 0.3
				
				if swim_phase_timer >= side_to_side_time:
					swim_phase = 2
					swim_phase_timer = 0.0
			else:  # Final descent
				# Continue downward with slight side movement
				velocity.x = cos(time_elapsed * frequency) * amplitude * 0.5
	
	state.linear_velocity = velocity
	
	# Handle shooting
	if can_shoot and MobBullet:
		shoot_timer += state.step
		if shoot_timer >= shoot_cooldown:
			shoot()
			shoot_timer = 0.0

func shoot():
	if MobBullet:
		var bullet = MobBullet.instantiate()
		bullet.position = position + Vector2(0, 30)  # Spawn in front of the mob
		bullet.direction = Vector2.DOWN
		bullet.speed = linear_velocity.length() * 1.8  # Slightly faster than the mob
		get_parent().add_child(bullet)

func hit():
	$CollisionShape2D.set_deferred("disabled", true)
	
	# explosion
	var explosion = ExplosionScene.instantiate() 
	explosion.position = position
	get_parent().add_child(explosion)
	
	# Chance for power-up
	if PowerUp and randf() < powerup_chance:
		var powerup = PowerUp.instantiate()
		powerup.position = position
		powerup.powerup_collected.connect(get_parent()._on_powerup_collected)
		get_parent().call_deferred("add_child", powerup)
	
	hide()
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
