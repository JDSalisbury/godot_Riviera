extends Control

var screens = {} # Loaded from screens.json
var current_screen = "start" # Initial screen

# Load and connect buttons on ready
func _ready():
	load_screen_data()
	connect_trigger_buttons()
	load_screen(current_screen)

# Load screen data from JSON file
func load_screen_data():
	var file = FileAccess.open("res://data/screens.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		screens = JSON.parse_string(content)
		if typeof(screens) != TYPE_DICTIONARY:
			push_error("Failed to parse screen data from JSON.")
	else:
		push_error("Could not open screens.json")

# Connect button presses to trigger handlers
func connect_trigger_buttons():
	$TriggerButtons/LeftButton.pressed.connect(trigger_left)
	$TriggerButtons/RightButton.pressed.connect(trigger_right)
	$TriggerButtons/UpButton.pressed.connect(trigger_up)
	$TriggerButtons/InspectButton.pressed.connect(trigger_inspect)

# Check if a trigger should be visible (based on hidden flag or GameState unlocks)
func is_trigger_visible(dir: String) -> bool:
	var trigger_data = screens[current_screen]["triggers"].get(dir, null)
	if trigger_data == null:
		return GameState.is_unlocked(current_screen, dir)

	if trigger_data.has("hidden") and trigger_data["hidden"]:
		return GameState.is_unlocked(current_screen, dir)

	return true

# Load the given screen and update UI
func load_screen(screen_name: String):
	if not screens.has(screen_name):
		push_error("Unknown screen: " + screen_name)
		return

	current_screen = screen_name
	var data = screens[screen_name]

	# Update background
	$Background.texture = load(data["background"])

	# Enable/disable trigger buttons
	$TriggerButtons/LeftButton.visible = is_trigger_visible("left")
	$TriggerButtons/RightButton.visible = is_trigger_visible("right")
	$TriggerButtons/UpButton.visible = is_trigger_visible("up")
	$TriggerButtons/InspectButton.visible = is_trigger_visible("inspect")

# Trigger handlers
func trigger_left(): handle_trigger("left")
func trigger_right(): handle_trigger("right")
func trigger_up(): handle_trigger("up")
func trigger_inspect(): handle_trigger("inspect")

# Unified trigger handler
func handle_trigger(direction: String):
	var screen_data = screens.get(current_screen, {})
	var trigger_data = screen_data.get("triggers", {}).get(direction, {})

	if trigger_data.has("options"):
		var options = trigger_data["options"]
		$ChoiceBox.show_options(
			trigger_data.get("message", "Choose an option:"),
			options,
			func(option_data):
				# Show the selected option’s message
				if option_data.has("message"):
					$DialogBox.show_message(option_data["message"])

				# Unlock directions if needed
				if option_data.has("unlocks_direction"):
					var dir = option_data["unlocks_direction"]
					GameState.unlock_direction(current_screen, dir)
					load_screen(current_screen)  # Refresh to show new direction
		)
		return

	if trigger_data.has("message"):
		$DialogBox.show_message(trigger_data["message"])

	if trigger_data.has("next_screen"):
		await get_tree().create_timer(1.5).timeout
		$ChoiceBox.hide()
		load_screen(trigger_data["next_screen"])
