extends CharacterBody3D

@export_category("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 6.0

@export_category("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0

@onready var _skin = %SophiaSkin
@onready var _camera_pivot : Node3D = %CameraPivot
@onready var _camera_3d: Camera3D = %Camera3D

func _unhandled_input(event: InputEvent) -> void:
	## MOUSE MODE is for check that is moving in the active window
	var is_camera_motion := (event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
		
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("left_click")):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if (event.is_action_pressed("ui_cancel")):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE		

func _physics_process(delta: float) -> void:
	## - Camera Movement -
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	## Limits the camera movent (to not fully rotate)
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	## Prevents camera to keep move if mouse is stoped
	_camera_input_direction = Vector2.ZERO
	
	## - Player Movement -
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera_3d.global_basis.z
	var right := _camera_3d.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	## prevents to move in y exes due to camera rotation
	move_direction = move_direction.normalized()
	var velocity_y = velocity.y
	move_direction.y = 0.0
	
	velocity = velocity.move_toward(move_direction * move_speed, delta * acceleration)
	velocity.y = velocity_y + _gravity * delta
	move_and_slide()

	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse
	
	## - Region Rotation -
	if (move_direction.length() > 0.2):
		_last_movement_direction = move_direction
	var target_rotation := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.global_rotation.y, target_rotation, delta * rotation_speed)	

	## - Region Animation -
	var ground_speed := velocity.length()
	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		if ground_speed > 0.2:
			_skin.move()
		else:
			_skin.idle()
