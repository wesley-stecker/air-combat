extends RigidBody2D

func hit():
	# Disable collision to prevent multiple hits
	$CollisionShape2D.set_deferred("disabled", true)
	# Hide the mob
	hide()
	# Then queue_free after a short delay
	await get_tree().create_timer(0.2).timeout
	queue_free()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])
	add_to_group("mob")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
