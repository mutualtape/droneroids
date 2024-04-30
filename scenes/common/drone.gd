extends RigidBody2D
class_name Drone

var energy: float = 100
const energy_max: float = 100

signal over_field(type: LandingField.Type, field: LandingField)

@export var rotationSpeed: int 
@export var thrust: int 

class PropellerInfo: 
	var node: Sprite2D
	var initial_scale: Vector2
	var scale_percent: float = randf_range(-1,1)
	var sign: float = -1
	var blood_particles: Array
	func _init(n): node = n; initial_scale = node.scale
@onready var propeller_left = PropellerInfo.new($PropellerLeft)
@onready var propeller_right = PropellerInfo.new($PropellerRight)


func _ready():
	
	inertia = 20
	
	init_blood()
	
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	
	$PropellerPlayer.play()

func drone_direction() -> Vector2: 
	return ($Marker2D.global_position - global_position).normalized()

func _physics_process(delta):
	
	# has to run in physics process
	if(position_reseted): apply_reset_position(); return
	# though physics is deactivated when paused, forces would accumulate and then cause a "rocket start" 
	if(get_tree().paused): return
	
	#Idea: making it harder to navigate by adding some randomness to rotation 
	#add_constant_torque(100)
	
	prev_velocity = linear_velocity;

	var rotation_change = rotationSpeed * delta * 100;
	var impulse = thrust * drone_direction() * delta * 100;	
	
	var steer_rotation = Input.get_axis("left", "right")
	var steer_thrust = Input.get_axis("backward", "forward")
	
	# apply rotation
	if(Input.is_action_pressed("left")):
		apply_torque( - rotation_change)
	elif (Input.is_action_pressed("right")):
		apply_torque( + rotation_change)
	elif (steer_rotation != 0):
		apply_torque( steer_rotation * rotation_change)
	else:
		# smooth out spinning eg, after bouncing against a wall
		angular_velocity /= 1 + delta * 2;
	
	# apply thrust
	if(Input.is_action_pressed("forward")):
		apply_force( + impulse)	
	elif(steer_thrust != 0):
		apply_force( steer_thrust * impulse )
	# idea: no or less thrust if ship is moving backwards already
	# linear_velocity.angle() direction.angle()
	elif(Input.is_action_pressed("backward")):
		apply_force( - impulse / 4)	
		
func _process(delta):
	
	var speed = 0.6 * delta \
		if get_linear_velocity().length() > 1 \
		else 0.2 * delta 
	var thrust = max(
		Input.get_action_strength("forward"), 
		Input.get_action_strength("backward"))
	animate_propeller(propeller_left, 
		speed + speed * max(Input.get_action_strength("right"), thrust))
	animate_propeller(propeller_right, 
		speed + speed * max(Input.get_action_strength("left"), thrust))

	$PropellerPlayer.pitch_scale = 1 + thrust/2
	AudioServer.get_bus_effect(1, 0).pan = Input.get_axis("left", "right") * 0.7
	
	
func animate_propeller(propeller: PropellerInfo, rotation_speed):
	propeller.scale_percent += 20 * propeller.sign * rotation_speed
	if(propeller.scale_percent <= -1): propeller.sign = 1
	elif(propeller.scale_percent >= 1): propeller.sign = -1
	var new_x = propeller.initial_scale.x * propeller.scale_percent
	propeller.node.scale = Vector2(new_x, propeller.initial_scale.y)
	
func energy_loss(lost_energy):
	energy -= lost_energy


# reset ship position and movement has to happen within physics process
var position_reseted = false
func reset_position():
	position_reseted = true
func apply_reset_position():
	position = Vector2.ZERO
	rotation = 0
	sleeping = true
	position_reseted = false

# Collision handling

@onready var cooldown_timer : Timer = Timer.new()
var over_landing_field: LandingField = null
var prev_velocity: Vector2 = Vector2.ZERO

func collision():
	if(cooldown_timer.is_stopped()):
		cooldown_timer.start(0.5)
		energy_loss(prev_velocity.length()/100)
		var new_db = min(prev_velocity.length()/30 - 17, 5)
		$CollisionPlayer.volume_db = new_db
		$CollisionPlayer.play()

func _on_collision(_body : CollisionObject2D):
	var impact = prev_velocity.length()
	if(impact > 100): collision()
	if(over_landing_field != null): over_field.emit(over_landing_field.type, over_landing_field) 
	
func _on_landing_area_body_entered(body):
	if(body is LandingField):
		#Idea: start a timer to make sure to be over the field for some time before landing
		over_landing_field = body

func _on_landing_area_body_exited(body):
	if(body is LandingField):
		over_landing_field = null

# Blood
func init_blood():
	$BloodArea/BloodParticles.position = Vector2.ZERO
	$BloodArea/BloodParticles.emitting = false
	propeller_left.blood_particles = generate_blood_particles($BloodArea/CollBloodLeft)
	propeller_right.blood_particles = generate_blood_particles($BloodArea/CollBloodRight)
	$BloodArea/BloodParticles.free()
func generate_blood_particles(marker):
	var blood_down: CPUParticles2D = $BloodArea/BloodParticles.duplicate()
	var blood_up: CPUParticles2D = $BloodArea/BloodParticles.duplicate()
	blood_down.direction.y = 1
	blood_up.direction.y = -1
	blood_down.position = marker.position
	blood_up.position = marker.position
	$BloodArea.add_child(blood_down)
	$BloodArea.add_child(blood_up)
	return [blood_down, blood_up]
func _on_blood_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if(not body is LevelShape2D): return
	match local_shape_index:
		0: set_all_emmision_to(propeller_left.blood_particles, true)
		1: set_all_emmision_to(propeller_right.blood_particles, true)
func _on_blood_area_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if(not body is LevelShape2D): return
	match local_shape_index:
		0: set_all_emmision_to(propeller_left.blood_particles, false)
		1: set_all_emmision_to(propeller_right.blood_particles, false)
func set_all_emmision_to(particles: Array, e: bool):
	for p in particles: p.emitting = e

