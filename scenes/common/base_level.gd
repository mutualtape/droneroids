@tool
extends Node2D

@export var debug_level_scene : PackedScene

signal finished(stat: Global.GameStat)

@onready var drone = $Drone

var current_level: Node2D
var level_timer_millis: int 
var level_started

func _ready():
	# start debug level when run directly
	if(get_parent() == get_tree().root): 
		load_level(debug_level_scene)
		start_level()

func load_level(level: PackedScene):
	if(current_level != null):
		current_level.free()
	drone.reset_position()
	level_timer_millis = 0
	level_started = false
	current_level = level.instantiate()
	get_tree().paused = true
	add_child(current_level)
	
func start_level():
	level_timer_millis = 0
	level_started = true
	get_tree().paused = false

func _process(delta):
	if(Engine.is_editor_hint()): return
	if(level_started): level_timer_millis += delta*1000
	$GameUI/EnergyBar.ratio = $Drone.energy / $Drone.energy_max
	$GameUI/Time.text = Global.text_for_millis(level_timer_millis)

func _on_drone_over_field(type, field):
	if(! level_started): return
	if(type == LandingField.Type.TARGET):
		level_started = false
		finished.emit(Global.GameStat.new(level_timer_millis, drone.energy))
