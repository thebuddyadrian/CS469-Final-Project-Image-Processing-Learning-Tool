@tool
extends SubViewportContainer

@export var canvas_size: Vector2 = Vector2(640, 360)
@onready var image_viewport: SubViewport = $ImageViewport
@onready var texture_rect: TextureRect = $ImageViewport/TextureRect
@onready var shader_holder: Control = $ImageViewport/ShaderHolder


func _process(_delta):
	size = canvas_size
	image_viewport.size = canvas_size
	
	var image_size: Vector2 = texture_rect.texture.get_size()
	var canvas_size_ratio: Vector2 = canvas_size / image_size # How many times bigger the canvas than the image

	texture_rect.size.y = canvas_size.y
	texture_rect.size.x = image_size.x * canvas_size_ratio.y

	texture_rect.position.y = 0
	texture_rect.position.x = (canvas_size.x - texture_rect.size.x) / 2


func add_shader(shader_name: String):
	# A back buffer copy is needed to allow multiple shaders to stack
	var back_buffer_copy := BackBufferCopy.new()
	back_buffer_copy.rect.size = texture_rect.size
	back_buffer_copy.rect.position = texture_rect.position
	back_buffer_copy.name = shader_name
	shader_holder.add_child(back_buffer_copy, true)
	
	# Add a ColorRect which will filter the image (and other ColorRects) behind it
	var color_rect := ColorRect.new()
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shaders/" + shader_name + ".gdshader")
	color_rect.material = shader_material
	color_rect.name = "ColorRect"
	back_buffer_copy.add_child(color_rect)
	color_rect.set_anchors_and_offsets_preset(PRESET_FULL_RECT)


# Remove shader at position
func remove_shader(idx: int):
	if shader_holder.get_child_count() <= idx:
		return
	shader_holder.remove_child(shader_holder.get_child(idx))


func get_shader_name(idx: int) -> String:
	return shader_holder.get_child(idx).shader


# Get the shader material at a specific index
func get_shader_material(idx: int) -> ShaderMaterial:
	var color_rect: ColorRect = shader_holder.get_child(idx).get_node("ColorRect")
	var shader_material: ShaderMaterial = color_rect.material
	return shader_material


func change_shader_parameter(index, parameter, value):
	get_shader_material(index).set_shader_parameter(parameter, value)


func move_shader_up(idx: int):
	var back_buffer_copy = shader_holder.get_child(idx)
	# Don't go up if node is already first
	if back_buffer_copy.get_index() == 0:
		return
	shader_holder.move_child(back_buffer_copy, idx - 1)


func move_shader_down(idx: int):
	var back_buffer_copy = shader_holder.get_child(idx)
	# Don't go up if node is already last
	if back_buffer_copy.get_index() == shader_holder.get_child_count() - 1:
		return
	shader_holder.move_child(back_buffer_copy, idx + 1)
