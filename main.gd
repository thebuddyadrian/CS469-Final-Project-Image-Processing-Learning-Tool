extends Control

@onready var algorithm_manager: PanelContainer = $AlgorithmManager # UI for managing and modifying different shaders
@onready var multi_shader_image: SubViewportContainer = $MultiShaderImage # An image container that allows you to apply multiple shaders and reorder them
@onready var file_dialog: FileDialog = $FileDialog
@onready var algorithm_name: Label = $TabContainer/Description/AlgorithmName
@onready var description: Label = $TabContainer/Description/Description

func _ready() -> void:
	algorithm_manager.algorithm_added.connect(multi_shader_image.add_shader)
	algorithm_manager.algorithm_removed.connect(multi_shader_image.remove_shader)
	algorithm_manager.algorithm_moved_up.connect(multi_shader_image.move_shader_up)
	algorithm_manager.algorithm_moved_down.connect(multi_shader_image.move_shader_down)
	algorithm_manager.algorithm_parameter_changed.connect(multi_shader_image.change_shader_parameter)
	algorithm_manager.algorithm_toggled.connect(multi_shader_image.set_shader_visible)
	algorithm_manager.algorithm_selected.connect(_on_algorithm_selected)


func _on_choose_image_pressed() -> void:
	file_dialog.show()

func _on_file_dialog_file_selected(path:String) -> void:
	multi_shader_image.choose_image(load(path))


func _on_algorithm_selected(_index, shader_name):
	algorithm_name.text = shader_name.replace("_", " ").capitalize()
	description.text = Global.algorithms[shader_name].get("description", "")
