extends HBoxContainer

@export var shader: String = "" # The filename of the shader, located in "res://shaders/"

@onready var value_slider: HSlider = $ValueSlider
@onready var value_spin_box: SpinBox = $ValueSpinBox
@onready var applied_label: Label = $ValueSlider/AppliedLabel
@onready var algorithm_name: Label = $AlgorithmName

var applied: bool = false

signal remove # Emitted when this slider should be removed and the applied shader should be undone
signal changed(shader, value) # Emitted when the value of this slider changes


func _ready() -> void:
	algorithm_name.text = shader.to_pascal_case()
	applied_label.hide()


# Makes sure the Slider and SpinBox stay in sync
func _on_value_slider_value_changed(value:float) -> void:
	value_spin_box.value = value
	changed.emit(shader, value)


# Makes sure the Slider and SpinBox stay in sync
func _on_value_spin_box_value_changed(value:float) -> void:
	value_slider.value = value
	changed.emit(shader, value)


func get_value() -> float:
	return value_spin_box.value


func set_value(p_value: float):
	value_spin_box.value = p_value
	value_slider.value = p_value


func _on_remove_button_pressed() -> void:
	remove.emit()
