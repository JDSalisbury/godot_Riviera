extends Control

var screens = {}
var current_screen = "start"
var option_interactions := {}

func _ready():

	load_screen_data()
	connect_trigger_buttons()
	load_screen(GameState.current_screen)

	
func _unhandled_input(event):
	if event.is_action_pressed("ui_inventory"):
		$InventoryPopup.toggle()
		
	if $ChoiceBox.visible:
		return  # Block movement while choosing

	if event.is_action_pressed("ui_left"):
		trigger_left()
	elif event.is_action_pressed("ui_right"):
		trigger_right()
	elif event.is_action_pressed("ui_up"):
		trigger_up()
	elif event.is_action_pressed("ui_down"):
		trigger_down()
	elif event.is_action_pressed("ui_inspect"):
		trigger_inspect()


func fade_to_black(callback: Callable):
	var fade = $ScreenFade
	fade.show()
	fade.color.a = 0.0
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.4)
	tween.tween_callback(callback)
	tween.tween_property(fade, "color:a", 0.0, 0.4)
	tween.tween_callback(func(): fade.hide())

func update_tp_bar():
	$TPBar.update_tp(GameState.trigger_points, GameState.max_trigger_points)

func load_screen_data():
	var file = FileAccess.open("res://data/screens.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		screens = JSON.parse_string(content)
		if typeof(screens) != TYPE_DICTIONARY:
			push_error("Failed to parse screen data from JSON.")
	else:
		push_error("Could not open screens.json")

func connect_trigger_buttons():
	$TriggerButtons/LeftButton.pressed.connect(trigger_left)
	$TriggerButtons/RightButton.pressed.connect(trigger_right)
	$TriggerButtons/UpButton.pressed.connect(trigger_up)
	$TriggerButtons/DownButton.pressed.connect(trigger_down)
	$TriggerButtons/InspectButton.pressed.connect(trigger_inspect)
	
func set_direction_buttons_visible(visible: bool):
	$TriggerButtons/LeftButton.visible = visible and is_trigger_visible("left")
	$TriggerButtons/RightButton.visible = visible and is_trigger_visible("right")
	$TriggerButtons/UpButton.visible = visible and is_trigger_visible("up")
	$TriggerButtons/DownButton.visible = visible and is_trigger_visible("down")


func is_trigger_visible(dir: String) -> bool:
	var trigger_data = screens[current_screen]["triggers"].get(dir, null)
	var item_unlocks = screens[current_screen].get("key_item_unlocks", {})
	var has_all_items := true

	if item_unlocks.has(dir):
		var required_items = item_unlocks[dir]
		for item in required_items:
			if item not in GameState.inventory["key"]:
				has_all_items = false
				break

		if has_all_items and not GameState.has_shown_key_item_unlock(current_screen, dir):
			GameState.mark_key_item_unlock(current_screen, dir)
			DialogSystem.show_message("You feel something shift...")

		if not has_all_items:
			return false  # Don't show if items aren't met

	if trigger_data == null:
		return GameState.is_unlocked(current_screen, dir)

	if trigger_data.has("hidden") and trigger_data["hidden"]:
		return GameState.is_unlocked(current_screen, dir)

	return true


func load_screen(screen_name: String):
	$DialogBox.clear()

	if not screens.has(screen_name):
		push_error("Unknown screen: " + screen_name)
		return

	current_screen = screen_name
	GameState.current_screen = screen_name  # 🔧 Sync with GameState

	var data = screens[screen_name]
	option_interactions.clear()

	$Background.texture = load(data["background"])
	
	update_tp_bar()
	set_direction_buttons_visible(true)
	$TriggerButtons/LeftButton.visible = is_trigger_visible("left")
	$TriggerButtons/RightButton.visible = is_trigger_visible("right")
	$TriggerButtons/UpButton.visible = is_trigger_visible("up")
	$TriggerButtons/DownButton.visible = is_trigger_visible("down")
	$TriggerButtons/InspectButton.visible = is_trigger_visible("inspect")

func trigger_left(): handle_trigger("left")
func trigger_right(): handle_trigger("right")
func trigger_up(): handle_trigger("up")
func trigger_down(): handle_trigger("down")
func trigger_inspect(): handle_trigger("inspect")

func handle_trigger(direction: String):
	var screen_data = screens.get(current_screen, {})
	var trigger_data = screen_data.get("triggers", {}).get(direction, {})

	if trigger_data.has("options"):
		set_direction_buttons_visible(false)

		var options = trigger_data["options"]
		$ChoiceBox.show_options(
			trigger_data.get("message", "Choose an option:"),
			options,
			current_screen,
			func(option_data):
				# Check if this was a one-time choice already used
				if option_data.get("once", false) and GameState.has_used_option(current_screen, option_data.label):
					$DialogBox.show_message("You've already done that.")
					return

				var cost = option_data.get("tp_cost", 0)
				if GameState.trigger_points < cost:
					$DialogBox.show_message("Not enough TP to do that.")
					return

				GameState.trigger_points -= cost
				update_tp_bar()

				# Mark one-time use
				if option_data.get("once", false):
					GameState.mark_option_used(current_screen, option_data.label)

				# Show message
			# Count how many times this option has been used
				var label = option_data["label"]
				if not option_interactions.has(label):
					option_interactions[label] = 0
				option_interactions[label] += 1
				var count = option_interactions[label]

				# Show alternate message based on count
				var alt_message = null
				var alt_data = null
				if option_data.has("additional_message"):
					alt_data = option_data["additional_message"].get(str(count), null)
					if alt_data and alt_data.has("message"):
						alt_message = alt_data["message"]


				# Optional override of TP cost or behavior
				if alt_data and alt_data.has("tp_cost"):
					var override_cost = int(alt_data["tp_cost"])
					if GameState.trigger_points < override_cost:
						$DialogBox.show_message("Not enough TP to do that.")
						return
					GameState.trigger_points -= override_cost
					update_tp_bar()

				# Handle possible next_screen override
				if alt_data and alt_data.has("next_screen"):
					await get_tree().create_timer(1.5).timeout
					$ChoiceBox.hide()
					fade_to_black(func():
						load_screen(alt_data["next_screen"])
					)
					return

				# Show the message
				if alt_message:
					$DialogBox.show_message(alt_message)
				elif option_data.has("message"):
					$DialogBox.show_message(option_data["message"])


				# Grant TP
				if option_data.has("grants_tp"):
					GameState.trigger_points += option_data["grants_tp"]
					update_tp_bar()

				# Unlock direction
				if option_data.has("unlocks_direction"):
					GameState.unlock_direction(current_screen, option_data["unlocks_direction"])

				# Grant item
				if option_data.has("grants_item"):
					var item = option_data["grants_item"]
					GameState.add_item(item["id"], item["type"])

				# Change screen
				if option_data.has("next_screen"):
					await get_tree().create_timer(1.5).timeout
					$ChoiceBox.hide()
					fade_to_black(func():
						load_screen(option_data["next_screen"])
					)

				# Trigger encounter (placeholder)
				if option_data.has("starts_encounter"):
					print("Start encounter:", option_data["starts_encounter"])
				set_direction_buttons_visible(true)

		)
		return

	if trigger_data.has("message"):
		$DialogBox.show_message(trigger_data["message"])

	if trigger_data.has("next_screen"):
		await get_tree().create_timer(1.5).timeout
		$ChoiceBox.hide()
		fade_to_black(func():
			load_screen(trigger_data["next_screen"])
		)
