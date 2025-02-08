extends Node

@export var mob_scene: PackedScene
var score = 0
var highscore = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")

func updatehighscorefunc (score):
	if score >= highscore:
		highscore = score
	$HUD.update_highscore(highscore)



func _on_bullet_mob_hit():
	score += 1
	$HUD.update_score(score)
	updatehighscorefunc(score)



func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	
	
	mob.position = Vector2(randf_range(0, screen_size.x), -50)
	
	
	mob.rotation = PI/2
	
	
	var speed = randf_range(200.0, 600.0)
	mob.linear_velocity = Vector2(0, speed)
	
	
	mob.set_physics_process(true)
	
	add_child(mob)
