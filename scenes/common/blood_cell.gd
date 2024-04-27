extends RigidBody2D
	
var drone: Drone = null

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
	

