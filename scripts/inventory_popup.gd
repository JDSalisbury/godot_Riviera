extends Control

@onready var key_tab = $Panel/TabContainer/KeyTab
@onready var battle_tab = $Panel/TabContainer/BattleTab
@onready var panel = $Panel

var tween: Tween = null

func _ready():
	hide()

func toggle():
	print("Attempting to Toggle")
	if visible:
		print("visible, should close")
		_on_Close_pressed()
	else:
		print("not visible, should open")
		show_inventory()

func _clear_container(container: Node):
	for child in container.get_children():
		child.queue_free()

func show_inventory():
	print(">> show_inventory called")

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

	# Start offscreen
	panel.position.x = 500
	show()
	await get_tree().process_frame

	var target_pos = Vector2(0, 0)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(panel, "position", target_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_Close_pressed():
	var offscreen_pos = Vector2(500, 0)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(panel, "position", offscreen_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): hide())
