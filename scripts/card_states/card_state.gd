class_name CardState
extends Node

enum State {BASE, DRAGGED, RELEASED, HOVERED}

signal transition_requested(from: CardState, to: State)

@export var state: State

var card: Card

func enter():
	pass
	
func exit():
	pass
	
func on_input(_event: InputEvent) -> void:
	pass
	
func on_mouse_entered() -> void:
	pass 


func on_mouse_exited() -> void:
	pass
	
