extends Control

func _ready():
	$MenuBox/NewGame.pressed.connect(_on_new_game_pressed)
	$MenuBox/Continue.pressed.connect(_on_continue_pressed)
	$MenuBox/Options.pressed.connect(_on_options_pressed)
	$MenuBox/Quit.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	print("Starting new game...")
	# Replace this with your main game scene once created
	get_tree().change_scene_to_file("res://scenes/look_screen.tscn")


func _on_continue_pressed():
	print("Continue not implemented yet!")

func _on_options_pressed():
	print("Options not implemented yet!")

func _on_quit_pressed():
	get_tree().quit()
