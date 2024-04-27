@tool
extends Node2D
class_name Game

@export var level : PackedScene

var start_time 

class GameStat:
	var time: int 
	func _init(t: int): time = t
var game_stats: Array[GameStat] = []

func _ready():
	var level_node = level.instantiate()
	add_child(level_node)
	start_time = Time.get_ticks_msec()

func _process(delta):
	if(Engine.is_editor_hint()): return
	$UI/EnergyBar.ratio = $Drone.energy / $Drone.energy_max
	
	$UI/Time.text = text_for_seconds(Time.get_ticks_msec() - start_time)
		
func text_for_seconds(milli_seconds: int):
	var seconds = (milli_seconds/1000) % 60
	var minutes = (milli_seconds/(1000 * 60)) % 60
	return "%02d:%02d" % [minutes, seconds]
		
func _game_over_win(type, field):
	if(type != LandingField.Type.TARGET): return
	
	game_stats.append(GameStat.new(Time.get_ticks_msec() - start_time))
	
	game_over("You needed %s \n and took %s%% damage" % [
		text_for_seconds(game_stats[0].time),
		round((1 - $Drone.energy / $Drone.energy_max) * 100)
	])

func _game_over_stranded(collision_node):
	game_over("poor turtle")		
	
func game_over(message):
	$UI/Panel/Message.text = "[center]" + message + "[/center]"
	$UI/Panel.visible = true
	get_tree().paused = true
