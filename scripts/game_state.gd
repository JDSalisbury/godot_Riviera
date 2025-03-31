extends Node

# Global state
var trigger_points: int = 10
var max_trigger_points: int = 20

var story_flags: Dictionary = {}
var screen_unlocks: Dictionary = {}

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
