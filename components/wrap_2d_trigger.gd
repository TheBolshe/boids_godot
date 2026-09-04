extends Node2D
class_name Wrap2DTrigger

@export var target: String = "body"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group(target):
		area.get_parent().get_node("Wrap2D").enabled = false


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group(target):
		area.get_parent().get_node("Wrap2D").enabled = true
