extends Node2D

func disable() -> void:
	for collision_shape in find_children("*", "CollisionShape2D", true):
		collision_shape.disabled = true

func enable() -> void:
	for collision_shape in find_children("*", "CollisionShape2D", true):
		collision_shape.disabled = false
