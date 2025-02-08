extends Area2D
signal hit
@export var Bullet : PackedScene
@export var speed = 400 
var screen_size 

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

func shoot():
	if visible:
		var b = Bullet.instantiate()
		owner.add_child(b)
		b.transform = $Muzzle.global_transform
		b.mob_hit.connect(owner._on_bullet_mob_hit)

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
	hide() 
	hit.emit()
	
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
