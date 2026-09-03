extends Control

signal separation_value_change(value)
signal alignement_value_change(value)
signal cohesion_value_change(value)


func _on_separation_value_changed(value: float) -> void:
	separation_value_change.emit(value)


func _on_alignement_value_changed(value: float) -> void:
	alignement_value_change.emit(value)


func _on_cohesion_value_changed(value: float) -> void:
	cohesion_value_change.emit(value)
