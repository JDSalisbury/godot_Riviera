extends Control

func _ready():
	# Fetch the buttons
	print_tree()

	var left = get_node("TriggerButtons/LeftButton")
	var right = get_node("TriggerButtons/RightButton")
	var up = get_node("TriggerButtons/UpButton")
	var inspect = get_node("TriggerButtons/InspectButton")

	# Debug to confirm node is found
	print("Found LeftButton: ", left)

	# Connect signals
	left.pressed.connect(trigger_left)
	right.pressed.connect(trigger_right)
	up.pressed.connect(trigger_up)
	inspect.pressed.connect(trigger_inspect)

# Trigger responses
func trigger_left():
	show_trigger_message("You try to go left, but the path is blocked.")

func trigger_right():
	show_trigger_message("You hear something rustling to the right...")

func trigger_up():
	show_trigger_message("Ahead lies the ancient temple gate.")

func trigger_inspect():
	show_trigger_message("You found a strange, glowing shard!")

# Message output
func show_trigger_message(message: String):
	print(message)
	# Placeholder for future dialog box UI
