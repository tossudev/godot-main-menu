extends Node2D

const CAMERA_TRANSITION_TIME: float = 0.6

# Node references
@onready var camera_node: Camera2D = $Camera

var time_elapsed: float = 0.0


func move_camera(to: String) -> void:
	var new_menu: Object
	var new_menu_position: Vector2
	
	match to:
		"Main":
			new_menu = $Menus/Main
		"Credits":
			new_menu = $Menus/Credits
	
	new_menu_position = new_menu.position
	
	_transition_camera(new_menu_position)


# Create animation for camera transition.
func _transition_camera(pos: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
			camera_node,
			"position",
			pos,
			CAMERA_TRANSITION_TIME
		).set_trans(Tween.TRANS_EXPO
		).set_ease(Tween.EASE_OUT)


# Signals

func _on_button_play_pressed():
	SceneChanger.change_scene("res://scenes/main_menu.tscn")


func _on_button_credits_pressed():
	move_camera("Credits")


func _on_button_back_pressed():
	move_camera("Main")




