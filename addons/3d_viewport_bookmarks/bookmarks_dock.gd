@tool
extends VBoxContainer

const SLOT_COUNT := 10
const DATA_PATH := "res://addons/3d_viewport_bookmarks/bookmarks.json"

# --- Style -------------------------------------------------------------------
# S (Save)
# L (Load)
# 

const S_EMPTY        := Color(0.23, 0.302, 0.39, 1.0)
const S_EMPTY_HOVER  := Color(0.28, 0.40, 0.56)
const S_EMPTY_PRESS  := Color(0.14, 0.16, 0.20)

const S_FILLED       := Color(0.212, 0.279, 0.36, 1.0)
const S_FILLED_HOVER := Color(0.28, 0.40, 0.56)
const S_FILLED_PRESS := Color(0.17, 0.25, 0.38)

const L_EMPTY        := Color(0.38, 0.38, 0.38, 1.0)
const L_EMPTY_HOVER  := Color(0.27, 0.24, 0.32)
const L_EMPTY_PRESS  := Color(0.15, 0.14, 0.20)

const L_FILLED       := Color(0.17, 0.237, 0.32, 1.0)
const L_FILLED_HOVER := Color(0.302, 0.388, 0.56, 1.0)
const L_FILLED_PRESS := Color(0.179, 0.246, 0.38, 1.0)

const COLOR_EMPTY_DIS    := Color(0.27, 0.27, 0.27, 1.0)
const FONT_COLOR         := Color(0.90, 0.90, 0.90)
const FONT_COLOR_DIS     := Color(0.57, 0.57, 0.57, 1.0)

# --- Состояние ---------------------------------------------------------------

var _slots: Array = []          # Array[Dictionary | null], длина = SLOT_COUNT
var _buttons: Array = []        # Array[Dictionary], {save, load}

# --- Lifecycle ---------------------------------------------------------------

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_FILL
	custom_minimum_size = Vector2(146, 0)

	_slots.resize(SLOT_COUNT)
	for i in range(SLOT_COUNT):
		_slots[i] = null

	_load_data()
	_build_ui()
	_refresh_buttons()

# --- UI ----------------------------------------------------------------------

func _build_ui() -> void:
	for i in range(SLOT_COUNT):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 2)

		var s := Button.new()
		s.text = "S%d" % (i + 1)
		s.tooltip_text = "Save current view to slot %d" % (i + 1)
		s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s.pressed.connect(_on_save_pressed.bind(i))
		_apply_button_style(s, false, true)
		row.add_child(s)

		var l := Button.new()
		l.text = "L%d" % (i + 1)
		l.tooltip_text = "Load view from slot %d" % (i + 1)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.pressed.connect(_on_load_pressed.bind(i))
		_apply_button_style(l, false, false)
		row.add_child(l)

		add_child(row)
		_buttons.append({"save": s, "load": l})

func _refresh_buttons() -> void:
	for i in range(SLOT_COUNT):
		var has_data: bool = _slots[i] != null
		_buttons[i]["load"].disabled = not has_data
		_apply_button_style(_buttons[i]["save"], has_data, true)
		_apply_button_style(_buttons[i]["load"], has_data, false)

# --- Styling -----------------------------------------------------------------

func _make_style(bg: Color, radius := 3) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	return sb

func _apply_button_style(btn: Button, filled: bool, is_save: bool) -> void:
	var n: Color
	var h: Color
	var p: Color

	if is_save:
		if filled:
			n = S_FILLED
			h = S_FILLED_HOVER
			p = S_FILLED_PRESS
		else:
			n = S_EMPTY
			h = S_EMPTY_HOVER
			p = S_EMPTY_PRESS
	else:
		if filled:
			n = L_FILLED
			h = L_FILLED_HOVER
			p = L_FILLED_PRESS
		else:
			n = L_EMPTY
			h = L_EMPTY_HOVER
			p = L_EMPTY_PRESS

	btn.add_theme_stylebox_override("normal",   _make_style(n))
	btn.add_theme_stylebox_override("hover",    _make_style(h))
	btn.add_theme_stylebox_override("pressed",  _make_style(p))
	btn.add_theme_stylebox_override("focus",    _make_style(h))
	btn.add_theme_stylebox_override("disabled", _make_style(COLOR_EMPTY_DIS))

	btn.add_theme_color_override("font_color",          FONT_COLOR)
	btn.add_theme_color_override("font_hover_color",    FONT_COLOR)
	btn.add_theme_color_override("font_pressed_color",  FONT_COLOR)
	btn.add_theme_color_override("font_focus_color",    FONT_COLOR)
	btn.add_theme_color_override("font_disabled_color", FONT_COLOR_DIS)

# --- Camera lookup -----------------------------------------------------------

func _get_editor_camera() -> Camera3D:
	var vp := EditorInterface.get_editor_viewport_3d(0)
	if vp == null:
		return null
	return _find_camera(vp)

func _find_camera(node: Node) -> Camera3D:
	if node is Camera3D:
		return node
	for c in node.get_children():
		var r := _find_camera(c)
		if r != null:
			return r
	return null

# --- Slots -------------------------------------------------------------------

func _on_save_pressed(index: int) -> void:
	var cam := _get_editor_camera()
	if cam == null:
		push_warning("[CameraBookmarks] Editor camera not found")
		return
	var t := cam.global_transform
	_slots[index] = {
		"basis": [
			[t.basis.x.x, t.basis.x.y, t.basis.x.z],
			[t.basis.y.x, t.basis.y.y, t.basis.y.z],
			[t.basis.z.x, t.basis.z.y, t.basis.z.z],
		],
		"origin": [t.origin.x, t.origin.y, t.origin.z],
	}
	_save_data()
	_refresh_buttons()

func _on_load_pressed(index: int) -> void:
	var slot: Variant = _slots[index]
	if slot == null:
		return
	var cam := _get_editor_camera()
	if cam == null:
		push_warning("[CameraBookmarks] Editor camera not found")
		return
	var t := _dict_to_transform(slot)
	_apply_camera_transform(cam, t)

func _dict_to_transform(d: Dictionary) -> Transform3D:
	var b: Array = d["basis"]
	var o: Array = d["origin"]
	var basis := Basis(
		Vector3(b[0][0], b[0][1], b[0][2]),
		Vector3(b[1][0], b[1][1], b[1][2]),
		Vector3(b[2][0], b[2][1], b[2][2])
	)
	return Transform3D(basis, Vector3(o[0], o[1], o[2]))

func _apply_camera_transform(cam: Camera3D, t: Transform3D) -> void:
	cam.global_transform = t
	var node: Node = cam
	while node != null:
		if node.get_class() == "Node3DEditorViewport":
			if node.has_method("set_camera_transform"):
				node.call("set_camera_transform", t)
			break
		node = node.get_parent()

# --- Persistence -------------------------------------------------------------

func _load_data() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		return
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return
	var arr: Variant = parsed.get("slots", [])
	if not (arr is Array):
		return
	for i in range(min(SLOT_COUNT, arr.size())):
		if arr[i] != null:
			_slots[i] = arr[i]

func _save_data() -> void:
	var data := {"slots": _slots}
	var f := FileAccess.open(DATA_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("[CameraBookmarks] Cannot write %s" % DATA_PATH)
		return
	f.store_string(JSON.stringify(data, "  "))
	f.close()
