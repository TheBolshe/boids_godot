extends Node

@export var boid_scene : PackedScene
@export var boids_number = 50

var boids: Array[Boid] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in boids_number:
		var boid : Boid = boid_scene.instantiate()

		boid.position = Vector2(randf_range(0, 700), randf_range(0, 700))
		
		add_child(boid)
		
		boids.push_back(boid)


func _physics_process(delta: float) -> void:
	for boid: Boid in boids:
		boid.set_speed()
		boid.translate(boid.speed * delta)
	
func _on_hud_alignement_value_change(value: Variant) -> void:
	Boid.alignement = value

func _on_hud_cohesion_value_change(value: Variant) -> void:
	Boid.cohesion = value

func _on_hud_separation_value_change(value: Variant) -> void:
	Boid.separation = value
