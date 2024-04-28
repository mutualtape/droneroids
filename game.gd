@tool
extends Node2D
class_name Game

@export var level_scene : PackedScene
var current_level: Node2D
var level_timer_millis: int 

class GameStat:
	var time: int 
	func _init(t: int): time = t
var game_stats: Array[GameStat] = []

func _ready():
	start_level(level_scene)

func start_level(level: PackedScene):
	current_level = level.instantiate()
	current_level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(current_level)
	level_timer_millis = 0

func _process(delta):
	if(Engine.is_editor_hint()): return
	level_timer_millis+=delta*1000
	$GameUI/EnergyBar.ratio = $Drone.energy / $Drone.energy_max
	$GameUI/Time.text = text_for_millis(level_timer_millis)

func text_for_millis(milli_seconds: int):
	var seconds = (milli_seconds/1000) % 60
	var minutes = (milli_seconds/(1000 * 60)) % 60
	return "%02d:%02d" % [minutes, seconds]

signal interacted
func _input(event):
	interacted.emit()

func _game_over_win(type, field):
	if(type != LandingField.Type.TARGET): return
	game_stats.append(GameStat.new(level_timer_millis))
	anim.play("fade_to_menu")
	get_tree().paused = true

func _game_over_stranded(collision_node):
	print("poor turtle not implemented in multi level")	

@onready var anim = $MenuUI/FadePlayer
var next_level: PackedScene
func _on_fade_player_animation_finished(anim_name):
	match anim_name:
		"fade_to_menu": 
			var message = "You needed %s \n and took %s%% damage\n\n press anything" % [
				text_for_millis(game_stats.back().time),
				round((1 - $Drone.energy / $Drone.energy_max) * 100)
			]
			$MenuUI/Message.text = "[center]" + message + "[/center]"
			$MenuUI/Message.visible = true
			current_level.free()
			next_level = load("res://scenes/levels/level_veins_2.tscn")
			$Drone.position = Vector2.ZERO
			start_level(next_level)
			await interacted
			$MenuUI/Message.visible = false
			anim.play("fade_to_level")
		"fade_to_level": 
			get_tree().paused = false
		_: assert(false, "unkown animation " + anim_name)
