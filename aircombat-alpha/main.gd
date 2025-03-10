# Add these variables to main.gd
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
var lives = 3

# Level system variables
var current_level = 1
var max_level = 5
var level_score_thresholds = [10, 25, 50, 80, 120]  # Score needed to reach each level
var level_speed_multipliers = [1.0, 1.3, 1.7, 2.2, 3.0]  # Speed multiplier for each level
var level_spawn_time_multipliers = [1.0, 0.9, 0.8, 0.7, 0.6]  # Lower = faster spawning
var mob_shoot_cooldown_multipliers = [1.0, 0.9, 0.8, 0.7, 0.6]  # Lower = more shooting

# Level-specific mob attributes
var level_mob_attributes = {
	1: {
		"min_speed_range": [100, 150],
		"max_speed_range": [150, 200],
		"shoot_cooldown_range": [2.0, 3.0],
		"spawn_time": 1.5
	},
	2: {
		"min_speed_range": [150, 200],
		"max_speed_range": [200, 250],
		"shoot_cooldown_range": [1.8, 2.7],
		"spawn_time": 1.3
	},
	3: {
		"min_speed_range": [200, 250],
		"max_speed_range": [250, 320],
		"shoot_cooldown_range": [1.5, 2.3],
		"spawn_time": 1.1
	},
	4: {
		"min_speed_range": [250, 320],
		"max_speed_range": [320, 400],
		"shoot_cooldown_range": [1.2, 2.0],
		"spawn_time": 0.9
	},
	5: {
		"min_speed_range": [300, 400],
		"max_speed_range": [400, 500],
		"shoot_cooldown_range": [0.8, 1.5],
		"spawn_time": 0.7
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.hit.connect(game_over)
	print("Player hit signal connected")
	# Update MobTimer interval based on current level
	update_mob_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $ScoreTimer.is_stopped() == false:
		game_time += delta
		
		# Check for level progression
		check_level_progression()

# Check if player has reached score threshold for next level
func check_level_progression():
	if current_level < max_level:
		if score >= level_score_thresholds[current_level - 1]:
			level_up()

# Handle level up
func level_up():
	current_level += 1
	
	# Show level up message
	$HUD.show_message("Level " + str(current_level) + "!")
	
	# Update mob spawning rate
	update_mob_timer()

# Update mob timer wait time based on current level
func update_mob_timer():
	var spawn_time = level_mob_attributes[current_level]["spawn_time"]
	$MobTimer.wait_time = spawn_time

func game_over():
	lives -= 1
	
	if lives <= 0:
		$ScoreTimer.stop()
		$MobTimer.stop()
		$HUD.show_game_over()
	else:
		$Player.start($StartPosition.position)
		$HUD.update_lives(lives)
		$HUD.show_message("Lives: " + str(lives))
		$Player.start_invulnerability(2.0)

func new_game():
	score = 0
	game_time = 0
	lives = 3
	current_level = 1  # Reset level
	update_mob_timer()  # Reset mob spawn timer
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_lives(lives)
	$HUD.show_message("Get Ready")

func updatehighscorefunc(score):
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
	
	# Get current level attributes
	var level_data = level_mob_attributes[current_level]
	
	# Set random speed within level range
	var min_speed = randf_range(level_data["min_speed_range"][0], level_data["min_speed_range"][1])
	var max_speed = randf_range(level_data["max_speed_range"][0], level_data["max_speed_range"][1])
	var speed = randf_range(min_speed, max_speed)
	mob.linear_velocity = Vector2(0, speed)
	
	# Set random shoot cooldown for this mob based on level
	if mob.has_method("shoot"):  # Check if mob can shoot
		var min_cooldown = level_data["shoot_cooldown_range"][0]
		var max_cooldown = level_data["shoot_cooldown_range"][1]
		mob.shoot_cooldown = randf_range(min_cooldown, max_cooldown)
	
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
