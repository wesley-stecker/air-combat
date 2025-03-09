extends Area2D
signal hit
@export var Bullet : PackedScene
@export var ExplosionScene : PackedScene
@export var speed = 400 
var screen_size
var can_shoot = true 
var shoot_cooldown = 0.25
var triple_shot_active = false
var invulnerable = false  # Add invulnerability flag

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

func start_invulnerability(duration):
	invulnerable = true
	print("Starting invulnerability for ", duration, " seconds")
	
	# We'll keep the collision shape enabled but use the invulnerable flag
	# This way collisions are still detected but don't trigger the hit effect
	
	# Create a timer for blinking
	var blink_timer = Timer.new()
	blink_timer.wait_time = 0.1
	blink_timer.autostart = true
	blink_timer.one_shot = false
	add_child(blink_timer)
	
	# Connect to timeout signal for blinking
	blink_timer.timeout.connect(func():
		modulate.a = 1.0 if modulate.a < 1.0 else 0.4
	)
	
	# Wait for duration
	await get_tree().create_timer(duration).timeout
	
	# Cleanup
	blink_timer.stop()
	blink_timer.queue_free()
	
	# End invulnerability
	invulnerable = false
	modulate.a = 1.0  # Ensure player is fully visible
	print("Invulnerability ended")

func shoot():
	if visible and can_shoot:
		if triple_shot_active:
			# Create center bullet
			var b1 = Bullet.instantiate()
			owner.add_child(b1)
			b1.transform = $Muzzle.global_transform
			b1.mob_hit.connect(owner._on_bullet_mob_hit)
			
			# left
			var b2 = Bullet.instantiate()
			owner.add_child(b2)
			b2.transform = $Muzzle.global_transform
			b2.rotation += 0.2  # Angle
			b2.mob_hit.connect(owner._on_bullet_mob_hit)
			
			# right
			var b3 = Bullet.instantiate()
			owner.add_child(b3)
			b3.transform = $Muzzle.global_transform
			b3.rotation -= 0.2
			b3.mob_hit.connect(owner._on_bullet_mob_hit)
		else:
			var b = Bullet.instantiate()
			owner.add_child(b)
			b.transform = $Muzzle.global_transform
			b.mob_hit.connect(owner._on_bullet_mob_hit)
		
		# Disable shooting and start cooldown
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		
		# Simplified shooting logic - works the same for pressed or just_pressed
		if Input.is_action_pressed("shoot") and can_shoot:
			shoot()
			
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.stop()
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "up"

func _on_body_entered(body):
	print("Body entered: ", body.name, " - Invulnerable: ", invulnerable)
	
	# Only take damage if not invulnerable
	if body.is_in_group("mob") and !invulnerable:
		print("Player hit by mob")
		# Create explosion
		var explosion = ExplosionScene.instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
		
		hide() 
		# Disable collision while hidden
		$CollisionShape2D.set_deferred("disabled", true)
		hit.emit()
		
func start(pos):
	print("Starting player at position ", pos)
	position = pos
	show()
	
	# Explicitly enable collision - make sure this is actually happening
	$CollisionShape2D.set_deferred("disabled", false)
	$CollisionShape2D.disabled = false  # Try both methods to make sure it takes effect
	
	print("Collision shape status: ", $CollisionShape2D.disabled)
	
	invulnerable = false  # Reset invulnerability state
	modulate.a = 1.0  # Ensure fully visible
