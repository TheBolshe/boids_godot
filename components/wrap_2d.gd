#@tool
class_name Wrap2D
extends Node2D

@export var enabled: bool:
	set(value):
		if value != enabled:
			if value:
				enabled = true
				call_deferred("enable_clones")
			else: 
				enabled = false
				call_deferred("disable_clones")

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
			clone.add_to_group("clone")
			clone.position += Vector2(col, row) * screen_size
			parent.call_deferred("add_child", clone)

func remove_clones() -> void:
	for child in parent.get_children():
		if child.is_in_group("clone"):
			child.queue_free()
			
func disable_clones() -> void:
	for child in parent.get_children():
		if child.is_in_group("clone"):
			child.get_node("Hitbox").disabled = true
			
func enable_clones() -> void:
	for child in parent.get_children():
		if child.is_in_group("clone"):
			child.get_node("Hitbox").disabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = self.get_parent()
	update_screen_size()
	get_viewport().size_changed.connect(update_screen_size)
	create_clones()
	enabled = true
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if enabled:
		parent.position.x = wrap(parent.position.x, 0, screen_size.x)
		parent.position.y = wrap(parent.position.y, 0, screen_size.y)
