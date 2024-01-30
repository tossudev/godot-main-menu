extends CanvasLayer

const TRANSITION_TIME: float = 1.0

# Node References
@onready var transition_nodes: Array = [
	$TransitionIn,
	$TransitionOut
] 

var transition_playing: bool = false


# Change scene to filepath, do transition animation.
func change_scene(to: String) -> void:
	if transition_playing:
		return
	
	transition_playing = true
	await _scene_transition(true)
	
	$TransitionOut.material.set_shader_parameter("progress", 1.0)
	$TransitionIn.material.set_shader_parameter("progress", 0.0)
	
	get_tree().change_scene_to_file(to)
	
	_scene_transition(false)
	transition_playing = false


# Animation for changing scenes.
func _scene_transition(transition_in: bool) -> void:
	var transition_node: Object
	var transition_final_value: float
	
	# Change transition animation between going in and out.
	if transition_in:
		transition_node = transition_nodes[0]
		transition_final_value = 1.0
	
	else:
		transition_node = transition_nodes[1]
		transition_final_value = 0.0
	
	# Create animation for transition.
	var tween = get_tree().create_tween()
	tween.tween_property(
			transition_node.material,
			"shader_parameter/progress",
			transition_final_value,
			TRANSITION_TIME / 2
		).set_trans(Tween.TRANS_LINEAR
		).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	tween.stop()
