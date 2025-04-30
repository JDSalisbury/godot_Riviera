extends CanvasLayer

var label: Label
var anim: AnimationPlayer

func _ready():
	label = get_node_or_null("Panel/Label")
	anim = get_node_or_null("Panel/AnimationPlayer")

	if not label or not anim:
		push_error("DialogBox nodes not found: Label or AnimationPlayer is missing.")

func show_message(text: String):
	if label and anim:
		label.text = text
		anim.play("fade_in_out")
	else:
		push_warning("DialogBox: Cannot show message, label or anim is null.")

func clear():
	if label:
		label.text = ""
