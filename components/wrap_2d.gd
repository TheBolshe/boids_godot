@tool
class_name Wrap2D
extends Node2D


var parent : Node2D
var screen_size : Vector2

func update_screen_size() -> void :
	screen_size = get_viewport().get_visible_rect().size

func create_clones() -> void:
	var body : Area2D = (func(node : Node2D):
		for child in node.get_children():
			if child.name == "Body":
				return child 
		return null).call(parent)
	
	for col in range(-1, 2, 1):
		for row in range(-1, 2, 1):
			if col == 0 and row == 0:
				continue
			var clone : Area2D = body.duplicate()
			clone.position += Vector2(col, row) * screen_size
			parent.call_deferred("add_child", clone)

func get_overlapping_clone(area: Area2D) -> Area2D:
	for child in get_parent().get_children():
		if child.is_in_group("body") && area.overlaps_area(child):
			return child
	return

func test():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = self.get_parent()
	update_screen_size()
	get_viewport().size_changed.connect(update_screen_size)
	create_clones()
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	parent.position.x = wrap(parent.position.x, 0, screen_size.x)
	parent.position.y = wrap(parent.position.y, 0, screen_size.y)
