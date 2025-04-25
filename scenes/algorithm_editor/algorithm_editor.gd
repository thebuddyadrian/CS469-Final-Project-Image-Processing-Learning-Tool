
@tool
extends PanelContainer

# Child node for modifying a singular parameter
const ParameterSlider = preload("res://scenes/algorithm_editor/parameter_slider/parameter_slider.tscn")

@export var shader: String = "" # The filename of the shader, located in "res://shaders/"

@onready var algorithm_name: Label = %AlgorithmName
@onready var parameter_sliders: VBoxContainer = %ParameterSliders
@onready var hbox_container: HBoxContainer = $HBoxContainer
@onready var enabled_button: Button = %EnabledButton
@onready var selected_outline: Panel = $SelectedOutline

var selected: bool: set = set_selected

signal remove() # Emitted when this slider should be removed and the applied shader should be undone
signal toggle(toggle_on) # Emitted when this algorithm should be temporarily disabled/enabled
signal parameter_changed(parameter, value) # Emitted when a parameter changes
signal move_up()
signal move_down()
signal select() # Emitted when this element was clicked, requesting to be marked as selected by the parent


func _ready() -> void:
	algorithm_name.text = shader.capitalize()
	# Initialize parameter sliders
	for param_data in Global.algorithms[shader]["parameters"]:
		var parameter_slider = ParameterSlider.instantiate()
		parameter_slider.parameter = param_data["param"]
		parameter_slider.default_value = param_data["default_value"]
		parameter_slider.min_value = param_data["min_value"]
		parameter_slider.max_value = param_data["max_value"]
		parameter_slider.changed.connect(_on_parameter_slider_value_changed)
		parameter_sliders.add_child(parameter_slider)
	# Select when added
	select.emit()


func _on_parameter_slider_value_changed(parameter, value):
	parameter_changed.emit(parameter, value)


func get_parameter_value(parameter: String) -> float:
	return parameter_sliders.get_node(parameter).get_value()


func set_selected(p_selected: bool):
	selected = p_selected
	selected_outline.visible = selected


# To tell the parent we should be removed
func _on_remove_button_pressed() -> void:
	remove.emit()


# To tell the parent we should be moved up in the list
func _on_move_up_pressed() -> void:
	move_up.emit()


# To tell the parent we should be moved down in the list
func _on_move_down_pressed() -> void:
	move_down.emit()


func _on_enabled_button_toggled(toggled_on:bool) -> void:
	if toggled_on:
		enabled_button.icon = preload("res://assets/GuiVisibilityVisible.svg")
	else:
		enabled_button.icon = preload("res://assets/GuiVisibilityHidden.svg")
	toggle.emit(toggled_on)


# When the panel is clicked, emit the select signal
# Check AlgorithmEditor and ParameterSlider, all control nodes are marked as either "Ignore" or "Pass" to make sure all clicks go through
func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			select.emit()
