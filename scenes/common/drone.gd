extends RigidBody2D
class_name Drone

@onready var direction_marker : Marker2D = $Marker2D
@onready var cooldown_timer : Timer = Timer.new()
@onready var stranded_timer : Timer = Timer.new()

var collision_counter: int = 0

signal over_field(type: LandingField.Type, field: LandingField)
signal stranded(on: CollisionObject2D)

@export var rotationSpeed: int 
@export var thrust: int 

var prev_velocity: Vector2 = Vector2.ZERO
var over_landing_field: LandingField = null
var stranded_on: CollisionObject2D = null

@onready var propeller_region_rect: Rect2 = $PropellerLeft.region_rect 
class PropellerInfo: 
	var node: Sprite2D
	var percentage_shown: float = randf()
	var sign: float = -1
	func _init(n): node = n
@onready var propeller_left = PropellerInfo.new($PropellerLeft)
@onready var propeller_right = PropellerInfo.new($PropellerRight)

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
	
	# apply thurst
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
	
func animate_propeller(propeller: PropellerInfo, rotation_speed):
	
	propeller.percentage_shown += propeller.sign * 20 * rotation_speed
	if(propeller.percentage_shown <= 0): propeller.sign = 1
	elif(propeller.percentage_shown >= 1): propeller.sign = -1
	
	var new_width = propeller_region_rect.size.x * propeller.percentage_shown
	var diff = propeller_region_rect.size.x - new_width  
	
	#print(propeller_percentage_shown, " ", diff/2, "  ", new_width)
	
	propeller.node.region_rect = Rect2(
		diff/2,
		propeller_region_rect.position.y,
		new_width,
		propeller_region_rect.size.y) 

func collision():
	if(cooldown_timer.is_stopped()):
		cooldown_timer.start(0.5)
		collision_counter += 1
		$AudioStreamPlayer.play()
	

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

func _on_stranded_area_body_entered(body):
	stranded_on = body
	stranded_timer.start(4)

func _on_stranded_area_body_exited(_body):
	stranded_timer.stop()
	stranded_on = null
	
func _on_stranded():
	if(drone_direction().y > 0):
		stranded.emit(stranded_on)
