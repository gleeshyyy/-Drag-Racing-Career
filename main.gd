extends Control

class DragTrack extends Control:
	var player_progress := 0.0
	var rival_progress := 0.0
	var player_paint := Color("#f5a623")

	func set_player_paint(paint: Color) -> void:
		player_paint = paint
		queue_redraw()

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
		_draw_car(28.0 + player_progress * maxf(0.0, w - 105.0), 48.0, player_paint)
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
var race_distance := 402.0
var race_reward := 500
var rival_target_speed := 238.0
var selected_event_id := "quarter_mile"
var race_event_name := "Quarter-Mile Sprint"

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
var owned_cars: Array = ["Street Compact"]
var active_car := "Street Compact"
var car_upgrades: Dictionary = {}
var car_paints: Dictionary = {}
var owned_paints: Array = ["#f5a623"]
var paint_price := 250
var car_max_speed := 290.0
var car_acceleration := 23.0
var garage_return_to_career := false
var rival_name := "Darius Cole"
var rival_names := ["Darius Cole", "Maya Brooks", "Jaxon Reed", "Andre Silva"]
var quick_rival_name := ""
var quick_searching := false
var race_countdown_active := false
var rival_records: Dictionary = {}

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
var track_title_label: Label

func _ready() -> void:
	_load_career_save()
	_ensure_rival_records()
	_build_interface()
	_show_menu()

func _process(delta: float) -> void:
	if not race_active:
		return
	race_time += delta
	shift_cooldown = maxf(0.0, shift_cooldown - delta)
	if throttle_down:
		var gear_factor := 1.0 + float(gear - 1) * 0.025
		player_speed = minf(car_max_speed * gear_factor, player_speed + car_acceleration * gear_factor * delta)
		rpm = minf(7600.0, rpm + 3900.0 * delta)
	else:
		player_speed = maxf(0.0, player_speed - 4.0 * delta)
		rpm = maxf(900.0, rpm - 1800.0 * delta)
	rival_speed = minf(rival_target_speed, rival_speed + 19.0 * delta)
	player_distance += player_speed / 3.6 * delta
	rival_distance += rival_speed / 3.6 * delta
	_update_hud()
	if player_distance >= race_distance or rival_distance >= race_distance:
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
	quick_button.pressed.connect(_show_quick_matchmaking)
	menu_panel.add_child(quick_button)
	var garage_button := _make_button("GARAGE", Color("#34485d"))
	garage_button.add_theme_color_override("font_color", Color.WHITE)
	garage_button.pressed.connect(func():
		garage_return_to_career = false
		_show_garage()
	)
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
	track_title_label = Label.new()
	track_title_label.text = "NIGHT SPRINT  /  1⁄4 MILE"
	track_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	track_title_label.add_theme_font_size_override("font_size", 14)
	track_title_label.add_theme_color_override("font_color", Color("#f5a623"))
	track_box.add_child(track_title_label)
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
	var event: Dictionary = _get_selected_event()
	_add_section_label("SELECTED EVENT  |  WEEK 1")
	_add_section_label("%s  •  %d metres  •  Prize: $%s" % [race_event_name, int(event["distance"]), str(event["reward"])])
	var event_button := _make_button("ENTER SELECTED EVENT", Color("#f5a623"))
	event_button.pressed.connect(func():
		career_race = true
		_start_race()
	)
	section_panel.add_child(event_button)
	var choose_event_button := _make_button("SELECT RACE EVENT", Color("#2675a8"))
	choose_event_button.add_theme_color_override("font_color", Color.WHITE)
	choose_event_button.pressed.connect(_show_event_selection)
	section_panel.add_child(choose_event_button)
	_add_section_label("CAREER RECORD")
	_add_section_label("Wins: %d     Losses: %d" % [career_wins, career_losses])
	_add_section_label("Cash: $%s     Reputation: %d" % [str(career_cash), career_reputation])
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
	garage_button.pressed.connect(func():
		garage_return_to_career = true
		_show_garage()
	)
	section_panel.add_child(garage_button)
	var finances_button := _make_button("FINANCES", Color("#34485d"))
	finances_button.add_theme_color_override("font_color", Color.WHITE)
	finances_button.pressed.connect(func(): _show_info_page("FINANCES", "Career cash balance: $%s\nPrize money and expenses will be tracked here." % str(career_cash)))
	section_panel.add_child(finances_button)
	var back_button := _make_button("MAIN MENU", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_menu)
	section_panel.add_child(back_button)

