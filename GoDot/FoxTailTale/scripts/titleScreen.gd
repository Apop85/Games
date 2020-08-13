extends Control

onready var button_newgame = $"Menu/CenterRow/Buttons/NewGame Button"
onready var button_exit = $"Menu/CenterRow/Buttons/Exit Button"
onready var fader = self.get_parent().get_parent().find_node("Fader")


func _ready():
	if fader != null:
#		Play fade in effect and wait until finished
		var animation = fader.fade_in()
		yield(animation , "animation_finished")
		fader.visible = false
	
#	Connect buttons to signals
	button_newgame.connect("pressed", self, "_on_NewGame_Button_pressed", [button_newgame])
	button_exit.connect("pressed", self, "_on_Exit_Button_pressed", [button_exit])
	GlobalVariable.level_now = GlobalVariable.next_level


func _on_NewGame_Button_pressed():
	GlobalVariable.next_level = 1


func _on_Exit_Button_pressed():
	get_tree().quit()
