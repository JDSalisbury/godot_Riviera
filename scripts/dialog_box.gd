extends CanvasLayer

@onready var label = $Panel/Label
@onready var anim = $Panel/AnimationPlayer

func show_message(text: String):
	label.text = text
	anim.play("fade_in_out")


func clear():
	label.text = ""
	#hide()
