@tool
extends Node2D

@export var debug_level_scene: PackedScene:
	set(scene): 
		debug_level_scene = scene 
		if(Engine.is_editor_hint()): instantiate_level(scene)
	get: return debug_level_scene
	
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

func load_level(scene: PackedScene):
	if(current_level != null):
		current_level.free()
	drone.reset_position()
	level_timer_millis = 0
	level_started = false
	get_tree().paused = true
	current_level = instantiate_level(scene)

func instantiate_level(scene: PackedScene):
	var new_node = scene.instantiate()
	var former_node = $Level
	former_node.name = "LevelTmp"
	new_node.name = "Level"
	$LevelTmp.replace_by(new_node)
	former_node.free()
	return new_node
	
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
