extends RigidBody2D

@onready var game : Game = $/root/Game
@onready var direction_marker : Marker2D = $Marker2D
@onready var cooldown_timer : Timer = Timer.new()
@onready var stranded_timer : Timer = Timer.new()

@export var rotationSpeed: int 
@export var thrust: float 

var prev_velocity: Vector2 = Vector2.ZERO
var over_landing_field: LandingField = null
var stranded_on: CollisionObject2D = null

func _ready():
	
	inertia = 20;
	
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	
	stranded_timer.one_shot = true
	stranded_timer.connect("timeout", _on_stranded)
	add_child(stranded_timer)
	

func drone_direction() -> Vector2: 
	return (direction_marker.global_position - global_position).normalized()

func _physics_process(delta):
	
	#Idea: making it harder to navigate by adding some randomness to rotation 
	#add_constant_torque(100)
	
	prev_velocity = linear_velocity;

	var rotation_change = rotationSpeed * delta * 100;
	var impulse = thrust * drone_direction() * delta * 10;	
	
	var steer_rotation = Input.get_axis("left", "right")
	var steer_thrust = Input.get_axis("backward", "forward")
	
	if(Input.is_action_pressed("left")):
		apply_torque( - rotation_change)
	elif (Input.is_action_pressed("right")):
		apply_torque( + rotation_change)
	elif (steer_rotation != 0):
		apply_torque( steer_rotation * rotation_change)
	else:
		# smooth out spinning eg, after bouncing against a wall
		angular_velocity /= 1 + delta;
	
	if(Input.is_action_pressed("forward")):
		apply_impulse( + impulse)	
	elif(steer_thrust != 0):
		apply_impulse( steer_thrust * impulse )

	# idea: no or less thrust if ship is moving backwards already
	# linear_velocity.angle() direction.angle()
	elif(Input.is_action_pressed("backward")):
		apply_impulse( - impulse / 4)	

func collision():
	if(cooldown_timer.is_stopped()):
		cooldown_timer.start(0.5)
		game.collision_counter += 1
		$AudioStreamPlayer.play()
	

func _on_collision(_body : CollisionObject2D):
	var impact = prev_velocity.length()
	if(impact > 100): collision()
	if(over_landing_field != null 
	and over_landing_field.type == over_landing_field.Type.TARGET): 
		game.game_over_win()

func _on_landing_area_body_entered(body):
	if(body is LandingField):
		#Idea: start a timer to make sure to be over the field for some time before landing
		over_landing_field = body

func _on_landing_area_body_exited(body):
	if(body is LandingField):
		over_landing_field = null

func _on_stranded_area_body_entered(body):
	stranded_on = body
	stranded_timer.start(4)

func _on_stranded_area_body_exited(_body):
	stranded_on = null
	stranded_timer.stop()
	
func _on_stranded():
	if(drone_direction().y > 0):
		game.game_over_lost("poor turtle")
