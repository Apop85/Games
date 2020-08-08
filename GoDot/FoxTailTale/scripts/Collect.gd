extends Node2D

var collected = false

onready var coin = $HitBox
onready var rest_position = position

signal coin_collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _physics_process(delta):
#	If colected start collecting animation
	if collected:
#		Set target position of coin before delete
		var target_position = rest_position.y -15
#		Move coin
		if position.y >= target_position:
			position.y -= 2.5
		elif position.y < target_position:
#			Search for player
			var main_parent = self.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_child(1)
			if "Coin" in self.name:
	#			Update Player Score
				main_parent.score += 1
				main_parent.score_label.text = str(main_parent.score)
				collected = false
#			Delete coin
			queue_free()
		

func _on_HitBox_body_entered(body):
	if body.name == "Player":
#		Play sound
		GlobalVariable.AudioPlayer.play()
#		Set coin as collected
		collected = true
