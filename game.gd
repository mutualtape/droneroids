extends Node2D
class_name Game

@export var level : PackedScene

func _ready():
	var level_node = level.instantiate()
	$Level.replace_by(level_node)

func _process(_delta):
	$UI/Touches.text = str(round($Drone.energy))
		
func _game_over_win(type, field):
	
	if(type != LandingField.Type.TARGET): return

	var text
	var collision_counter = $Drone.collision_counter
	if(collision_counter == 0): text = "GOAT!!!"
	elif(collision_counter <= 2): text = "Rockstar!"
	elif(collision_counter <= 5): text = "Master!"
	elif(collision_counter <= 10): text = "Good!"
	elif(collision_counter <= 20): text = "You can Do better"
	else: text = "hardly Survived" 
	game_over(str(collision_counter) + " hits:\n" + text)

func _game_over_stranded(collision_node):
	game_over("poor turtle")		
	
func game_over(message):
	$UI/Panel/Message.text = message
	$UI/Panel.visible = true
