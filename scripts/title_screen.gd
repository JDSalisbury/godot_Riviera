extends Control

func _ready():
	$MenuBox/NewGame.pressed.connect(_on_new_game_pressed)
	$MenuBox/Continue.pressed.connect(_on_continue_pressed)
	$MenuBox/Options.pressed.connect(_on_options_pressed)
	$MenuBox/Quit.pressed.connect(_on_quit_pressed)
	$MenuBox/Continue.disabled = not FileAccess.file_exists(SaveSystem.SAVE_PATH)

func _on_new_game_pressed():
	print("Starting new game...")
	GameState.reset_game()
	get_tree().change_scene_to_file("res://scenes/look_screen.tscn")

func _on_continue_pressed():
	if FileAccess.file_exists(SaveSystem.SAVE_PATH):
		print("Loading saved game...")
		var data = SaveSystem.load_game()
		GameState.apply_loaded_data(data)
		get_tree().change_scene_to_file("res://scenes/look_screen.tscn")
	else:
		print("No saved game found.")
		DialogSystem.show_message("No save found!")

func _on_options_pressed():
	print("Options not implemented yet!")

func _on_quit_pressed():
	get_tree().quit()
