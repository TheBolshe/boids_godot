extends Node2D

@export var boid_scene : PackedScene
@export var boids_number = 50
var boids: Array[Boid2D] = []

@export var min_speed : int = 100
@export var max_speed : int = 300
@export_range(0, PI) var rotation_speed : float = PI/2

@export_range(0, 10) var separation : float = 1
@export_range(0, 10) var alignement : float = 1
@export_range(0, 10) var cohesion : float = 1

class Boid2DData:
	var position: Vector2
	var speed: Vector2
	var accel: Vector2
	var neighbours: Array[Boid2DData]

## Build and return a Boid2DData array with information needed to compute forces.
## For each boid copies its position, speed, accel and neghbours speed and position
func _build_data() -> Array[Boid2DData]:
	var data_array: Array[Boid2DData] = []
	for boid: Boid2D in boids:
		var data: Boid2DData = Boid2DData.new()
		data.position = boid.global_position
		data.speed = boid.speed
		data.accel = boid.accel
		data.neighbours = []
		for neighbour in boid.neighbours:
			# Get current boid Vision Area2D then determine which one of the neighbour Area2D body
			# clones is overlapping it
			var vision: Area2D = boid.get_node("Vision")
			var target: Area2D = neighbour.get_node("Wrap2D").get_overlapping_clone(vision, "body")
			var neighbour_data: Boid2DData = Boid2DData.new()
			neighbour_data.position = target.global_position
			neighbour_data.speed = neighbour.speed
			data.neighbours.push_back(neighbour_data)
		data_array.push_back(data)
	return data_array

## Update the passed Boid2DData array
func _calculate_forces(data: Boid2DData)-> void:
	# Dampen current speed and accel
	data.speed *= 0.97
	data.accel *= 0.9
	# Init forces then update them for each neighbour
	var separation_force = Vector2.ZERO
	var alignement_force = Vector2.ZERO
	var cohesion_force = Vector2.ZERO
	for neighbour: Boid2DData in data.neighbours:
		# Separation : try to avoid its neighbours (with exponential decay)
		var dist: Vector2 = data.position - neighbour.position
		separation_force += dist * exp(dist.length() * -0.1)
		# Alignement : move in the average direction of its neighbours
		alignement_force += neighbour.speed
		# Cohesion : move towards the average position of its neighbours
		cohesion_force += neighbour.position - data.position
	alignement_force /= data.neighbours.size()
	cohesion_force /= data.neighbours.size()
	
	# Sum non zero forces into accel
	if separation_force.length() > 0:
		data.accel += separation_force.normalized() * separation
	if alignement_force.length() > 0:
		data.accel += alignement_force.normalized() * alignement
	if cohesion_force.length() > 0:
		data.accel += cohesion_force.normalized() * cohesion
	# Update speed with accel then clamp it
	data.speed += data.accel
	if data.speed.length() < min_speed:
		data.speed = data.speed.normalized() * min_speed
	if data.speed.length() > max_speed:
		data.speed = data.speed.normalized() * max_speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in boids_number:
		var boid: Boid2D = boid_scene.instantiate()
		boid.position = Vector2(randf_range(0, 700), randf_range(0, 700))
		var angle = randf_range(-PI, PI)
		boid.speed = Vector2.UP.rotated(angle).normalized() * randi_range(min_speed, max_speed)
		add_child(boid)
		boids.push_back(boid)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var data: Array[Boid2DData] = _build_data()
	for i in boids.size():
		_calculate_forces(data[i])
		boids[i].speed = data[i].speed
		boids[i].accel = data[i].accel
	
	for boid: Boid2D in boids:
		boid.translate(boid.speed * delta)
