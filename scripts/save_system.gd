extends Node

const SAVE_PATH := "user://save_game.json"

func save_game():
	var data := {
		"trigger_points": GameState.trigger_points,
		"max_trigger_points": GameState.max_trigger_points,
		"story_flags": GameState.story_flags,
		"screen_unlocks": GameState.screen_unlocks,
		"used_options": GameState.used_options,
		"inventory": GameState.inventory,
		"current_screen": GameState.current_screen,
		"key_item_unlocks_shown": GameState.key_item_unlocks_shown,
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		print("✅ Game saved.")
	else:
		push_error("❌ Failed to save game.")

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("ℹ️ No save file found.")
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		var data = JSON.parse_string(content)
		if typeof(data) == TYPE_DICTIONARY:
			print("✅ Game loaded.")
			return data
		else:
			push_error("❌ Failed to parse save file.")
	else:
		push_error("❌ Failed to open save file.")

	return {}
