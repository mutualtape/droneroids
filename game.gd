extends Node2D

@onready var anim = $MenuUI/FadePlayer
@onready var level = $BaseLevel

var game_stats: Array[Global.GameStat] = []

func _ready():
	next_level()

signal interacted
func _input(event):
	interacted.emit()

func _game_over_stranded(collision_node):
	print("poor turtle not implemented in multi level")	
	
func _on_base_level_finished(stat: Global.GameStat):
	game_stats.append(stat)
	anim.play("fade_to_menu")
	
func next_level(): 
	var resource = "res://scenes/levels/level_veins_%s.tscn" % (game_stats.size() + 1)
	print("load " + resource)
	level.load_level(load(resource))
	anim.play("fade_to_level")

func _on_fade_player_animation_finished(anim_name):
	match anim_name:
		"fade_to_menu": 
			var message = "You needed %s \n and took %s%% damage\n\n press anything" % [
				Global.text_for_millis(game_stats.back().time),
				round((1 - game_stats.back().energy / Drone.energy_max) * 100)
			]
			$MenuUI/Message.text = "[center]" + message + "[/center]"
			$MenuUI/Message.visible = true
			
			await interacted
			$MenuUI/Message.visible = false
			next_level()
		"fade_to_level": 
			level.start_level()
		_: assert(false, "unkown animation " + anim_name)



