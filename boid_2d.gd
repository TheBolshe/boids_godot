extends Node2D
class_name Boid2D

var safe_position : Vector2
var accel : Vector2 = Vector2.ZERO
var speed : Vector2 = Vector2.ZERO

var neighbours : Array[Area2D]

func _process(delta: float) -> void:
	$Vision.rotation = speed.angle()
	$Body.rotation = speed.angle()

func _physics_process(delta: float) -> void:
	safe_position = global_position

func _on_vision_area_entered(area: Area2D) -> void:
	if area.get_parent() != self:
		neighbours.push_back(area)


func _on_vision_area_exited(area: Area2D) -> void:
	neighbours.erase(area)
