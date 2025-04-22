extends Control

@onready var algorithm_manager: PanelContainer = $AlgorithmManager # UI for managing and modifying different shaders
@onready var multi_shader_image: SubViewportContainer = $MultiShaderImage # An image container that allows you to apply multiple shaders and reorder them


func _ready() -> void:
	algorithm_manager.algorithm_added.connect(multi_shader_image.add_shader)
	algorithm_manager.algorithm_removed.connect(multi_shader_image.remove_shader)
	algorithm_manager.algorithm_moved_up.connect(multi_shader_image.move_shader_up)
	algorithm_manager.algorithm_moved_down.connect(multi_shader_image.move_shader_down)
	algorithm_manager.algorithm_parameter_changed.connect(multi_shader_image.change_shader_parameter)
