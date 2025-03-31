extends Control

var screens = {} # Loaded from screens.json
var current_screen = "start" # Initial screen
var screen_unlocks = {} # Tracks unlocked directions for screens

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

func is_unlocked(direction: String) -> bool:
	if not screen_unlocks.has(current_screen):
		return false
	return direction in screen_unlocks[current_screen]


func is_trigger_visible(dir: String) -> bool:
	var trigger_data = screens[current_screen]["triggers"].get(dir, null)
	if trigger_data == null:
		return is_unlocked(dir)  # Not defined? Only show if unlocked

	if trigger_data.has("hidden") and trigger_data["hidden"]:
		return is_unlocked(dir)  # Hidden? Show only if unlocked

	return true  # Not hidden and exists


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
	# Enable triggers that are in the data or were unlocked by choices
	$TriggerButtons/LeftButton.visible = is_trigger_visible("left")
	$TriggerButtons/RightButton.visible = is_trigger_visible("right")
	$TriggerButtons/UpButton.visible = is_trigger_visible("up")
	$TriggerButtons/InspectButton.visible = is_trigger_visible("inspect")

# Trigger handlers
func trigger_left(): handle_trigger("left")
func trigger_right(): handle_trigger("right")
func trigger_up(): handle_trigger("up")
func trigger_inspect(): handle_trigger("inspect")

func unlock_direction(screen: String, direction: String):
	if not screen_unlocks.has(screen):
		screen_unlocks[screen] = []
	if direction not in screen_unlocks[screen]:
		screen_unlocks[screen].append(direction)


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

				if option_data.has("unlocks_direction"):
					var dir = option_data["unlocks_direction"]
					unlock_direction(current_screen, dir)
					load_screen(current_screen)  # Reload to refresh button visibility

		)
		return

	if trigger_data.has("message"):
		$DialogBox.show_message(trigger_data["message"])

	if trigger_data.has("next_screen"):
		await get_tree().create_timer(1.5).timeout
	
		$ChoiceBox.hide()
		load_screen(trigger_data["next_screen"])
