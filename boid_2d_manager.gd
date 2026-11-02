extends Node2D

@export var boid_scene: PackedScene
@export var boids_number: int = 50
var boids: Array[Boid2D] = []

@export var min_speed: int = 100
@export var max_speed: int = 300

@export_range(0, 10) var separation: float = 1
@export_range(0, 10) var alignement: float = 1
@export_range(0, 10) var cohesion: float = 1

var THREAD_COUNT: int = 5
var chunk_size: int = 0

var results: Array[DataTest]
var threads: Array[Thread]
var work_semaphores: Array[Semaphore]
var done_semaphores: Array[Semaphore]
var stop: bool = false


class DataTest:
	var speed: Vector2
	var accel: Vector2

func _calculate_test(i: int) -> void:
	var data: DataTest = results[i]
	data.speed = boids[i].speed
	data.accel = boids[i].accel
	# Dampen current speed and accel
	data.speed *= 0.97
	data.accel *= 0.9
	# Init forces then update them for each neighbour
	var separation_force: Vector2 = Vector2.ZERO
	var alignement_force: Vector2 = Vector2.ZERO
	var cohesion_force: Vector2 = Vector2.ZERO
	for neighbour: Area2D in boids[i].neighbours:
		# Separation : try to avoid its neighbours (with exponential decay)
		var dist: Vector2 = boids[i].safe_position - neighbour.safe_global_position
		separation_force += dist * exp(dist.length() * -0.1)
		# Alignement : move in the average direction of its neighbours
		alignement_force += neighbour.get_parent().speed
		# Cohesion : move towards the average position of its neighbours
		cohesion_force += neighbour.safe_global_position - boids[i].safe_position
	alignement_force /= boids[i].neighbours.size()
	cohesion_force /= boids[i].neighbours.size()
	
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

func thread_work(thread_id: int) -> void:
	while true:
		work_semaphores[thread_id].wait()
		if stop:
			break
		var start: int = thread_id * chunk_size
		var end: int = mini(start + chunk_size, boids.size())
		for i in range(start, end):
			_calculate_test(i)
		done_semaphores[thread_id].post()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in boids_number:
		var boid: Boid2D = boid_scene.instantiate()
		boid.position = Vector2(randf_range(0, 700), randf_range(0, 700))
		var angle: float = randf_range(-PI, PI)
		boid.speed = Vector2.UP.rotated(angle).normalized() * randi_range(min_speed, max_speed)
		add_child(boid)
		boids.push_back(boid)
		
	chunk_size = ceili(float(boids.size()) / THREAD_COUNT)
	results.resize(boids.size())
	for i in results.size():
		results[i] = DataTest.new()
	
	for i in THREAD_COUNT:
		work_semaphores.push_back(Semaphore.new())
		done_semaphores.push_back(Semaphore.new())
		threads.push_back(Thread.new())
		threads[i].start(thread_work.bind(i))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in THREAD_COUNT:
		work_semaphores[i].post()
	for i in THREAD_COUNT:
		done_semaphores[i].wait()
	
	for i in boids.size():
		boids[i].speed = results[i].speed
		boids[i].accel = results[i].accel
	
	for boid: Boid2D in boids:
		boid.translate(boid.speed * delta)
	

func _exit_tree() -> void:
	stop = true
	for i in THREAD_COUNT:
		work_semaphores[i].post()
	for t in threads:
		t.wait_to_finish()
