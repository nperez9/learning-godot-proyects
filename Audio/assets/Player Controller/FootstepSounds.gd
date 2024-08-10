extends AudioStreamPlayer3D

@export var footstep_sounds : Array[AudioStream]
@export var play_rate : float = 0.5
@export var min_velocity : float = 0.5
var last_play_time : float

@onready var player : CharacterBody3D = get_parent()

func _process(delta):
	if (_can_play_footsteps()):
		last_play_time = Time.get_unix_time_from_system()
		stream = footstep_sounds[randi_range(0, footstep_sounds.size() - 1)]
		play()

func _can_play_footsteps() -> bool:
	if not player.is_on_floor():
		return false
	
	if player.velocity.length() < min_velocity:
		return false
		
	if Time.get_unix_time_from_system() - last_play_time < play_rate:
		return false 
	return true
