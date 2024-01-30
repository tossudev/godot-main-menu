extends CanvasLayer

const TRANSITION_TIME: float = 1.5

var transition_playing: bool = false


func change_scene(to: String) -> void:
	if transition_playing:
		return
	
	transition_playing = true
	await _transition_in()
	
	$TransitionOut.material.set_shader_parameter("progress", 1.0)
	$TransitionIn.material.set_shader_parameter("progress", 0.0)
	
	get_tree().change_scene_to_file(to)
	
	_transition_out()
	transition_playing = false


func _transition_in() -> void:
	var tween = get_tree().create_tween()
	
	tween.tween_property(
			$TransitionIn.material, "shader_parameter/progress",
			1.0, TRANSITION_TIME / 2
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	tween.stop()


func _transition_out() -> void:
	var tween_out = get_tree().create_tween()
	
	tween_out.tween_property(
			$TransitionOut.material, "shader_parameter/progress",
			0.0, TRANSITION_TIME / 2
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
