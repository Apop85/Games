extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var button_newgame = $"Menu/CenterRow/Buttons/NewGame Button"
onready var button_exit = $"Menu/CenterRow/Buttons/Exit Button"
onready var fader = self.get_parent().get_parent().find_node("Fader")

# Called when the node enters the scene tree for the first time.
func _ready():
	if fader != null:
		var animation = fader.fade_in()
		yield(animation , "animation_finished")
		fader.visible = false
		
	button_newgame.connect("pressed", self, "_on_NewGame_Button_pressed", [button_newgame])
	button_exit.connect("pressed", self, "_on_Exit_Button_pressed", [button_exit])
	GlobalVariable.level_now = GlobalVariable.next_level


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewGame_Button_pressed():
	GlobalVariable.next_level = 1


func _on_Exit_Button_pressed():
	get_tree().quit()
