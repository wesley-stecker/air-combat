extends Area2D
signal hit
@export var Bullet : PackedScene
@export var speed = 400 
var screen_size
var can_shoot = true 
var shoot_delay = .25
var is_holding = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

func shoot():
	if visible and can_shoot:
		var b = Bullet.instantiate()
		owner.add_child(b)
		b.transform = $Muzzle.global_transform
		b.mob_hit.connect(owner._on_bullet_mob_hit)
		if is_holding:
			can_shoot = false  # Prevent shooting until delay is over
			await get_tree().create_timer(shoot_delay).timeout
			can_shoot = true  # Allow shooting again

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
		
		if Input.is_action_just_pressed("shoot"):
			is_holding = false
			shoot()
		elif Input.is_action_pressed("shoot"):
			is_holding = true
			if can_shoot:
				shoot()
		else:
			is_holding = false
			can_shoot = true
			
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
	hide() 
	hit.emit()
	
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
