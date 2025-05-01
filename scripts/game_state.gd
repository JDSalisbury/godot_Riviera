extends Node

# --- Game State Variables ---
var trigger_points: int
var max_trigger_points: int
var current_screen: String
var story_flags: Dictionary
var screen_unlocks: Dictionary
var used_options: Dictionary
var inventory: Dictionary
var key_item_unlocks_shown: Dictionary

# --- Default State Source of Truth ---
func get_default_state() -> Dictionary:
	return {
		"trigger_points": 10,
		"max_trigger_points": 20,
		"current_screen": "start",
		"story_flags": {},
		"screen_unlocks": {},
		"used_options": {},
		"inventory": {
			"key": [],
			"battle": []
		},
		"key_item_unlocks_shown": {}
	}

# --- Save Helpers ---
func to_dict() -> Dictionary:
	var state = {}
	for key in get_default_state().keys():
		state[key] = self.get(key)
	return state

func from_dict(data: Dictionary) -> void:
	var defaults = get_default_state()
	for key in defaults.keys():
		self.set(key, data.get(key, defaults[key]))

func reset_game():
	from_dict(get_default_state())

# --- Game Logic ---
func mark_key_item_unlock(screen: String, direction: String):
	if not key_item_unlocks_shown.has(screen):
		key_item_unlocks_shown[screen] = []
	if direction not in key_item_unlocks_shown[screen]:
		key_item_unlocks_shown[screen].append(direction)

func has_shown_key_item_unlock(screen: String, direction: String) -> bool:
	return key_item_unlocks_shown.has(screen) and direction in key_item_unlocks_shown[screen]

func has_used_option(screen: String, label: String) -> bool:
	return used_options.has(screen) and label in used_options[screen]

func mark_option_used(screen: String, label: String):
	if not used_options.has(screen):
		used_options[screen] = []
	used_options[screen].append(label)

func add_flag(flag: String) -> void:
	story_flags[flag] = true

func has_flag(flag: String) -> bool:
	return story_flags.get(flag, false)

func unlock_direction(screen: String, direction: String):
	if not screen_unlocks.has(screen):
		screen_unlocks[screen] = []
	if direction not in screen_unlocks[screen]:
		screen_unlocks[screen].append(direction)

func is_unlocked(screen: String, direction: String) -> bool:
	return direction in screen_unlocks.get(screen, [])

func add_item(id: String, item_type: String):
	if not inventory.has(item_type):
		push_error("Unknown item type: %s" % item_type)
		return

	if id not in inventory[item_type]:
		inventory[item_type].append(id)
		print("Added item:", id, "to", item_type)
