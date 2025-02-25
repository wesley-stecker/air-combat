extends Area2D

signal powerup_collected(type)

var speed = 50
var powerup_type = "default"
var duration = 10.0
var possible_types = ["double_fire_rate", "triple_shot"]

func _ready():
	# Random powerup
	powerup_type = possible_types[randi() % possible_types.size()]
	
	# change color of the powerup
	if powerup_type == "triple_shot":
		
		modulate = Color(1, 0.5, 1)  # Purple
	
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
