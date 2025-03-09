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

func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	var selected_animation = mob_types[randi() % mob_types.size()]
	$AnimatedSprite2D.play(selected_animation)
	
	
	can_shoot = (selected_animation == "swim")
	
	add_to_group("mob")
	movement_type = randi() % 3 
	original_x = position.x
	amplitude = randf_range(50, 150)
	frequency = randf_range(1, 3)
	
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
