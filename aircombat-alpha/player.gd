extends Area2D
signal hit
@export var Bullet : PackedScene
@export var ExplosionScene : PackedScene
@export var speed = 400 
var screen_size
var can_shoot = true 
var shoot_cooldown = 0.25
var triple_shot_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

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
	if body.is_in_group("mob"):
		# Create explosion
		var explosion = ExplosionScene.instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
		
		hide() 
		hit.emit()
		$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
