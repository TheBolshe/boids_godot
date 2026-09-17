extends Node

func _on_hud_alignement_value_change(value: Variant) -> void:
	$Boid2DManager.alignement = value

func _on_hud_cohesion_value_change(value: Variant) -> void:
	$Boid2DManager.cohesion = value

func _on_hud_separation_value_change(value: Variant) -> void:
	$Boid2DManager.separation = value
