extends CanvasLayer

@onready var label = $Panel/MainMessage
@onready var options_list = $Panel/OptionsList

var on_option_selected: Callable

func show_options(prompt: String, options: Array, screen_name: String, callback: Callable):
	label.text = prompt
	on_option_selected = callback

	# Clear previous options
	for child in options_list.get_children():
		child.queue_free()

	# Add buttons
	for option in options:
		var btn = Button.new()
		btn.text = option["label"]

		var cost = option.get("tp_cost", 0)
		var is_once = option.get("once", false)
		var already_used = is_once and GameState.has_used_option(screen_name, option["label"])
		var not_enough_tp = GameState.trigger_points < cost

		# Label adjustment
		if already_used:
			btn.text += " (Used)"
		elif cost > 0:
			btn.text += " (TP: %d)" % cost

		# Disable if used or not enough TP
		if already_used or not_enough_tp:
			btn.disabled = true
			btn.modulate = Color(0.6, 0.6, 0.6)  # dim

		# Callback
		btn.pressed.connect(func():
			hide()
			on_option_selected.call(option)
		)

		options_list.add_child(btn)

	show()

func _ready():
	hide()
