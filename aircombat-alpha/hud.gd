extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout

	$Message.text = "Space Combat!"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func update_highscore(highscore):
	$HighScoreLabel.text = str(highscore)

# Update lives display
func update_lives(lives):
	$LivesLabel.text = "Lives: " + str(lives)

# New function to update level display
func update_level(level):
	$LevelLabel.text = "Level: " + str(level)

func _ready() -> void:
	if has_node("LivesLabel"):
		$LivesLabel.text = "Lives: 3"
	
	# Make sure we have a level label
	if has_node("LevelLabel"):
		$LevelLabel.text = "Level: 1"
	else:
		# If there's no level label, create one
		var level_label = Label.new()
		level_label.name = "LevelLabel"
		level_label.text = "Level: 1"
		# Position it appropriately on your HUD
		level_label.position = Vector2(10, 90)  # Adjust position as needed
		add_child(level_label)

func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
