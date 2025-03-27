extends Control

func _ready():
	var left = get_node("TriggerButtons/LeftButton")
	var right = get_node("TriggerButtons/RightButton")
	var up = get_node("TriggerButtons/UpButton")
	var inspect = get_node("TriggerButtons/InspectButton")

	print("Found LeftButton: ", left)

	left.pressed.connect(trigger_left)
	right.pressed.connect(trigger_right)
	up.pressed.connect(trigger_up)
	inspect.pressed.connect(trigger_inspect)

func trigger_left():
	show_trigger_message("You try to go left, but the path is blocked.")

func trigger_right():
	show_trigger_message("You hear something rustling to the right...")

func trigger_up():
	show_trigger_message("Ahead lies the ancient temple gate.")

func trigger_inspect():
	show_trigger_message("You found a strange, glowing shard!")

func show_trigger_message(message: String):
	$DialogBox.show_message(message)
