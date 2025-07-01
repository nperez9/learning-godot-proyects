extends CharacterBody3D

@export_category("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 6.0

@export_category("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0

var _camera_input_direction := Vector2.ZERO
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
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	## Limits the camera movent (to not fully rotate)
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	## Prevents camera to keep move if mouse is stoped
	_camera_input_direction = Vector2.ZERO
