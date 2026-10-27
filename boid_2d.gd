extends Node2D
class_name Boid2D

var accel : Vector2 = Vector2.ZERO 
var speed : Vector2 = Vector2.ZERO

var neighbours : Array[Area2D]


func _process(delta: float) -> void:
	for child in self.get_children():
		if child.is_class("Area2D"):
			child.rotation = speed.angle()


func _on_vision_area_entered(area: Area2D) -> void:
	if area.get_parent() != self:
		neighbours.push_back(area)


func _on_vision_area_exited(area: Area2D) -> void:
	neighbours.erase(area)
