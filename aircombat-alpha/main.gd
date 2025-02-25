extends Node

@export var mob_scene: PackedScene
var score = 0
var highscore = 0
var game_time = 0
var base_min_speed = 100.0
var base_max_speed = 200.0
var max_speed_increase = 400.0
var powerup_active = false
var original_shoot_cooldown = 0.5
var triple_shot_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $ScoreTimer.is_stopped() == false:
		game_time += delta


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	game_time = 0
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
	
	
	var speed_increase = min(game_time * 10, max_speed_increase)
	var min_speed = base_min_speed + speed_increase
	var max_speed = base_max_speed + speed_increase
	
	var speed = randf_range(min_speed, max_speed)
	mob.linear_velocity = Vector2(0, speed)
	
	mob.set_physics_process(true)
	add_child(mob)


func _on_powerup_collected(type):
	if type == "double_fire_rate":
		activate_double_fire_rate()
	elif type == "triple_shot":
		activate_triple_shot()

func activate_double_fire_rate():
	
	if !powerup_active:
		original_shoot_cooldown = $Player.shoot_cooldown
	
	
	powerup_active = true
	
	
	$Player.shoot_cooldown = original_shoot_cooldown / 2
	
	
	var timer = get_tree().create_timer(10.0)
	await timer.timeout
	
	
	if powerup_active:
		$Player.shoot_cooldown = original_shoot_cooldown
		powerup_active = false
		
func activate_triple_shot():
	#State
	triple_shot_active = true
	
	
	$Player.triple_shot_active = true
	
	# duration
	var timer = get_tree().create_timer(10.0)
	await timer.timeout
	
	# Disable after its done
	if triple_shot_active:
		$Player.triple_shot_active = false
		triple_shot_active = false
