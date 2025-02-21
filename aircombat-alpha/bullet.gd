extends Area2D
@export var ExplosionScene : PackedScene

var speed = 750
signal mob_hit
func _physics_process(delta):
	position -= transform.y * speed * delta

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print("Collision detected with: ", body.name) 
	if body.is_in_group("mob"):
		mob_hit.emit()
		
		
		body.hit()
	queue_free()
