extends CharacterBody3D

const SPEED = 2
const JUMP_VELOCITY = 2.5
#@export var cam :PhantomCamera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var facing_direction : Vector3 = Vector3(0,0,1)
func _ready():
	#cam = get_tree().current_scene.get_node("PhantomCamera3D")
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		#$AnimationTree.set("parameters/conditions/is_grounded",true)
	
	if is_on_floor():
		$AnimationTree.set("parameters/conditions/is_jumping",false)
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimationTree.set("parameters/conditions/is_jumping",true)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = ($Camera3D.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# only want to rotate y!
	if facing_direction != direction && direction.length() > 0.2:
		facing_direction = direction 
		var model = $Skeleton3D
		var angle = atan2(direction.x, direction.z)
		var rotation_matrix = Basis(Vector3(0, 1, 0), angle)
		model.transform.basis = rotation_matrix

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	$AnimationTree.set("parameters/conditions/is_grounded",is_on_floor())
	$AnimationTree.set("parameters/conditions/is_moving",direction)
	$AnimationTree.set("parameters/conditions/is_idle",!direction)
	
	move_and_slide()
