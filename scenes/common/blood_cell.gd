@tool
extends RigidBody2D
	
var drone: Drone = null

@export var scaled_children: float = 1:
	set(new_value):
		scaled_children = new_value/scaled_children
		_ready()
		scaled_children = new_value
		
func _ready():
	apply_scale_on_children(self)
	
func apply_scale_on_children(parent: Node2D):	
	for node in parent.get_children():
		if(node is Node2D):
			node.apply_scale(Vector2(scaled_children, scaled_children))
			apply_scale_on_children(node)
	

func _physics_process(delta):
	if(drone != null):
		apply_force(drone.linear_velocity)
	
func random_dir():
	return Vector2(randf_range(-1, 1), randf_range(-1, 1))	

func _on_drone_detector_area_body_entered(body):
	if(body is Drone): 
		drone = body

func _on_drone_detector_area_body_exited(body):
	drone = null

func _on_direction_timer_timeout():
	apply_impulse(random_dir() * 30)
	if(drone): drone.energy_loss(1)
	

