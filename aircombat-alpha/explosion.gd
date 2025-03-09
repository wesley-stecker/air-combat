extends Node2D

func _ready():
	# Play the animation once
	$AnimatedSprite2D.play("explode")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
