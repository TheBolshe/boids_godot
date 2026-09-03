extends Node2D
class_name Boid

@export var min_speed : int = 100
@export var max_speed : int = 300
@export_range(0, PI) var rotation_speed : float = PI/2

static var separation : float = 1
static var alignement : float = 1
static var cohesion : float = 1

var accel : Vector2 = Vector2.ZERO 
var speed : Vector2 = Vector2.ZERO

var neighbours : Array[Boid]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var angle = randf_range(-PI, PI)
	speed = Vector2.UP.rotated(angle).normalized() * randi_range(min_speed, max_speed)

func _process(delta: float) -> void:
	
	#draw_speed()
	#draw_pos()
	
	for child in self.get_children():
		if child.is_class("Area2D"):
			child.rotation = speed.angle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	set_speed()
	
	translate(speed * delta)

func draw_pos() -> void:
	$Label.text = "%.1f %.1f" % [position.x, position.y]

func draw_speed()-> void:
	$Line2D.clear_points()
	$Line2D.add_point(Vector2.ZERO)
	$Line2D.add_point(speed)
	$Line2D.global_rotation = 0 #you'll need this because Line2D will rotate together with a body


func set_speed() -> void:
	speed *= 0.97
	accel *= 0.95
	
	var separation_force = Vector2.ZERO
	var alignement_force = Vector2.ZERO
	var cohesion_force = Vector2.ZERO
	#var border_force = Vector2.ZERO
	
	var vision: Area2D = $Vision
	
	if neighbours.size() > 0:
		for neighbour: Boid in neighbours:
			var target: Area2D = neighbour.get_node("Wrap2D").get_overlapping_clone(vision)
			var dist: Vector2 = self.global_position - target.global_position
			separation_force += dist * exp(dist.length() * -0.1)
			alignement_force += neighbour.speed
			cohesion_force += target.global_position - self.global_position
		alignement_force /= neighbours.size()
		cohesion_force /= neighbours.size()
	
	if separation_force.length() > 0:
		accel += separation_force.normalized() * separation
	if alignement_force.length() > 0:
		accel += alignement_force.normalized() * alignement
	if cohesion_force.length() > 0:
		accel += cohesion_force.normalized() * cohesion
	
	speed += accel
	
	if speed.length() < min_speed:
		speed = speed.normalized() * min_speed
	if speed.length() > max_speed:
		speed = speed.normalized() * max_speed


func _on_vision_area_entered(area: Area2D) -> void:
	if area.get_parent() != self:
		neighbours.push_back(area.get_parent())


func _on_vision_area_exited(area: Area2D) -> void:
	neighbours.erase(area.get_parent())
