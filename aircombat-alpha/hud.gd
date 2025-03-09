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

#to update lives display
func update_lives(lives):
	$LivesLabel.text = "Lives: " + str(lives)

func _ready() -> void:
	if has_node("LivesLabel"):
		$LivesLabel.text = "Lives: 3"

func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
