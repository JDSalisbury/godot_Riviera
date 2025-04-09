extends CanvasLayer

@onready var label = $Panel/MainMessage
@onready var options_list = $Panel/OptionsList

var on_option_selected: Callable

func show_options(prompt: String, options: Array, callback: Callable):
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
		if cost > 0:
			btn.text += " (TP: %d)" % cost

		# 🧊 Disable if not enough TP
		if GameState.trigger_points < cost:
			btn.disabled = true
			# Optional: style the button to look grayed out
			btn.modulate = Color(0.6, 0.6, 0.6)  # Makes it appear dimmer

		btn.pressed.connect(func():
			hide()
			on_option_selected.call(option)
		)

		options_list.add_child(btn)


	show()

func _ready():
	hide()
