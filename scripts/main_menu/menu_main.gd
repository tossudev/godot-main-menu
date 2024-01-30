extends Node2D

const ANIM_VALUES_TITLE: Dictionary = {
	"scale_time" : 1.75,			# Time multiplier for animation
	"scale_amount" : 0.1,			# Scale multiplier for animation
	"scale_amount_offset" : 1.0,	# Scale offset from 0.0
	
	"rotation_time" : 2.0,			# Time multiplier for animation
	"rotation_amount" : 0.08,		# Rotation multiplier for animation
}

# Node references
@onready var title_node: Object = $Title

var time_elapsed: float = 0.0


func _process(delta):
	time_elapsed += delta
	_do_title_spin()


func _do_title_spin() -> void:
	var title_scale: float = (
		cos(time_elapsed * ANIM_VALUES_TITLE.scale_time
		) * ANIM_VALUES_TITLE.scale_amount
		) + ANIM_VALUES_TITLE.scale_amount_offset
	
	var title_rotation: float = cos(
		time_elapsed * ANIM_VALUES_TITLE.rotation_time
		) * ANIM_VALUES_TITLE.rotation_amount
	
	title_node.scale = Vector2(title_scale, title_scale)
	title_node.rotation = title_rotation
	


# Signals

func _on_button_play_pressed():
	SceneChanger.change_scene("res://scenes/main_menu.tscn")
