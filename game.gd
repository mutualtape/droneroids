extends Node2D
class_name Game

var collision_counter: int = 0

func _process(_delta):
	$UI/Touches.text = str(collision_counter)
	
func game_over_win():
	var text
	if(collision_counter == 0): text = "GOAT!!!"
	elif(collision_counter <= 2): text = "Rockstar!"
	elif(collision_counter <= 5): text = "Master!"
	elif(collision_counter <= 10): text = "Good!"
	elif(collision_counter <= 20): text = "You can Do better"
	else: text = "hardly Survived" 
	game_over(str(collision_counter) + " hits:\n" + text)
	
func game_over_lost(message):
	game_over(message)
	
func game_over(message):
	$UI/Panel/Message.text = message
	$UI/Panel.visible = true
