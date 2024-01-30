extends Node

const GROUP_BUTTONS: String = "buttons"

# Object references
var button_nodes: Array = []


func _ready() -> void:
	_get_node_references()
	_connect_signals()


func _get_node_references() -> void:
	for button_node: Object in get_tree().get_nodes_in_group(GROUP_BUTTONS):
		button_nodes.append(button_node)
		_correct_node_pivot_offset(button_node.get_node("Contents"))


func _correct_node_pivot_offset(node: Object) -> void:
	# Set nodes pivot offset to the center of the node.
	var pivot_offset: Vector2 = node.size / 2
	node.set_pivot_offset(pivot_offset)


func _connect_signals() -> void:
	for button_node: Object in button_nodes:
		button_node.mouse_entered.connect(
				_on_button_mouse_entered.bind(button_node))
		button_node.mouse_exited.connect(
				_on_button_mouse_exited.bind(button_node))
		button_node.button_down.connect(
				_on_button_down.bind(button_node))
		button_node.button_up.connect(
				_on_button_up.bind(button_node))


func do_object_animation(
		type: String,
		object: Object,
		from: Variant,
		to: Variant,
		speed: float):
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(object.get_node("Contents"), type,
		to, speed).from(
		from).set_trans(
		Tween.TRANS_ELASTIC).set_ease(
		Tween.EASE_OUT)


# Signals

func _on_button_mouse_entered(button_node: Object):
	do_object_animation(
		"scale",
		button_node,
		Vector2.ONE,
		Vector2(1.1, 1.1),
		0.3
	)


func _on_button_mouse_exited(button_node: Object):
	pass


func _on_button_down(button_node: Object):
	pass


func _on_button_up(button_node: Object):
	pass
