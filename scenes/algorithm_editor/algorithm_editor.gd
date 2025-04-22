
@tool
extends PanelContainer

# Child node for modifying a singular parameter
const ParameterSlider = preload("res://scenes/algorithm_editor/parameter_slider/parameter_slider.tscn")

@export var shader: String = "" # The filename of the shader, located in "res://shaders/"

@onready var algorithm_name: Label = %AlgorithmName
@onready var parameter_sliders: VBoxContainer = %ParameterSliders
@onready var hbox_container: HBoxContainer = $HBoxContainer

signal remove() # Emitted when this slider should be removed and the applied shader should be undone
signal parameter_changed(parameter, value) # Emitted when a parameter changes
signal move_up()
signal move_down()


func _ready() -> void:
	algorithm_name.text = shader.to_pascal_case()
	# Initialize parameter sliders
	for param_data in Global.algorithms[shader]["parameters"]:
		var parameter_slider = ParameterSlider.instantiate()
		parameter_slider.parameter = param_data["param"]
		parameter_slider.default_value = param_data["default_value"]
		parameter_slider.min_value = param_data["min_value"]
		parameter_slider.max_value = param_data["max_value"]
		parameter_slider.changed.connect(_on_parameter_slider_value_changed)
		parameter_sliders.add_child(parameter_slider)


func _on_parameter_slider_value_changed(parameter, value):
	parameter_changed.emit(parameter, value)


func get_parameter_value(parameter: String) -> float:
	return parameter_sliders.get_node(parameter).get_value()


# To tell the parent we should be removed
func _on_remove_button_pressed() -> void:
	remove.emit()


# To tell the parent we should be moved up in the list
func _on_move_up_pressed() -> void:
	move_up.emit()


# To tell the parent we should be moved down in the list
func _on_move_down_pressed() -> void:
	move_down.emit()
