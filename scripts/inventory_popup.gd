extends Control

@onready var key_tab = $Panel/TabContainer/KeyTab
@onready var battle_tab = $Panel/TabContainer/BattleTab

func _ready():
	hide()

func _clear_container(container: Node):
	for child in container.get_children():
		child.queue_free()

func show_inventory():
	_clear_container(key_tab)
	_clear_container(battle_tab)

	for item in GameState.inventory["key"]:
		var label = Label.new()
		label.text = item.capitalize()
		key_tab.add_child(label)

	for item in GameState.inventory["battle"]:
		var label = Label.new()
		label.text = item.capitalize()
		battle_tab.add_child(label)

	show()

func _on_Close_pressed():
	hide()
