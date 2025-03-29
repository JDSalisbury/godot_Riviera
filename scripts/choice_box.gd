extends CanvasLayer

@onready var label = $Panel/MainMessage
@onready var options_list = $Panel/OptionsList

var on_option_selected: Callable

func show_options(prompt: String, options: Array, callback: Callable):
	label.text = prompt
	on_option_selected = callback

	# Clear old buttons
	for child in options_list.get_children():
		child.queue_free()

	# Add new buttons
	for option in options:
		var btn = Button.new()
		btn.text = option.label
		btn.pressed.connect(func():
			hide()
			on_option_selected.call(option)
		)
		options_list.add_child(btn)

	show()

func _ready():
	hide()
