extends Control

const TRACK_LENGTH := 402.0
const ACCELERATION := 23.0
const MAX_SPEED := 290.0

var race_active := false
var race_finished := false
var player_distance := 0.0
var rival_distance := 0.0
var player_speed := 0.0
var rival_speed := 0.0
var rpm := 900.0
var gear := 1
var throttle_down := false
var shift_cooldown := 0.0
var race_time := 0.0
var result_text := ""

var title_label: Label
var status_label: Label
var speed_label: Label
var distance_label: Label
var rpm_label: Label
var gear_label: Label
var player_bar: ProgressBar
var rival_bar: ProgressBar
var throttle_button: Button
var shift_button: Button
var race_panel: VBoxContainer
var menu_panel: VBoxContainer

func _ready() -> void:
	_build_interface()
	_show_menu()

func _process(delta: float) -> void:
	if not race_active:
		return
	race_time += delta
	shift_cooldown = maxf(0.0, shift_cooldown - delta)
	if throttle_down:
		var gear_factor := 1.0 - float(gear - 1) * 0.075
		player_speed = minf(MAX_SPEED * gear_factor, player_speed + ACCELERATION * gear_factor * delta)
		rpm = minf(7600.0, rpm + 3900.0 * delta)
	else:
		player_speed = maxf(0.0, player_speed - 4.0 * delta)
		rpm = maxf(900.0, rpm - 1800.0 * delta)
	var rival_target := 238.0
	rival_speed = minf(rival_target, rival_speed + 19.0 * delta)
	player_distance += player_speed / 3.6 * delta
	rival_distance += rival_speed / 3.6 * delta
	_update_hud()
	if player_distance >= TRACK_LENGTH or rival_distance >= TRACK_LENGTH:
		_finish_race()

func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("#101722")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 14)
	root.add_theme_constant_override("margin_left", 22)
	root.add_theme_constant_override("margin_right", 22)
	root.add_theme_constant_override("margin_top", 30)
	root.add_theme_constant_override("margin_bottom", 24)
	add_child(root)

	var brand := Label.new()
	brand.text = "DRAG RACING CAREER"
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_theme_font_size_override("font_size", 17)
	brand.add_theme_color_override("font_color", Color("#8fa6bd"))
	root.add_child(brand)

	title_label = Label.new()
	title_label.text = "THE STREETS\nARE YOURS."
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 38)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(title_label)

	status_label = Label.new()
	status_label.text = "A new career starts with one race."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", Color("#a8b5c4"))
	root.add_child(status_label)

	menu_panel = VBoxContainer.new()
	menu_panel.add_theme_constant_override("separation", 12)
	root.add_child(menu_panel)
	var start := _make_button("START FIRST RACE", Color("#f5a623"))
	start.pressed.connect(_start_race)
	menu_panel.add_child(start)
	var note := Label.new()
	note.text = "QUARTER-MILE SPRINT  •  402 METRES"
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#7f91a5"))
	menu_panel.add_child(note)

	race_panel = VBoxContainer.new()
	race_panel.add_theme_constant_override("separation", 10)
	root.add_child(race_panel)
	race_panel.hide()

	var track_card := PanelContainer.new()
	track_card.add_theme_stylebox_override("panel", _panel_style("#1b2938"))
	race_panel.add_child(track_card)
	var track_box := VBoxContainer.new()
	track_box.add_theme_constant_override("separation", 9)
	track_card.add_child(track_box)
	var track_title := Label.new()
	track_title.text = "NIGHT SPRINT  /  1⁄4 MILE"
	track_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	track_title.add_theme_font_size_override("font_size", 14)
	track_title.add_theme_color_override("font_color", Color("#f5a623"))
	track_box.add_child(track_title)
	var road := ColorRect.new()
	road.custom_minimum_size = Vector2(0, 190)
	road.color = Color("#263442")
	track_box.add_child(road)
	var road_text := Label.new()
	road_text.text = "RIVAL LANE     ─ ─ ─ ─ ─ ─ ─ ─\n\nYOUR LANE       ─ ─ ─ ─ ─ ─ ─ ─"
	road_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	road_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	road_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	road_text.add_theme_font_size_override("font_size", 14)
	road_text.add_theme_color_override("font_color", Color("#c4d0db"))
	road.add_child(road_text)

	var rival_row := HBoxContainer.new()
	track_box.add_child(rival_row)
	var rival_name := _small_label("RIVAL")
	rival_row.add_child(rival_name)
	rival_bar = ProgressBar.new()
	rival_bar.max_value = TRACK_LENGTH
	rival_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rival_bar.show_percentage = false
	rival_row.add_child(rival_bar)
	var player_row := HBoxContainer.new()
	track_box.add_child(player_row)
	player_row.add_child(_small_label("YOU"))
	player_bar = ProgressBar.new()
	player_bar.max_value = TRACK_LENGTH
	player_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_bar.show_percentage = false
	player_row.add_child(player_bar)

	speed_label = _large_label("0 km/h")
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	race_panel.add_child(speed_label)
	distance_label = _small_label("0 / 402 m")
	distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	race_panel.add_child(distance_label)
	rpm_label = _small_label("RPM  900")
	rpm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	race_panel.add_child(rpm_label)
	gear_label = _small_label("GEAR  1")
	gear_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	race_panel.add_child(gear_label)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	race_panel.add_child(controls)
	shift_button = _make_button("SHIFT", Color("#2675a8"))
	shift_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shift_button.pressed.connect(_shift_gear)
	controls.add_child(shift_button)
	throttle_button = _make_button("HOLD TO ACCELERATE", Color("#e58d22"))
	throttle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	throttle_button.button_down.connect(func(): throttle_down = true)
	throttle_button.button_up.connect(func(): throttle_down = false)
	controls.add_child(throttle_button)

	var hint := Label.new()
	hint.text = "Hold ACCELERATE. Tap SHIFT as RPM climbs."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#91a1b2"))
	race_panel.add_child(hint)

