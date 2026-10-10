@tool
extends EditorPlugin

const DockClass := preload("res://addons/3d_viewport_bookmarks/bookmarks_dock.gd")

var _window: Window
var _dock: Control

func _enter_tree() -> void:
	_window = Window.new()
	_window.title = "3D Viewport BM"
	_window.size = Vector2i(240, 560)
	_window.transient = false
	_window.exclusive = false
	_window.unresizable = false
	_window.always_on_top = true
	_window.close_requested.connect(_on_close_requested)
	_window.set_flag(Window.FLAG_MINIMIZE_DISABLED, true)
	_window.set_flag(Window.FLAG_MAXIMIZE_DISABLED, true)

	_dock = DockClass.new()
	
	var wrapper := MarginContainer.new()
	wrapper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_window.add_child(wrapper)
	wrapper.add_child(_dock)

	EditorInterface.get_base_control().add_child(_window)
	var screen := DisplayServer.window_get_current_screen()
	var screen_pos := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	_window.position = screen_pos + (screen_size - _window.size) / 2
	_window.visible = true


func _exit_tree() -> void:
	if _window:
		_window.queue_free()
		_window = null
		_dock = null

func _on_close_requested() -> void:
	if _window:
		_window.hide()
