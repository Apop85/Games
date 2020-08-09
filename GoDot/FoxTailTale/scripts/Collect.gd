extends Node2D

var collected = false
var moved = false
var played = false

onready var rest_position = position

signal coin_collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func move_object():
	var target_position = rest_position.y -15
	if position.y >= target_position:
		position.y -= 2.5
		return false
	elif position.y < target_position:
		return true

func _physics_process(delta):
#	If colected start collecting animation
	if collected:
		moved = move_object()
		if not played:
			if "Coin" in self.name:
				GlobalVariable.play_sound("res://sounds/coin.wav")
			elif "Fox" in self.name:
				GlobalVariable.play_sound("res://sounds/foxHead.wav")
			played = true
				
#			Update Player Score

#		Set target position of coin before delete
#		Move coin
#		if position.y >= target_position:
#			position.y -= 2.5
#		elif position.y < target_position:
#			Search for player
		if moved:
			var main_parent = self.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_child(1)
			if "Coin" in self.name:
				main_parent.score += 1
				main_parent.score_label.text = str(main_parent.score)
				collected = false
#				GlobalVariable.AudioPlayer.play()
			if "Fox" in self.name:
#				Load next level
				GlobalVariable.next_level += 1
#			Delete coin
			queue_free()
		

func _on_HitBox_body_entered(body):
	if body.name == "Player":
#		Play sound
#		Set coin as collected
		collected = true
