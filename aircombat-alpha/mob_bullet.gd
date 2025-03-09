extends Area2D

var speed = 200  
var direction = Vector2.DOWN

func _physics_process(delta):
	position += direction * speed * delta

func _ready():
	
	rotation = direction.angle() + PI/2

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	queue_free()

func _on_area_entered(area):
	if area.name == "Player" and not area.invulnerable:
		area.hit.emit()
		queue_free()
