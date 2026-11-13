extends Control

class DragTrack extends Control:
	var player_progress := 0.0
	var rival_progress := 0.0

	func set_progress(player_value: float, rival_value: float) -> void:
		player_progress = clampf(player_value, 0.0, 1.0)
		rival_progress = clampf(rival_value, 0.0, 1.0)
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_rect(Rect2(Vector2.ZERO, size), Color("#202a35"))
		draw_rect(Rect2(Vector2(0, 12), Vector2(w, 72)), Color("#303d4a"))
		draw_rect(Rect2(Vector2(0, 106), Vector2(w, 72)), Color("#303d4a"))
		for x in range(0, int(w), 42):
			draw_rect(Rect2(Vector2(x, 94), Vector2(22, 3)), Color("#aab5bf"))
		for y in [24.0, 118.0]:
			draw_line(Vector2(0, y + 60), Vector2(w, y + 60), Color("#687582"), 1.5)
		var finish_x := w - 24.0
		for y in range(12, 180, 12):
			draw_rect(Rect2(Vector2(finish_x, y), Vector2(8, 6)), Color.WHITE if (y / 12) % 2 == 0 else Color("#202a35"))
		_draw_car(28.0 + player_progress * maxf(0.0, w - 105.0), 48.0, Color("#f5a623"))
		_draw_car(28.0 + rival_progress * maxf(0.0, w - 105.0), 142.0, Color("#38a8e8"))

	func _draw_car(x: float, center_y: float, paint: Color) -> void:
		draw_rect(Rect2(Vector2(x, center_y - 10.0), Vector2(48, 17)), paint)
		draw_colored_polygon(PackedVector2Array([Vector2(x + 9, center_y - 10), Vector2(x + 19, center_y - 20), Vector2(x + 37, center_y - 20), Vector2(x + 44, center_y - 10)]), paint)
		draw_rect(Rect2(Vector2(x + 21, center_y - 18), Vector2(13, 7)), Color("#b9d8e8"))
		draw_circle(Vector2(x + 11, center_y + 8), 6.0, Color("#111820"))
		draw_circle(Vector2(x + 39, center_y + 8), 6.0, Color("#111820"))
		draw_circle(Vector2(x + 11, center_y + 8), 2.5, Color("#aeb9c3"))
		draw_circle(Vector2(x + 39, center_y + 8), 2.5, Color("#aeb9c3"))

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
var career_race := false
var career_wins := 0
var career_losses := 0
var career_cash := 0
var career_reputation := 0
var last_result := "No races completed"
var rival_name := "Darius Cole"
var rival_names := ["Darius Cole", "Maya Brooks", "Jaxon Reed", "Andre Silva"]

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
var section_panel: VBoxContainer
var track_visual: DragTrack

func _ready() -> void:
	_build_interface()
	_show_menu()

func _process(delta: float) -> void:
	if not race_active:
		return
	race_time += delta
	shift_cooldown = maxf(0.0, shift_cooldown - delta)
	if throttle_down:
		var gear_factor := 1.0 + float(gear - 1) * 0.025
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
	var career_button := _make_button("CAREER MODE", Color("#f5a623"))
	career_button.pressed.connect(_show_career_dashboard)
	menu_panel.add_child(career_button)
	var quick_button := _make_button("QUICK RACE", Color("#38a8e8"))
	quick_button.pressed.connect(_start_race)
	menu_panel.add_child(quick_button)
	var garage_button := _make_button("GARAGE", Color("#34485d"))
	garage_button.add_theme_color_override("font_color", Color.WHITE)
	garage_button.pressed.connect(func(): _show_info_page("GARAGE", "Your car collection will live here. Buy, sell, upgrade and customize your cars."))
	menu_panel.add_child(garage_button)
	var settings_button := _make_button("SETTINGS", Color("#34485d"))
	settings_button.add_theme_color_override("font_color", Color.WHITE)
	settings_button.pressed.connect(func(): _show_info_page("SETTINGS", "Game settings will be added here."))
	menu_panel.add_child(settings_button)

	section_panel = VBoxContainer.new()
	section_panel.add_theme_constant_override("separation", 10)
	root.add_child(section_panel)
	section_panel.hide()
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
	track_visual = DragTrack.new()
	track_visual.custom_minimum_size = Vector2(0, 190)
	track_box.add_child(track_visual)

	var rival_row := HBoxContainer.new()
	track_box.add_child(rival_row)
	rival_row.add_child(_small_label("RIVAL"))
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
	section_panel.hide()
	menu_panel.show()
	title_label.text = "THE STREETS\nARE YOURS."
	status_label.text = "Choose how you want to race."

