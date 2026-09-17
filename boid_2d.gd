extends Node2D
class_name Boid2D

static var min_speed : int = 100
static var max_speed : int = 300
@export_range(0, PI) var rotation_speed : float = PI/2

static var separation : float = 1
static var alignement : float = 1
static var cohesion : float = 1

var accel : Vector2 = Vector2.ZERO 
var speed : Vector2 = Vector2.ZERO

var neighbours : Array[Boid2D]

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


func draw_pos() -> void:
	$Label.text = "%.1f %.1f" % [position.x, position.y]

func draw_speed()-> void:
	$Line2D.clear_points()
	$Line2D.add_point(Vector2.ZERO)
	$Line2D.add_point(speed)
	$Line2D.global_rotation = 0 #you'll need this because Line2D will rotate together with a body

func _on_vision_area_entered(area: Area2D) -> void:
	if area.get_parent() != self:
		neighbours.push_back(area.get_parent())


func _on_vision_area_exited(area: Area2D) -> void:
	neighbours.erase(area.get_parent())
