extends Area2D

signal powerup_collected(type)

var speed = 100
var powerup_type = "double_fire_rate"
var duration = 10.0

func _ready():
	$DurationTimer.wait_time = duration

func _physics_process(delta):
	# Move downward slowly
	position.y += speed * delta

func _on_area_entered(area):
	if area.name == "Player":
		powerup_collected.emit(powerup_type)
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