func _car_catalog() -> Array:
	return [
		{"name": "Street Compact", "price": 0, "speed": 290.0, "acceleration": 23.0, "description": "Balanced starter car"},
		{"name": "Turbo Coupe", "price": 2500, "speed": 315.0, "acceleration": 27.0, "description": "Quick acceleration and strong top speed"},
		{"name": "Muscle V8", "price": 6000, "speed": 340.0, "acceleration": 25.0, "description": "High top speed with powerful launches"}
	]

func _apply_active_car() -> void:
	var selected_car: Dictionary = {}
	for car in _car_catalog():
		if str(car["name"]) == active_car:
			selected_car = car
			break
	if selected_car.is_empty():
		active_car = "Street Compact"
		selected_car = _car_catalog()[0]
	car_max_speed = float(selected_car["speed"])
	car_acceleration = float(selected_car["acceleration"])
	var upgrades: Dictionary = car_upgrades.get(active_car, {})
	var engine_level := int(upgrades.get("Engine", 0))
	var turbo_level := int(upgrades.get("Turbo", 0))
	var transmission_level := int(upgrades.get("Transmission", 0))
	var tyres_level := int(upgrades.get("Tyres", 0))
	car_max_speed += engine_level * 5.0 + turbo_level * 7.0 + transmission_level * 9.0
	car_acceleration += engine_level * 1.5 + turbo_level * 2.0 + tyres_level * 1.0