func _show_menu() -> void:
	race_active = false
	race_panel.hide()
	menu_panel.show()
	title_label.text = "THE STREETS\nARE YOURS."
	status_label.text = "A new career starts with one race."

func _start_race() -> void:
	race_active = true
	race_finished = false
	player_distance = 0.0
	rival_distance = 0.0
	player_speed = 0.0
	rival_speed = 0.0
	rpm = 900.0
	gear = 1
	race_time = 0.0
	throttle_down = false
	menu_panel.hide()
	race_panel.show()
	title_label.text = "MAKE YOUR MOVE"
	status_label.text = "Beat the rival to the finish."
	_update_hud()

func _shift_gear() -> void:
	if not race_active or shift_cooldown > 0.0:
		return
	if rpm >= 4200.0 and gear < 5:
		gear += 1
		rpm *= 0.68
		shift_cooldown = 0.35
		gear_label.text = "GEAR  %d" % gear
	else:
		# A mistimed shift costs a little speed.
		player_speed = maxf(0.0, player_speed - 8.0)
		rpm = maxf(900.0, rpm - 900.0)

func _update_hud() -> void:
	speed_label.text = "%d km/h" % int(player_speed)
	distance_label.text = "%d / 402 m" % int(minf(player_distance, TRACK_LENGTH))
	rpm_label.text = "RPM  %d" % int(rpm)
	gear_label.text = "GEAR  %d" % gear
	player_bar.value = minf(player_distance, TRACK_LENGTH)
	rival_bar.value = minf(rival_distance, TRACK_LENGTH)

func _finish_race() -> void:
	race_active = false
	throttle_down = false
	var won := player_distance >= TRACK_LENGTH and player_distance >= rival_distance
	race_finished = true
	menu_panel.show()
	race_panel.hide()
	if won:
		title_label.text = "RACE WON!"
		status_label.text = "You beat the rival in %.2f seconds." % race_time
		var again := _make_button("RACE AGAIN", Color("#f5a623"))
		again.pressed.connect(_start_race)
		menu_panel.add_child(again)
	else:
		title_label.text = "RACE LOST"
		status_label.text = "The rival got there first. Run it back."
		var again := _make_button("TRY AGAIN", Color("#f5a623"))
		again.pressed.connect(_start_race)
		menu_panel.add_child(again)

func _make_button(caption: String, fill: Color) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 58)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("#101722"))
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = fill.lightened(0.08)
	button.add_theme_stylebox_override("hover", hover)
	return button

func _panel_style(fill: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill)
	style.set_content_margin_all(12)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style

func _small_label(caption: String) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("#b8c6d4"))
	return label

func _large_label(caption: String) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color("#ffffff"))
	return label
