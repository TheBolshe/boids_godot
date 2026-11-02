extends Area2D
var safe_global_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	safe_global_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	safe_global_position = global_position