func _show_garage() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "YOUR GARAGE"
	status_label.text = "Cash: $%s  •  Active car: %s" % [str(career_cash), active_car]
	_clear_section()
	_add_section_label("OWNED CARS")
	for car in _car_catalog():
		var car_name := str(car["name"])
		var is_owned := owned_cars.has(car_name)
		var is_active := active_car == car_name
		var caption := ""
		if is_active:
			caption = "ACTIVE  •  " + car_name
		elif is_owned:
			caption = "SELECT  •  " + car_name
		else:
			caption = "BUY  •  %s  •  $%s" % [car_name, str(car["price"])]
		var car_button := _make_button(caption, Color("#f5a623") if is_active else Color("#34485d"))
		if not is_active:
			car_button.add_theme_color_override("font_color", Color.WHITE)
			if is_owned:
				car_button.pressed.connect(_select_car.bind(car_name))
			else:
				car_button.pressed.connect(_buy_car.bind(car_name))
		section_panel.add_child(car_button)
		_add_section_label("%s  •  %d km/h  •  Acceleration %d" % [str(car["description"]), int(car["speed"]), int(car["acceleration"])])
	var upgrades_button := _make_button("CAR UPGRADES", Color("#2675a8"))
	upgrades_button.add_theme_color_override("font_color", Color.WHITE)
	upgrades_button.pressed.connect(_show_upgrades)
	section_panel.add_child(upgrades_button)
	var customize_button := _make_button("CUSTOMIZE CAR", Color("#2675a8"))
	customize_button.add_theme_color_override("font_color", Color.WHITE)
	customize_button.pressed.connect(_show_customization)
	section_panel.add_child(customize_button)
	var back_button := _make_button("BACK", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	if garage_return_to_career:
		back_button.pressed.connect(_show_career_dashboard)
	else:
		back_button.pressed.connect(_show_menu)
	section_panel.add_child(back_button)

func _paint_catalog() -> Array:
	return [
		{"name": "Racing Orange", "color": "#f5a623"},
		{"name": "Midnight Black", "color": "#171b22"},
		{"name": "Rally Red", "color": "#e53935"},
		{"name": "Electric Blue", "color": "#168bd2"},
		{"name": "Pearl White", "color": "#e9edf2"},
		{"name": "Emerald Green", "color": "#159b62"},
		{"name": "Royal Purple", "color": "#8146b5"}
	]

func _show_customization() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "CAR PALETTE"
	var current_paint := str(car_paints.get(active_car, "#f5a623"))
	status_label.text = "%s  •  Personal paint selection" % active_car
	_clear_section()
	_add_section_label("ACTIVE CAR  |  " + active_car.to_upper())
	_add_section_label("CURRENT COLOR  |  " + _paint_name_for_color(current_paint))
	_add_section_label("OWNED COLORS ARE FREE TO REUSE ON EVERY CAR")
	_add_section_label("NEW COLORS COST $%s EACH" % str(paint_price))
	var palette := GridContainer.new()
	palette.columns = 2
	palette.add_theme_constant_override("h_separation", 10)
	palette.add_theme_constant_override("v_separation", 10)
	section_panel.add_child(palette)
	for paint in _paint_catalog():
		var paint_name := str(paint["name"])
		var paint_color := str(paint["color"])
		var is_owned := owned_paints.has(paint_color)
		var caption := ""
		if current_paint == paint_color:
			caption = "✓  " + paint_name + "\nCURRENT"
		elif is_owned:
			caption = paint_name + "\nSELECT"
		else:
			caption = paint_name + "\nBUY  $%s" % str(paint_price)
		var paint_button := _make_button(caption, Color(paint_color))
		paint_button.custom_minimum_size = Vector2(0, 76)
		paint_button.add_theme_font_size_override("font_size", 13)
		if paint_color == "#171b22" or paint_color == "#8146b5" or paint_color == "#168bd2":
			paint_button.add_theme_color_override("font_color", Color.WHITE)
		else:
			paint_button.add_theme_color_override("font_color", Color("#101722"))
		paint_button.pressed.connect(_buy_or_select_paint.bind(paint_color))
		palette.add_child(paint_button)
	var back_button := _make_button("BACK TO GARAGE", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_garage)
	section_panel.add_child(back_button)

func _paint_name_for_color(paint_color: String) -> String:
	for paint in _paint_catalog():
		if str(paint["color"]) == paint_color:
			return str(paint["name"])
	return "Racing Orange"

func _buy_or_select_paint(paint_color: String) -> void:
	if not owned_paints.has(paint_color):
		if career_cash < paint_price:
			status_label.text = "Not enough cash. You need $%s more." % str(paint_price - career_cash)
			return
		career_cash -= paint_price
		owned_paints.append(paint_color)
	car_paints[active_car] = paint_color
	if is_instance_valid(track_visual):
		track_visual.set_player_paint(Color(paint_color))
	_save_career()
	_show_customization()

func _upgrade_catalog() -> Array:
	return [
		{"name": "Engine", "base_price": 1200, "effect": "+5 km/h and +1.5 acceleration per level"},
		{"name": "Turbo", "base_price": 1600, "effect": "+7 km/h and +2 acceleration per level"},
		{"name": "Transmission", "base_price": 1000, "effect": "+9 km/h per level"},
		{"name": "Tyres", "base_price": 800, "effect": "+1 acceleration per level"}
	]

func _show_upgrades() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "CAR UPGRADES"
	status_label.text = "%s  •  Cash: $%s" % [active_car, str(career_cash)]
	_clear_section()
	_add_section_label("UPGRADES ARE INSTALLED ON THIS CAR ONLY")
	var upgrades: Dictionary = car_upgrades.get(active_car, {})
	for part in _upgrade_catalog():
		var part_name := str(part["name"])
		var level := int(upgrades.get(part_name, 0))
		var price := int(part["base_price"]) * (level + 1)
		_add_section_label("%s  •  Level %d/3" % [part_name, level])
		_add_section_label(str(part["effect"]))
		var caption := "MAX LEVEL" if level >= 3 else "UPGRADE  •  $%s" % str(price)
		var upgrade_button := _make_button(caption, Color("#2675a8") if level < 3 else Color("#34485d"))
		upgrade_button.add_theme_color_override("font_color", Color.WHITE)
		upgrade_button.disabled = level >= 3
		upgrade_button.pressed.connect(_buy_upgrade.bind(part_name))
		section_panel.add_child(upgrade_button)
	var back_button := _make_button("BACK TO GARAGE", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_garage)
	section_panel.add_child(back_button)

func _buy_upgrade(part_name: String) -> void:
	var upgrades: Dictionary = car_upgrades.get(active_car, {})
	var level := int(upgrades.get(part_name, 0))
	if level >= 3:
		return
	for part in _upgrade_catalog():
		if str(part["name"]) == part_name:
			var price := int(part["base_price"]) * (level + 1)
			if career_cash < price:
				status_label.text = "Not enough cash. You need $%s more." % str(price - career_cash)
				return
			career_cash -= price
			upgrades[part_name] = level + 1
			car_upgrades[active_car] = upgrades
			_apply_active_car()
			_save_career()
			_show_upgrades()
			return

func _buy_car(car_name: String) -> void:
	for car in _car_catalog():
		if str(car["name"]) == car_name and not owned_cars.has(car_name):
			var price := int(car["price"])
			if career_cash < price:
				status_label.text = "Not enough cash. You need $%s." % str(price - career_cash)
				return
			career_cash -= price
			owned_cars.append(car_name)
			active_car = car_name
			_apply_active_car()
			_save_career()
			_show_garage()
			return

func _select_car(car_name: String) -> void:
	if owned_cars.has(car_name):
		active_car = car_name
		_apply_active_car()
		_save_career()
		_show_garage()

func _event_catalog() -> Array:
	return [
		{"id": "quarter_mile", "name": "Quarter-Mile Sprint", "distance": 402.0, "reward": 500, "rival_speed": 238.0, "description": "Classic drag race. A balanced test of launch and shifting."},
		{"id": "half_mile", "name": "Half-Mile Challenge", "distance": 804.0, "reward": 850, "rival_speed": 245.0, "description": "Longer run. Top speed and clean gear changes matter."},
		{"id": "top_speed", "name": "Top Speed Shootout", "distance": 1000.0, "reward": 1200, "rival_speed": 252.0, "description": "The longest event with the toughest rival pace."}
	]

func _get_selected_event() -> Dictionary:
	for event in _event_catalog():
		if str(event["id"]) == selected_event_id:
			return event
	return _event_catalog()[0]

func _show_event_selection() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "RACE EVENTS"
	status_label.text = "Choose an event. Longer races offer larger prizes."
	_clear_section()
	for event in _event_catalog():
		var event_id := str(event["id"])
		var event_name := str(event["name"])
		var distance := int(event["distance"])
		var reward := int(event["reward"])
		_add_section_label("%s  •  %d m  •  Prize $%s" % [event_name, distance, str(reward)])
		_add_section_label(str(event["description"]))
		var caption := "SELECTED  •  " + event_name if event_id == selected_event_id else "SELECT  •  " + event_name
		var event_button := _make_button(caption, Color("#f5a623") if event_id == selected_event_id else Color("#34485d"))
		if event_id != selected_event_id:
			event_button.add_theme_color_override("font_color", Color.WHITE)
		event_button.pressed.connect(_select_event.bind(event_id))
		section_panel.add_child(event_button)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _select_event(event_id: String) -> void:
	for event in _event_catalog():
		if str(event["id"]) == event_id:
			selected_event_id = event_id
			race_event_name = str(event["name"])
			_save_career()
			_show_event_selection()
			return

func _show_calendar() -> void:
	_show_event_selection()

func _show_standings() -> void:
	var rows: Array = [{"name": "YOU", "points": career_wins * 10}]
	for name in rival_names:
		var record: Dictionary = rival_records.get(name, {})
		rows.append({"name": name, "points": int(record.get("points", 0))})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := "ROOKIE CHAMPIONSHIP\n\n"
	for index in range(rows.size()):
		body += "%d. %s — %d points\n" % [index + 1, str(rows[index]["name"]), int(rows[index]["points"])]
	_show_subpage("STANDINGS", body, "BACK TO CAREER")

func _show_rivals() -> void:
	var body := "YOUR RIVALS\n\n"
	for name in rival_names:
		var record: Dictionary = rival_records.get(name, {})
		body += "%s\nWins: %d  Losses: %d\nPoints: %d  Reputation: %d\nCar: %s\nUpgrades: %d  Rating: %d/100\n\n" % [name, int(record.get("wins", 0)), int(record.get("losses", 0)), int(record.get("points", 0)), int(record.get("reputation", 0)), str(record.get("car", "Street Compact")), int(record.get("upgrade_level", 0)), int(record.get("rating", 50))]
	_show_subpage("RIVALS", body, "BACK TO CAREER")

func _ensure_rival_records() -> void:
	for index in range(rival_names.size()):
		var name := str(rival_names[index])
		if not rival_records.has(name):
			rival_records[name] = {"wins": 0, "losses": 0, "points": 0, "reputation": 0, "rating": 50 + index * 3, "funds": 0, "car": "Street Compact", "upgrade_level": 0}

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

func _show_quick_matchmaking() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "QUICK RACE"
	status_label.text = "Find an AI driver to race against."
	_clear_section()
	_add_section_label("AI DRIVER MATCHMAKING")
	_add_section_label("Search the driver roster and choose your opponent.")
	var search_button := _make_button("SEARCH FOR OPPONENT", Color("#38a8e8"))
	search_button.pressed.connect(_search_quick_opponent)
	section_panel.add_child(search_button)
	var back_button := _make_button("BACK TO MENU", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_menu)
	section_panel.add_child(back_button)

func _search_quick_opponent() -> void:
	if quick_searching:
		return
	quick_searching = true
	_clear_section()
	_add_section_label("🔍 SEARCHING FOR OPPONENT")
	var search_status := _small_label("Scanning the local AI driver roster")
	search_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_panel.add_child(search_status)
	var search_icon := _large_label("🔍")
	search_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_panel.add_child(search_icon)
	_add_section_label("OFFLINE MATCHMAKING")
	var search_messages := [
		"Scanning available drivers",
		"Checking driver experience",
		"Comparing racing performance",
		"Finding your next rival"
	]
	for step in range(28):
		search_status.text = str(search_messages[mini(step / 7, search_messages.size() - 1)])
		for dot_count in range((step % 3) + 1):
			search_status.text += "."
		search_icon.rotation = deg_to_rad(float(step) * 18.0)
		await get_tree().create_timer(0.25).timeout
	var available_rivals := rival_names.duplicate()
	if available_rivals.size() > 1 and available_rivals.has(quick_rival_name):
		available_rivals.erase(quick_rival_name)
	quick_rival_name = str(available_rivals[randi_range(0, available_rivals.size() - 1)])
	quick_searching = false
	_clear_section()
	_add_section_label("OPPONENT FOUND")
	_add_section_label(quick_rival_name.to_upper())
	_add_section_label("AI DRIVER  •  DRAG RACING CHALLENGER")
	_add_section_label("Your opponent is ready. Get to the starting line.")
	var race_button := _make_button("RACE THIS DRIVER", Color("#f5a623"))
	race_button.pressed.connect(func():
		career_race = false
		_start_race()
	)
	section_panel.add_child(race_button)
	var search_again := _make_button("SEARCH AGAIN", Color("#38a8e8"))
	search_again.pressed.connect(_search_quick_opponent)
	section_panel.add_child(search_again)
	var back_button := _make_button("BACK TO MENU", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_menu)
	section_panel.add_child(back_button)

func _start_race() -> void:
	if race_countdown_active:
		return
	race_countdown_active = true
	section_panel.show()
	menu_panel.hide()
	race_panel.hide()
	if career_race:
		var event: Dictionary = _get_selected_event()
		race_distance = float(event["distance"])
		race_reward = int(event["reward"])
		race_event_name = str(event["name"])
	else:
		race_distance = TRACK_LENGTH
		race_reward = 0
		rival_target_speed = 238.0
		race_event_name = "Quick Race"
	race_active = false
	race_finished = false
	player_distance = 0.0
	rival_distance = 0.0
	player_speed = 0.0
	rival_speed = 0.0
	rpm = 900.0
	gear = 1
	race_time = 0.0
	throttle_down = false
	if career_race:
		rival_name = str(rival_names[(career_wins + career_losses) % rival_names.size()])
		var selected_record: Dictionary = rival_records.get(rival_name, {})
		rival_target_speed = float(_get_selected_event()["rival_speed"]) + float(selected_record.get("rating", 50) - 50) * 0.22
	else:
		rival_name = quick_rival_name if quick_rival_name != "" else rival_names[randi_range(0, rival_names.size() - 1)]
		rival_target_speed = 238.0
	title_label.text = "GET READY"
	status_label.text = "You vs %s  •  Take your position." % rival_name
	_clear_section()
	_add_section_label("RACE STARTING")
	var countdown_label := _large_label("3")
	countdown_label.add_theme_font_size_override("font_size", 76)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_panel.add_child(countdown_label)
	for count in [3, 2, 1]:
		countdown_label.text = str(count)
		await get_tree().create_timer(0.85).timeout
	countdown_label.text = "GO!"
	countdown_label.add_theme_color_override("font_color", Color("#f5a623"))
	await get_tree().create_timer(0.45).timeout
	section_panel.hide()
	race_panel.show()
	title_label.text = "MAKE YOUR MOVE"
	if is_instance_valid(track_title_label):
		track_title_label.text = "%s  /  %d M" % [race_event_name.to_upper(), int(race_distance)]
	status_label.text = "You vs %s  •  Beat them to %d metres." % [rival_name, int(race_distance)]
	_update_hud()
	race_countdown_active = false
	race_active = true

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
	distance_label.text = "%d / %d m" % [int(minf(player_distance, race_distance)), int(race_distance)]
	rpm_label.text = "RPM  %d" % int(rpm)
	gear_label.text = "GEAR  %d" % gear
	player_bar.max_value = race_distance
	player_bar.value = minf(player_distance, race_distance)
	rival_bar.max_value = race_distance
	rival_bar.value = minf(rival_distance, race_distance)
	track_visual.set_player_paint(Color(str(car_paints.get(active_car, "#f5a623"))))
	track_visual.set_progress(player_distance / race_distance, rival_distance / race_distance)

func _finish_race() -> void:
	race_active = false
	throttle_down = false
	var was_career_race := career_race
	var won := player_distance >= race_distance and player_distance >= rival_distance
	race_finished = true
	if was_career_race:
		_update_rival_career_results(won)
		if won:
			career_wins += 1
			career_cash += race_reward
			career_reputation += 10
			last_result = "Victory vs " + rival_name
		else:
			career_losses += 1
			last_result = "Defeat vs " + rival_name
		career_race = false
		_save_career()
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

func _update_rival_career_results(player_won: bool) -> void:
	_ensure_rival_records()
	var opponent: Dictionary = rival_records.get(rival_name, {})
	if player_won:
		opponent["losses"] = int(opponent.get("losses", 0)) + 1
	else:
		_record_rival_victory(opponent, race_reward)
	rival_records[rival_name] = opponent
	for name in rival_names:
		if str(name) == rival_name:
			continue
		var record: Dictionary = rival_records.get(name, {})
		if randf() < 0.55:
			_record_rival_victory(record, randi_range(500, 1200))
		else:
			record["losses"] = int(record.get("losses", 0)) + 1
		rival_records[str(name)] = record

func _record_rival_victory(record: Dictionary, prize: int) -> void:
	record["wins"] = int(record.get("wins", 0)) + 1
	record["points"] = int(record.get("points", 0)) + 10
	record["reputation"] = int(record.get("reputation", 0)) + 5
	record["funds"] = int(record.get("funds", 0)) + prize
	var rating := int(record.get("rating", 50))
	var upgrade_level := int(record.get("upgrade_level", 0))
	var car_name := str(record.get("car", "Street Compact"))
	var upgrade_cost := 900 + upgrade_level * 550
	if upgrade_level < 12 and int(record["funds"]) >= upgrade_cost and randf() < 0.65:
		record["funds"] = int(record["funds"]) - upgrade_cost
		upgrade_level += 1
		rating = mini(100, rating + randi_range(2, 4))
		record["upgrade_level"] = upgrade_level
	elif car_name == "Street Compact" and int(record["funds"]) >= 2500 and rating >= 65:
		record["funds"] = int(record["funds"]) - 2500
		record["car"] = "Turbo Coupe"
		rating = mini(100, rating + 5)
	elif car_name == "Turbo Coupe" and int(record["funds"]) >= 6000 and rating >= 82:
		record["funds"] = int(record["funds"]) - 6000
		record["car"] = "Muscle V8"
		rating = mini(100, rating + 7)
	record["rating"] = rating

func _load_career_save() -> void:
	var save := ConfigFile.new()
	var error := save.load("user://career_save.cfg")
	if error != OK:
		return
	career_wins = int(save.get_value("career", "wins", 0))
	career_losses = int(save.get_value("career", "losses", 0))
	career_cash = int(save.get_value("career", "cash", 0))
	career_reputation = int(save.get_value("career", "reputation", 0))
	rival_records = save.get_value("career", "rival_records", {})
	selected_event_id = str(save.get_value("career", "selected_event_id", "quarter_mile"))
	race_event_name = str(_get_selected_event()["name"])
	last_result = str(save.get_value("career", "last_result", "No races completed"))
	owned_cars = save.get_value("garage", "owned_cars", ["Street Compact"])
	active_car = str(save.get_value("garage", "active_car", "Street Compact"))
	car_upgrades = save.get_value("garage", "car_upgrades", {})
	car_paints = save.get_value("garage", "car_paints", {})
	owned_paints = save.get_value("garage", "owned_paints", ["#f5a623"])
	if not owned_paints.has("#f5a623"):
		owned_paints.append("#f5a623")
	for car_name in car_paints.keys():
		if not owned_paints.has(str(car_paints[car_name])):
			car_paints[car_name] = "#f5a623"
	if not owned_cars.has("Street Compact"):
		owned_cars.append("Street Compact")
	if not owned_cars.has(active_car):
		active_car = "Street Compact"
	_apply_active_car()

func _save_career() -> void:
	var save := ConfigFile.new()
	save.set_value("career", "wins", career_wins)
	save.set_value("career", "losses", career_losses)
	save.set_value("career", "cash", career_cash)
	save.set_value("career", "reputation", career_reputation)
	save.set_value("career", "rival_records", rival_records)
	save.set_value("career", "selected_event_id", selected_event_id)
	save.set_value("career", "last_result", last_result)
	save.set_value("garage", "owned_cars", owned_cars)
	save.set_value("garage", "active_car", active_car)
	save.set_value("garage", "car_upgrades", car_upgrades)
	save.set_value("garage", "car_paints", car_paints)
	save.set_value("garage", "owned_paints", owned_paints)
	var error := save.save("user://career_save.cfg")
	if error != OK:
		push_warning("Could not save career progress.")

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
