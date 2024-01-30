extends Node

const GROUP_BUTTONS: String = "buttons"

# Values for button animations
const ANIM_VALUES_BUTTON: Dictionary = {
	"scale_normal" : Vector2.ONE,
	"scale_up" : Vector2(1.2, 1.2),
	"scale_pressed" : Vector2(0.6, 0.6),
	"rotation_normal" : 0.0,
	"rotation_pressed" : 0.1,
	"time" : 1.2,
}

# Object references
var button_nodes: Array = []


func _ready() -> void:
	_get_node_references()
	_connect_signals()


# Get all node references
func _get_node_references() -> void:
	for button_node: Object in get_tree().get_nodes_in_group(GROUP_BUTTONS):
		button_nodes.append(button_node)
		_correct_node_pivot_offset(button_node.get_node("Contents"))


# Set nodes pivot offset to the center of the node.
func _correct_node_pivot_offset(node: Object) -> void:
	var pivot_offset: Vector2 = node.size / 2
	node.set_pivot_offset(pivot_offset)


# Connect signals for buttons, eg.
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


# Object animation creates a tween between from and to using the type prompted.
# Type needs to be a valid node property for object.
func do_object_animation(
		type: String,
		object: Object,
		from: Variant,
		to: Variant,
		speed: float):
	
	# If we change scenes when pressing button, skip animations.
	if get_tree() == null:
		return
	
	# Create and play the animation.
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
		ANIM_VALUES_BUTTON.scale_normal,
		ANIM_VALUES_BUTTON.scale_up,
		ANIM_VALUES_BUTTON.time,
	)


func _on_button_mouse_exited(button_node: Object):
	do_object_animation(
		"scale",
		button_node,
		ANIM_VALUES_BUTTON.scale_up,
		ANIM_VALUES_BUTTON.scale_normal,
		ANIM_VALUES_BUTTON.time,
	)


func _on_button_down(button_node: Object):
	do_object_animation(
		"scale",
		button_node,
		ANIM_VALUES_BUTTON.scale_up,
		ANIM_VALUES_BUTTON.scale_pressed,
		ANIM_VALUES_BUTTON.time,
	)
	do_object_animation(
		"rotation",
		button_node,
		ANIM_VALUES_BUTTON.rotation_normal,
		ANIM_VALUES_BUTTON.rotation_pressed,
		ANIM_VALUES_BUTTON.time,
	)


func _on_button_up(button_node: Object):
	do_object_animation(
		"scale",
		button_node,
		ANIM_VALUES_BUTTON.scale_pressed,
		ANIM_VALUES_BUTTON.scale_up,
		ANIM_VALUES_BUTTON.time,
	)
	do_object_animation(
		"rotation",
		button_node,
		ANIM_VALUES_BUTTON.rotation_pressed,
		ANIM_VALUES_BUTTON.rotation_normal,
		ANIM_VALUES_BUTTON.time,
	)