func _show_career_dashboard() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "CAREER DASHBOARD"
	status_label.text = "SEASON 1  •  ROOKIE DIVISION"
	_clear_section()
	_add_section_label("NEXT EVENT  |  WEEK 1")
	_add_section_label("Quarter-Mile Sprint  •  402 metres")
	var event_button := _make_button("ENTER NEXT EVENT", Color("#f5a623"))
	event_button.pressed.connect(func():
		career_race = true
		_start_race()
	)
	section_panel.add_child(event_button)
	_add_section_label("CAREER RECORD")
	_add_section_label("Wins: %d     Losses: %d" % [career_wins, career_losses])
	_add_section_label("Cash: RWF %s     Reputation: %d" % [str(career_cash), career_reputation])
	_add_section_label("LAST RESULT  |  " + last_result)
	var calendar_button := _make_button("RACE CALENDAR", Color("#34485d"))
	calendar_button.add_theme_color_override("font_color", Color.WHITE)
	calendar_button.pressed.connect(_show_calendar)
	section_panel.add_child(calendar_button)
	var standings_button := _make_button("CHAMPIONSHIP STANDINGS", Color("#34485d"))
	standings_button.add_theme_color_override("font_color", Color.WHITE)
	standings_button.pressed.connect(_show_standings)
	section_panel.add_child(standings_button)
	var rivals_button := _make_button("RIVALS", Color("#34485d"))
	rivals_button.add_theme_color_override("font_color", Color.WHITE)
	rivals_button.pressed.connect(_show_rivals)
	section_panel.add_child(rivals_button)
	var garage_button := _make_button("GARAGE", Color("#34485d"))
	garage_button.add_theme_color_override("font_color", Color.WHITE)
	garage_button.pressed.connect(func(): _show_info_page("GARAGE", "Your car collection, upgrades and customization will be developed here."))
	section_panel.add_child(garage_button)
	var finances_button := _make_button("FINANCES", Color("#34485d"))
	finances_button.add_theme_color_override("font_color", Color.WHITE)
	finances_button.pressed.connect(func(): _show_info_page("FINANCES", "Career cash balance: RWF %s\nPrize money and expenses will be tracked here." % str(career_cash)))
	section_panel.add_child(finances_button)
	var back_button := _make_button("MAIN MENU", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_menu)
	section_panel.add_child(back_button)

func _show_calendar() -> void:
	_show_subpage("RACE CALENDAR", "WEEK 1  •  ROOKIE DIVISION\n\n1. Quarter-Mile Sprint — 402 m\n2. Street Sprint — coming soon\n3. Circuit Challenge — coming soon", "BACK TO CAREER")

func _show_standings() -> void:
	var text := "ROOKIE CHAMPIONSHIP\n\n1. You — %d points\n2. %s — %d points\n3. Maya Brooks — 0 points\n4. Jaxon Reed — 0 points\n5. Andre Silva — 0 points" % [career_wins * 10, rival_name, career_wins * 8]
	_show_subpage("STANDINGS", text, "BACK TO CAREER")

func _show_rivals() -> void:
	var text := "YOUR RIVALS\n\nDarius Cole — Aggressive starter\nMaya Brooks — Technical driver\nJaxon Reed — High top speed\nAndre Silva — Consistent racer\n\nRivals will develop as the season progresses."
	_show_subpage("RIVALS", text, "BACK TO CAREER")

func _show_subpage(page_title: String, body: String, back_caption: String) -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = page_title
	status_label.text = body
	_clear_section()
	var back_button := _make_button(back_caption, Color("#f5a623"))
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _show_info_page(page_title: String, description: String) -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = page_title
	status_label.text = description
	_clear_section()
	var back_button := _make_button("BACK", Color("#f5a623"))
	back_button.pressed.connect(_show_menu)
	section_panel.add_child(back_button)

func _clear_section() -> void:
	for child in section_panel.get_children():
		section_panel.remove_child(child)
		child.queue_free()

func _add_section_label(caption: String) -> void:
	var label := _small_label(caption)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	section_panel.add_child(label)

func _start_race() -> void:
	section_panel.hide()
	menu_panel.hide()
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
	rival_name = rival_names[(career_wins + career_losses) % rival_names.size()]
	status_label.text = "You vs %s  •  Beat them to the finish." % rival_name
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
		player_speed = maxf(0.0, player_speed - 8.0)
		rpm = maxf(900.0, rpm - 900.0)

func _update_hud() -> void:
	speed_label.text = "%d km/h" % int(player_speed)
	distance_label.text = "%d / 402 m" % int(minf(player_distance, TRACK_LENGTH))
	rpm_label.text = "RPM  %d" % int(rpm)
	gear_label.text = "GEAR  %d" % gear
	player_bar.value = minf(player_distance, TRACK_LENGTH)
	rival_bar.value = minf(rival_distance, TRACK_LENGTH)
	track_visual.set_progress(player_distance / TRACK_LENGTH, rival_distance / TRACK_LENGTH)

func _finish_race() -> void:
	race_active = false
	throttle_down = false
	var was_career_race := career_race
	var won := player_distance >= TRACK_LENGTH and player_distance >= rival_distance
	race_finished = true
	if was_career_race:
		if won:
			career_wins += 1
			career_cash += 500
			career_reputation += 10
			last_result = "Victory vs " + rival_name
		else:
			career_losses += 1
			last_result = "Defeat vs " + rival_name
		career_race = false
	race_panel.hide()
	if was_career_race:
		_show_career_dashboard()
	else:
		menu_panel.show()
		section_panel.hide()
		if won:
			title_label.text = "RACE WON!"
			status_label.text = "You beat %s in %.2f seconds." % [rival_name, race_time]
		else:
			title_label.text = "RACE LOST"
			status_label.text = "%s got there first. Run it back." % rival_name

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
