extends Control

@onready var bar = $Bar
@onready var label = $TPLabel

func update_tp(current: int, max_val: int):
	bar.max_value = max_val
	bar.value = current
	label.text = "TP: %d / %d" % [current, max_val]
