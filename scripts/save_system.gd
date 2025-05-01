extends Node

const SAVE_PATH := "user://save_game.json"

func save_game():
	var data = GameState.to_dict()

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
			GameState.from_dict(data)
			print("✅ Game loaded.")
			return data
		else:
			push_error("❌ Failed to parse save file.")
	else:
		push_error("❌ Failed to open save file.")

	return {}
