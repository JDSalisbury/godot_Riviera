extends Node

# Global TP system
var trigger_points: int = 10
var max_trigger_points: int = 20

var story_flags: Dictionary = {}
var screen_unlocks: Dictionary = {}
var used_options := {}

var inventory := {
	"key": [],
	"battle": []
}

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
