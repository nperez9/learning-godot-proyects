extends Area3D
@export var speed : float = 10.0
@export var max_distance : float = 50.0

@onready var start_post = global_position



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(basis.z * speed * delta)
	
	if global_position.distance_to(start_post) > max_distance:
		global_position = start_post
