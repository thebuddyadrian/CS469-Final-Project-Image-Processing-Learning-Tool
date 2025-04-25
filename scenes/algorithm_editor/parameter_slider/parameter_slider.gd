extends HBoxContainer

@export var parameter: String # The parameter to set on the shader
@export var default_value: float = 0.0
@export var min_value: float = 0.0
@export var max_value: float = 1.0

@onready var parameter_name: Label = $ParameterName
@onready var value_slider: HSlider = $ValueSlider
@onready var value_entry: SpinBox = $ValueEntry

signal changed(parameter, value) # Emitted when the value of this slider changes


func _ready() -> void:
	parameter_name.text = parameter.capitalize()
	value_entry.min_value = min_value
	value_slider.min_value = min_value
	value_entry.max_value = max_value
	value_slider.max_value = max_value
	value_entry.value = default_value
	value_slider.value = default_value
	changed.emit(parameter, get_value())


# Makes sure the Slider and SpinBox stay in sync
func _on_value_slider_value_changed(value:float) -> void:
	value_entry.value = value
	changed.emit(parameter, value)


# Makes sure the Slider and SpinBox stay in sync
func _on_value_entry_value_changed(value:float) -> void:
	value_slider.value = value
	changed.emit(parameter, value)


func get_value() -> float:
	return value_entry.value


func set_value(p_value: float):
	value_entry.value = p_value
	value_slider.value = p_value

func _on_reset_button_pressed() -> void:
	value_entry.value = default_value
	value_slider.value = default_value
