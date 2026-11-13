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
var rival_acceleration := 19.0
var rpm := 900.0
var gear := 1
var throttle_down := false
var shift_cooldown := 0.0
var race_time := 0.0
var race_top_speed := 0.0
var nitro_remaining := 100.0
var nitro_capacity := 100.0
var nitro_used := 0.0
var nitro_down := false
var nitro_active := false
var last_top_speed_record := false
var race_track_condition := "DRY ASPHALT"
var player_grip_multiplier := 1.0
var rival_grip_multiplier := 1.0
var personal_bests: Dictionary = {}
var personal_top_speeds: Dictionary = {}
var race_history: Array = []
var current_win_streak := 0
var best_win_streak := 0
var career_race := false
var career_wins := 0
var career_losses := 0
var career_cash := 0
var career_reputation := 0
var career_xp := 0
var season_number := 1
var season_points: Dictionary = {}
var season_events_completed: Array = []
var last_season_points: Dictionary = {}
var last_season_number := 0
var last_season_champion := ""
var last_season_message := ""
var sponsor_contract_name := ""
var sponsor_contract_target := 0
var sponsor_contract_progress := 0
var sponsor_contract_reward := 0
var last_sponsor_message := ""
var achievements: Dictionary = {}
var last_achievement_message := ""
var last_xp_earned := 0
var last_level_up := false
var last_result := "No races completed"
var story_stage := 0
var story_completed := false
var last_story_message := ""
var active_jasper_job := ""
var jasper_job_progress := 0
var completed_jasper_jobs: Array = []
var last_jasper_job_message := ""
var career_month := 1
var races_this_month := 0
var child_support_due := 0
var household_expenses_due := 0
var child_support_paid_total := 0
var household_paid_total := 0
var missed_payment_months := 0
var last_finance_message := ""
var owned_cars: Array = ["Street Compact"]
var active_car := "Street Compact"
var car_upgrades: Dictionary = {}
var car_condition: Dictionary = {}
var last_condition_loss := 0.0
var car_fuel: Dictionary = {}
var last_fuel_used := 0.0
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
var nitro_button: Button
var nitro_bar: ProgressBar
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
	nitro_active = throttle_down and nitro_down and nitro_remaining > 0.0
	if nitro_active:
		var nitro_drain := minf(nitro_remaining, 35.0 * delta)
		nitro_remaining -= nitro_drain
		nitro_used += nitro_drain
	if throttle_down:
		var gear_factor := 1.0 + float(gear - 1) * 0.025
		var boost_multiplier := 1.65 if nitro_active else 1.0
		var speed_limit := car_max_speed + (35.0 if nitro_active else 0.0)
		player_speed = minf(speed_limit * gear_factor, player_speed + car_acceleration * player_grip_multiplier * gear_factor * boost_multiplier * delta)
		rpm = minf(7600.0, rpm + 3900.0 * delta)
	else:
		player_speed = maxf(0.0, player_speed - 4.0 * delta)
		rpm = maxf(900.0, rpm - 1800.0 * delta)
	rival_speed = minf(rival_target_speed, rival_speed + rival_acceleration * rival_grip_multiplier * delta)
	race_top_speed = maxf(race_top_speed, player_speed)
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
	nitro_button = _make_button("NITRO  |  100%", Color("#25a9a1"))
	nitro_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nitro_button.button_down.connect(func(): nitro_down = true)
	nitro_button.button_up.connect(func(): nitro_down = false)
	nitro_button.disabled = false
	race_panel.add_child(nitro_button)
	nitro_bar = ProgressBar.new()
	nitro_bar.min_value = 0.0
	nitro_bar.max_value = nitro_capacity
	nitro_bar.value = nitro_remaining
	nitro_bar.show_percentage = false
	race_panel.add_child(nitro_bar)

	var hint := Label.new()
	hint.text = "Hold ACCELERATE. Tap SHIFT as RPM climbs. Hold NITRO with throttle for a short boost."
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
	_add_section_label("SEASON %d  |  EVENTS COMPLETED: %d / %d" % [season_number, season_events_completed.size(), _event_catalog().size()])
	_add_section_label("SELECTED EVENT  |  WEEK 1")
	_add_section_label("%s  •  %d metres  •  Prize: $%s" % [race_event_name, int(event["distance"]), str(event["reward"])])
	var best_time := float(personal_bests.get(selected_event_id, 0.0))
	if best_time > 0.0:
		_add_section_label("PERSONAL BEST: %.2f seconds" % best_time)
	else:
		_add_section_label("PERSONAL BEST: No record yet")
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
	_add_section_label("DRIVER LEVEL  %d  •  XP %d / %d" % [_driver_level(), career_xp % 250, 250])
	_add_section_label("CAREER RECORD")
	_add_section_label("Wins: %d     Losses: %d" % [career_wins, career_losses])
	_add_section_label("Cash: $%s     Reputation: %d" % [str(career_cash), career_reputation])
	_add_section_label("LAST RESULT  |  " + last_result)
	var story_button := _make_button("STORY & MISSIONS", Color("#34485d"))
	story_button.add_theme_color_override("font_color", Color.WHITE)
	story_button.pressed.connect(_show_story_missions)
	section_panel.add_child(story_button)
	var jobs_button := _make_button("JASPER'S GIGS", Color("#34485d"))
	jobs_button.add_theme_color_override("font_color", Color.WHITE)
	jobs_button.pressed.connect(_show_jasper_jobs)
	section_panel.add_child(jobs_button)
	var history_button := _make_button("RACE HISTORY", Color("#34485d"))
	history_button.add_theme_color_override("font_color", Color.WHITE)
	history_button.pressed.connect(_show_race_history)
	section_panel.add_child(history_button)
	var profile_button := _make_button("DRIVER PROFILE", Color("#34485d"))
	profile_button.add_theme_color_override("font_color", Color.WHITE)
	profile_button.pressed.connect(_show_driver_profile)
	section_panel.add_child(profile_button)
	var calendar_button := _make_button("RACE CALENDAR", Color("#34485d"))
	calendar_button.add_theme_color_override("font_color", Color.WHITE)
	calendar_button.pressed.connect(_show_calendar)
	section_panel.add_child(calendar_button)
	var standings_button := _make_button("CHAMPIONSHIP STANDINGS", Color("#34485d"))
	standings_button.add_theme_color_override("font_color", Color.WHITE)
	standings_button.pressed.connect(_show_standings)
	section_panel.add_child(standings_button)
	var achievements_button := _make_button("ACHIEVEMENTS", Color("#34485d"))
	achievements_button.add_theme_color_override("font_color", Color.WHITE)
	achievements_button.pressed.connect(_show_achievements)
	section_panel.add_child(achievements_button)
	var sponsor_button := _make_button("SPONSOR CONTRACTS", Color("#34485d"))
	sponsor_button.add_theme_color_override("font_color", Color.WHITE)
	sponsor_button.pressed.connect(_show_sponsor_contracts)
	section_panel.add_child(sponsor_button)
	var season_button := _make_button("SEASON STANDINGS", Color("#34485d"))
	season_button.add_theme_color_override("font_color", Color.WHITE)
	season_button.pressed.connect(_show_season_standings)
	section_panel.add_child(season_button)
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
	finances_button.pressed.connect(_show_finances)
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
	var condition := clampf(float(car_condition.get(active_car, 100.0)), 0.0, 100.0)
	var condition_factor := condition / 100.0
	car_max_speed *= 1.0 - (1.0 - condition_factor) * 0.15
	car_acceleration *= 1.0 - (1.0 - condition_factor) * 0.25
	var fuel := clampf(float(car_fuel.get(active_car, 100.0)), 0.0, 100.0)
	if fuel < 20.0:
		var fuel_factor := 0.70 + fuel / 20.0 * 0.30
		car_max_speed *= 0.90 + fuel / 20.0 * 0.10
		car_acceleration *= fuel_factor

func _service_active_car() -> void:
	var condition := clampf(float(car_condition.get(active_car, 100.0)), 0.0, 100.0)
	var wear := 100.0 - condition
	if wear <= 0.0 or career_cash <= 0:
		_show_garage()
		return
	var repair_amount := minf(wear, float(career_cash) / 25.0)
	var repair_cost := mini(career_cash, int(ceil(repair_amount * 25.0)))
	if repair_amount <= 0.0 or repair_cost <= 0:
		_show_garage()
		return
	car_condition[active_car] = minf(100.0, condition + repair_amount)
	career_cash -= repair_cost
	_apply_active_car()
	_save_career()
	_show_garage()

func _refuel_active_car() -> void:
	var fuel := clampf(float(car_fuel.get(active_car, 100.0)), 0.0, 100.0)
	var missing_fuel := 100.0 - fuel
	if missing_fuel <= 0.0 or career_cash <= 0:
		_show_garage()
		return
	var refill_amount := minf(missing_fuel, float(career_cash) / 10.0)
	var refill_cost := mini(career_cash, int(ceil(refill_amount * 10.0)))
	if refill_amount <= 0.0 or refill_cost <= 0:
		_show_garage()
		return
	car_fuel[active_car] = minf(100.0, fuel + refill_amount)
	career_cash -= refill_cost
	_apply_active_car()
	_save_career()
	_show_garage()

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
	var condition := clampf(float(car_condition.get(active_car, 100.0)), 0.0, 100.0)
	_add_section_label("ACTIVE CAR CONDITION  |  %.1f%%" % condition)
	_add_section_label("Wear reduces speed and acceleration. Service restores full performance.")
	var service_cost := int(ceil((100.0 - condition) * 25.0))
	var service_button := _make_button("SERVICE CAR  |  $%s" % str(service_cost), Color("#25a9a1"))
	service_button.disabled = condition >= 99.9 or career_cash <= 0
	service_button.pressed.connect(_service_active_car)
	section_panel.add_child(service_button)
	var fuel := clampf(float(car_fuel.get(active_car, 100.0)), 0.0, 100.0)
	_add_section_label("FUEL LEVEL  |  %.1f%%" % fuel)
	_add_section_label("Low fuel reduces engine performance. Refuelling costs $10 per 1%.")
	var refuel_cost := int(ceil((100.0 - fuel) * 10.0))
	var refuel_button := _make_button("REFUEL CAR  |  $%s" % str(refuel_cost), Color("#2675a8"))
	refuel_button.add_theme_color_override("font_color", Color.WHITE)
	refuel_button.disabled = fuel >= 99.9 or career_cash <= 0
	refuel_button.pressed.connect(_refuel_active_car)
	section_panel.add_child(refuel_button)
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
		{"name": "Tyres", "base_price": 800, "effect": "+1 acceleration per level"},
		{"name": "Nitro", "base_price": 1800, "effect": "+25% nitro tank capacity per level"}
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
		{"id": "eighth_mile", "name": "Eighth-Mile Dash", "distance": 201.0, "reward": 300, "rival_speed": 232.0, "description": "A short explosive sprint. Launch reaction and acceleration decide the winner."},
		{"id": "quarter_mile", "name": "Quarter-Mile Sprint", "distance": 402.0, "reward": 500, "rival_speed": 238.0, "description": "Classic drag race. A balanced test of launch and shifting."},
		{"id": "pro_quarter", "name": "Pro Quarter-Mile", "distance": 402.0, "reward": 900, "rival_speed": 247.0, "description": "A tougher quarter-mile event with a stronger rival field."},
		{"id": "half_mile", "name": "Half-Mile Challenge", "distance": 804.0, "reward": 1200, "rival_speed": 250.0, "description": "Longer run. Top speed and clean gear changes matter."},
		{"id": "top_speed", "name": "Top Speed Shootout", "distance": 1000.0, "reward": 1600, "rival_speed": 255.0, "description": "A high-speed test against experienced drivers."},
		{"id": "mile_run", "name": "One-Mile Showdown", "distance": 1609.0, "reward": 2500, "rival_speed": 260.0, "description": "The ultimate endurance drag event. Hold speed and shift cleanly."}
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

func _show_race_history() -> void:
	var body := "RECENT RACE HISTORY\n\n"
	var total := race_history.size()
	body += "RECORDED RACES  |  %d / 30\n" % total
	body += "CAREER WIN STREAK  |  %d\n" % current_win_streak
	body += "BEST WIN STREAK  |  %d\n\n" % best_win_streak
	if race_history.is_empty():
		body += "No races recorded yet. Complete a race to start your history."
	else:
		body += "SHOWING MOST RECENT 10 RACES\n\n"
		for index in range(mini(race_history.size(), 10)):
			var entry: Dictionary = race_history[index]
			body += "%d. %s  |  %s\n" % [index + 1, str(entry.get("result", "UNKNOWN")), str(entry.get("event", "Race"))]
			body += "Opponent: %s  •  Time: %.2f sec\n" % [str(entry.get("opponent", "Unknown")), float(entry.get("time", 0.0))]
			body += "Top speed: %d km/h\n" % int(entry.get("top_speed", 0.0))
			body += "Track: %s\n" % str(entry.get("condition", "Unknown"))
			body += "Distance: %d m  •  Prize: $%s  •  %s\n" % [int(entry.get("distance", 0)), str(entry.get("prize", 0)), str(entry.get("mode", "Career"))]
			body += "%s\n\n" % str(entry.get("date", ""))
	_show_subpage("RACE HISTORY", body, "BACK TO CAREER")

func _show_driver_profile() -> void:
	var total_races := career_wins + career_losses
	var win_rate := 0.0
	if total_races > 0:
		win_rate = float(career_wins) * 100.0 / float(total_races)
	var body := "DRIVER PROFILE\n\n"
	body += "DRIVER LEVEL  |  %d\n" % _driver_level()
	body += "TOTAL XP  |  %d\n" % career_xp
	body += "LEVEL PROGRESS  |  %d / 250 XP\n\n" % (career_xp % 250)
	body += "CAREER RECORD\n"
	body += "Wins  |  %d\nLosses  |  %d\nWin Rate  |  %.1f%%\n" % [career_wins, career_losses, win_rate]
	body += "Reputation  |  %d\nCash  |  $%s\nActive Car  |  %s\n" % [career_reputation, str(career_cash), active_car]
	body += "Current Win Streak  |  %d\nBest Win Streak  |  %d\n\n" % [current_win_streak, best_win_streak]
	body += "PERSONAL BEST RECORDS\n"
	for event in _event_catalog():
		var event_id := str(event["id"])
		var best := float(personal_bests.get(event_id, 0.0))
		var top_speed := float(personal_top_speeds.get(event_id, 0.0))
		body += "%s  |  %s  |  Top speed: %d km/h\n" % [str(event["name"]), "%.2f sec" % best if best > 0.0 else "No record", int(top_speed)]
	var quick_best := float(personal_bests.get("quick_402", 0.0))
	var quick_top_speed := float(personal_top_speeds.get("quick_402", 0.0))
	body += "Quick Race  |  %s  |  Top speed: %d km/h" % ["%.2f sec" % quick_best if quick_best > 0.0 else "No record", int(quick_top_speed)]
	_show_subpage("DRIVER PROFILE", body, "BACK TO CAREER")

func _check_achievements(new_personal_best: bool) -> void:
	last_achievement_message = ""
	var total_races := career_wins + career_losses
	var unlocked: Array[String] = []
	if career_wins >= 1 and _unlock_achievement("first_win"):
		unlocked.append("First Victory")
	if career_wins >= 10 and _unlock_achievement("ten_wins"):
		unlocked.append("Ten Wins")
	if best_win_streak >= 5 and _unlock_achievement("streak_5"):
		unlocked.append("Unstoppable")
	if total_races >= 25 and _unlock_achievement("veteran_25"):
		unlocked.append("Quarter-Century Racer")
	if _driver_level() >= 5 and _unlock_achievement("level_5"):
		unlocked.append("Rising Star")
	if last_season_message.contains("CHAMPION!") and _unlock_achievement("season_champion"):
		unlocked.append("Season Champion")
	if last_sponsor_message.contains("CONTRACT COMPLETE") and _unlock_achievement("sponsor_complete"):
		unlocked.append("Sponsor's Choice")
	if new_personal_best and _unlock_achievement("record_breaker"):
		unlocked.append("Record Breaker")
	if not unlocked.is_empty():
		last_achievement_message = "ACHIEVEMENT UNLOCKED: "
		for index in range(unlocked.size()):
			if index > 0:
				last_achievement_message += ", "
			last_achievement_message += unlocked[index]

func _unlock_achievement(achievement_id: String) -> bool:
	if bool(achievements.get(achievement_id, false)):
		return false
	achievements[achievement_id] = true
	return true

func _show_achievements() -> void:
	var achievement_names := {
		"first_win": ["First Victory", "Win your first Career race"],
		"ten_wins": ["Ten Wins", "Earn 10 Career victories"],
		"streak_5": ["Unstoppable", "Win 5 Career races in a row"],
		"veteran_25": ["Quarter-Century Racer", "Complete 25 Career races"],
		"level_5": ["Rising Star", "Reach Driver Level 5"],
		"season_champion": ["Season Champion", "Win a complete championship season"],
		"sponsor_complete": ["Sponsor's Choice", "Complete a sponsorship contract"],
		"record_breaker": ["Record Breaker", "Set a new personal best"]
	}
	var body := "CAREER ACHIEVEMENTS\n\n"
	var unlocked_count := 0
	for achievement_id in achievement_names.keys():
		var details: Array = achievement_names[achievement_id]
		var is_unlocked := bool(achievements.get(achievement_id, false))
		if is_unlocked:
			unlocked_count += 1
		body += "%s  %s\n%s\n\n" % ["[UNLOCKED]" if is_unlocked else "[LOCKED]", str(details[0]), str(details[1])]
	body += "UNLOCKED: %d / %d" % [unlocked_count, achievement_names.size()]
	_show_subpage("ACHIEVEMENTS", body, "BACK TO CAREER")

func _show_sponsor_contracts() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "SPONSOR CONTRACTS"
	status_label.text = "Accept one contract and complete its racing objective for a cash reward."
	_clear_section()
	if sponsor_contract_name != "":
		_add_section_label("ACTIVE SPONSOR  |  " + sponsor_contract_name)
		_add_section_label("CAREER RACE WINS  |  %d / %d" % [sponsor_contract_progress, sponsor_contract_target])
		_add_section_label("COMPLETION REWARD  |  $%s" % str(sponsor_contract_reward))
	else:
		_add_section_label("NO ACTIVE CONTRACT")
		_add_section_label("Choose one sponsor challenge:")
		_add_sponsor_offer("Street Performance", 2, 1500)
		_add_sponsor_offer("Turbo Works", 3, 2500)
		_add_sponsor_offer("Elite Motors", 5, 4500)
	var back_button := _make_button("BACK TO CAREER", Color("#f5a623"))
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _add_sponsor_offer(sponsor: String, target: int, reward: int) -> void:
	var offer := _make_button("%s  |  Win %d Career races  |  $%s" % [sponsor, target, str(reward)], Color("#34485d"))
	offer.add_theme_color_override("font_color", Color.WHITE)
	offer.pressed.connect(func(): _accept_sponsor_contract(sponsor, target, reward))
	section_panel.add_child(offer)

func _accept_sponsor_contract(sponsor: String, target: int, reward: int) -> void:
	if sponsor_contract_name != "":
		return
	sponsor_contract_name = sponsor
	sponsor_contract_target = target
	sponsor_contract_progress = 0
	sponsor_contract_reward = reward
	last_sponsor_message = "SPONSOR CONTRACT ACCEPTED: " + sponsor
	_save_career()
	_show_sponsor_contracts()

func _update_sponsor_contract(player_won: bool) -> void:
	last_sponsor_message = ""
	if sponsor_contract_name == "" or not player_won:
		return
	sponsor_contract_progress += 1
	if sponsor_contract_progress >= sponsor_contract_target:
		var completed_name := sponsor_contract_name
		var earned_reward := sponsor_contract_reward
		career_cash += earned_reward
		sponsor_contract_name = ""
		sponsor_contract_target = 0
		sponsor_contract_progress = 0
		sponsor_contract_reward = 0
		last_sponsor_message = "SPONSOR CONTRACT COMPLETE: %s  |  BONUS $%s" % [completed_name, str(earned_reward)]
	else:
		last_sponsor_message = "SPONSOR PROGRESS: %d / %d WINS" % [sponsor_contract_progress, sponsor_contract_target]

func _update_season_progress(player_won: bool) -> void:
	last_season_message = ""
	if season_events_completed.has(selected_event_id):
		last_season_message = "SEASON EVENT ALREADY COMPLETED — NO EXTRA POINTS"
		return
	season_events_completed.append(selected_event_id)
	var player_points := 10 if player_won else 3
	season_points["YOU"] = int(season_points.get("YOU", 0)) + player_points
	for name in rival_names:
		var rival_score := 10 if randf() < 0.55 else 3
		season_points[name] = int(season_points.get(name, 0)) + rival_score
	last_season_message = "SEASON POINTS  |  +%d" % player_points
	if season_events_completed.size() >= _event_catalog().size():
		var rows: Array = []
		for driver in ["YOU"] + rival_names:
			rows.append({"name": driver, "points": int(season_points.get(driver, 0))})
		rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
		var champion := str(rows[0]["name"])
		last_season_points = season_points.duplicate(true)
		last_season_number = season_number
		last_season_champion = champion
		if champion == "YOU":
			career_cash += 2500
			career_reputation += 25
			last_season_message = "SEASON %d CHAMPION! BONUS: $2,500 + 25 REP" % season_number
		else:
			last_season_message = "SEASON %d CHAMPION: %s" % [season_number, champion]
		season_number += 1
		season_points = {}
		season_events_completed = []

func _show_season_standings() -> void:
	var display_points: Dictionary = season_points
	var display_number := season_number
	var heading := "CURRENT SEASON"
	if season_events_completed.is_empty() and last_season_number > 0:
		display_points = last_season_points
		display_number = last_season_number
		heading = "LAST COMPLETED SEASON  |  CHAMPION: " + last_season_champion
	var rows: Array = [{"name": "YOU", "points": int(display_points.get("YOU", 0))}]
	for name in rival_names:
		rows.append({"name": name, "points": int(display_points.get(name, 0))})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := "%s\nSEASON %d\n\n" % [heading, display_number]
	for index in range(rows.size()):
		body += "%d. %s — %d points\n" % [index + 1, str(rows[index]["name"]), int(rows[index]["points"])]
	body += "\nCurrent season events completed: %d / %d" % [season_events_completed.size(), _event_catalog().size()]
	_show_subpage("SEASON STANDINGS", body, "BACK TO CAREER")

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
	status_label.text = "CAREER RECORDS AND DRIVER STATISTICS"
	_clear_section()
	section_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var content_scroll := ScrollContainer.new()
	content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.custom_minimum_size = Vector2(0, 220)
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	section_panel.add_child(content_scroll)
	var content_label := Label.new()
	content_label.text = body
	content_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	content_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	content_label.add_theme_font_size_override("font_size", 14)
	content_label.add_theme_color_override("font_color", Color("#dce5ef"))
	content_label.add_theme_constant_override("line_spacing", 5)
	content_scroll.add_child(content_label)
	var back_button := _make_button(back_caption, Color("#f5a623"))
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _show_story_missions() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "STORY & MISSIONS"
	status_label.text = "JASPER'S CONNECTIONS  •  YOUR CAREER STARTS HERE"
	_clear_section()
	if story_stage == 0:
		_add_section_label("CHAPTER 1  |  A FRESH START")
		_add_section_label("Your old life has fallen apart. You lost your job, your marriage ended, and the court has ordered you to pay monthly child support. You need a way to rebuild.")
		_add_section_label("Jasper, an old friend, calls with a way in. He knows the underground racing scene and can get you small jobs, but he expects you to prove yourself.")
		var begin_button := _make_button("CALL JASPER", Color("#f5a623"))
		begin_button.pressed.connect(func():
			story_stage = 1
			last_story_message = "Jasper: I can get you started. Win your first career race and show them you belong."
			_save_career()
			_show_story_missions()
		)
		section_panel.add_child(begin_button)
	else:
		_add_section_label("CHAPTER 1  |  A FRESH START")
		if story_stage == 1:
			_add_section_label("MISSION 1  |  PROVE YOURSELF")
			_add_section_label("Jasper: I can get you started. Win your first career race and show them you belong.")
			_add_section_label("OBJECTIVE  |  Win 1 Career race")
		elif story_stage == 2:
			_add_section_label("MISSION 2  |  BUILD A NAME")
			_add_section_label("Jasper has noticed your first result. Now prove it wasn't a one-off. Keep winning and build your reputation.")
			_add_section_label("OBJECTIVE  |  Win 3 Career races in total")
		elif story_stage == 3:
			_add_section_label("MISSION 3  |  BIGGER OPPORTUNITIES")
			_add_section_label("Your name is starting to travel. Jasper has heard that a more serious racing organizer is watching. Reach 50 reputation and win 5 Career races.")
			_add_section_label("OBJECTIVE  |  5 Career wins and 50 reputation")
		else:
			_add_section_label("CHAPTER 1 COMPLETE")
			_add_section_label("You've earned your place in the underground scene. Jasper's network can now open the door to bigger opportunities. The next chapter will expand your story.")
		if last_story_message != "":
			_add_section_label(last_story_message)
		_add_section_label("CAREER WINS  |  %d / 5" % [career_wins])
		_add_section_label("REPUTATION  |  %d / 50" % career_reputation)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _update_story_progress() -> void:
	if story_stage == 1 and career_wins >= 1:
		story_stage = 2
		career_cash += 500
		career_reputation += 5
		last_story_message = "MISSION COMPLETE: Jasper pays you $500 and introduces you to more racers."
	elif story_stage == 2 and career_wins >= 3:
		story_stage = 3
		career_cash += 1200
		career_reputation += 10
		last_story_message = "MISSION COMPLETE: Jasper rewards you with $1,200. Your name is spreading."
	elif story_stage == 3 and career_wins >= 5 and career_reputation >= 50:
		story_stage = 4
		story_completed = true
		career_cash += 2500
		career_reputation += 20
		last_story_message = "CHAPTER 1 COMPLETE: You earned $2,500 and access to the next stage of your racing career."
	else:
		return
	_save_career()

func _jasper_job_catalog() -> Array:
	return [
		{"id": "parts_run", "name": "Spare Parts Run", "description": "Help Jasper move a set of racing parts. Complete 1 Career race.", "races": 1, "reward": 350},
		{"id": "garage_support", "name": "Garage Support", "description": "Earn Jasper's trust by completing 2 Career races.", "races": 2, "reward": 800},
		{"id": "night_network", "name": "Night Network", "description": "Work three race nights and build Jasper's contacts.", "races": 3, "reward": 1500}
	]

func _show_jasper_jobs() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "JASPER'S GIGS"
	status_label.text = "SIDE WORK  •  EARN EXTRA CASH"
	_clear_section()
	_add_section_label("Jasper has small jobs that fit around your racing career. Accept one job at a time. Each completed Career race counts toward its objective.")
	if story_stage == 0:
		_add_section_label("CALL JASPER in STORY & MISSIONS to unlock his jobs.")
	else:
		if active_jasper_job != "":
			var active_job: Dictionary = {}
			for job in _jasper_job_catalog():
				if str(job["id"]) == active_jasper_job:
					active_job = job
					break
			if not active_job.is_empty():
				_add_section_label("ACTIVE JOB  |  " + str(active_job["name"]))
				_add_section_label("PROGRESS  |  %d / %d Career races" % [jasper_job_progress, int(active_job["races"])])
				_add_section_label("REWARD  |  $%s" % str(active_job["reward"]))
		else:
			_add_section_label("NO ACTIVE JOB")
			for job in _jasper_job_catalog():
				var job_id := str(job["id"])
				if completed_jasper_jobs.has(job_id):
					_add_section_label("COMPLETED  |  " + str(job["name"]))
					continue
				_add_section_label(str(job["name"]) + "  •  $" + str(job["reward"]))
				_add_section_label(str(job["description"]))
				var accept_button := _make_button("ACCEPT  |  " + str(job["name"]), Color("#25a9a1"))
				accept_button.pressed.connect(_accept_jasper_job.bind(job_id))
				section_panel.add_child(accept_button)
	if last_jasper_job_message != "":
		_add_section_label(last_jasper_job_message)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _accept_jasper_job(job_id: String) -> void:
	if active_jasper_job != "" or completed_jasper_jobs.has(job_id):
		return
	for job in _jasper_job_catalog():
		if str(job["id"]) == job_id:
			active_jasper_job = job_id
			jasper_job_progress = 0
			last_jasper_job_message = "Jasper: Good. Get it done and I'll pay you when the job is complete."
			_save_career()
			_show_jasper_jobs()
			return

func _update_jasper_job_progress() -> void:
	if active_jasper_job == "":
		return
	for job in _jasper_job_catalog():
		if str(job["id"]) != active_jasper_job:
			continue
		jasper_job_progress += 1
		var target := int(job["races"])
		if jasper_job_progress >= target:
			var job_name := str(job["name"])
			var reward := int(job["reward"])
			career_cash += reward
			completed_jasper_jobs.append(active_jasper_job)
			active_jasper_job = ""
			jasper_job_progress = 0
			last_jasper_job_message = "JASPER'S GIG COMPLETE: %s — $%s paid." % [job_name, str(reward)]
		else:
			last_jasper_job_message = "Jasper's gig progress: %d / %d Career races." % [jasper_job_progress, target]
		_save_career()
		return

func _advance_career_month() -> void:
	races_this_month += 1
	if races_this_month < 4:
		return
	races_this_month = 0
	career_month += 1
	var late_support_fee := int(ceil(child_support_due * 0.10))
	var late_household_fee := int(ceil(household_expenses_due * 0.05))
	if child_support_due > 0 or household_expenses_due > 0:
		missed_payment_months += 1
		child_support_due += late_support_fee
		household_expenses_due += late_household_fee
		last_finance_message = "PAYMENT OVERDUE: Late fees added — $%d child support, $%d household." % [late_support_fee, late_household_fee]
	else:
		last_finance_message = "A new in-game month has started. Your monthly bills are now due."
	child_support_due += 450
	household_expenses_due += 300
	_save_career()

func _show_finances() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "PERSONAL FINANCES"
	status_label.text = "MONTH %d  •  CASH $%s" % [career_month, str(career_cash)]
	_clear_section()
	_add_section_label("MONTHLY RESPONSIBILITIES")
	_add_section_label("CHILD SUPPORT  |  $450 per month")
	_add_section_label("Outstanding: $%s" % str(child_support_due))
	_add_section_label("HOUSEHOLD EXPENSES  |  $300 per month")
	_add_section_label("Outstanding: $%s" % str(household_expenses_due))
	_add_section_label("PAYMENT DEADLINE  |  End of each 4 Career races")
	_add_section_label("MONTHLY PROGRESS  |  %d / 4 Career races" % races_this_month)
	_add_section_label("MISSED PAYMENT MONTHS  |  %d" % missed_payment_months)
	_add_section_label("LATE FEES: 10%% on unpaid child support and 5%% on unpaid household bills at the next monthly deadline.")
	_add_section_label("TOTAL PAID  |  Child support $%s  •  Household $%s" % [str(child_support_paid_total), str(household_paid_total)])
	if last_finance_message != "":
		_add_section_label(last_finance_message)
	var support_button := _make_button("PAY CHILD SUPPORT  |  $%s" % str(child_support_due), Color("#25a9a1"))
	support_button.disabled = child_support_due <= 0 or career_cash <= 0
	support_button.pressed.connect(_pay_child_support)
	section_panel.add_child(support_button)
	var household_button := _make_button("PAY HOUSEHOLD BILLS  |  $%s" % str(household_expenses_due), Color("#2675a8"))
	household_button.add_theme_color_override("font_color", Color.WHITE)
	household_button.disabled = household_expenses_due <= 0 or career_cash <= 0
	household_button.pressed.connect(_pay_household_expenses)
	section_panel.add_child(household_button)
	var all_button := _make_button("PAY ALL AFFORDABLE BILLS", Color("#f5a623"))
	all_button.pressed.connect(_pay_all_bills)
	section_panel.add_child(all_button)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _pay_child_support() -> void:
	var payment := mini(career_cash, child_support_due)
	if payment <= 0:
		return
	career_cash -= payment
	child_support_due -= payment
	child_support_paid_total += payment
	last_finance_message = "Child support payment made: $%s." % str(payment)
	_save_career()
	_show_finances()

func _pay_household_expenses() -> void:
	var payment := mini(career_cash, household_expenses_due)
	if payment <= 0:
		return
	career_cash -= payment
	household_expenses_due -= payment
	household_paid_total += payment
	last_finance_message = "Household payment made: $%s." % str(payment)
	_save_career()
	_show_finances()

func _pay_all_bills() -> void:
	var support_payment := mini(career_cash, child_support_due)
	career_cash -= support_payment
	child_support_due -= support_payment
	child_support_paid_total += support_payment
	var household_payment := mini(career_cash, household_expenses_due)
	career_cash -= household_payment
	household_expenses_due -= household_payment
	household_paid_total += household_payment
	last_finance_message = "Payments made: $%s child support and $%s household." % [str(support_payment), str(household_payment)]
	_save_career()
	_show_finances()

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

func _roll_track_condition() -> void:
	var roll := randi_range(1, 100)
	var base_grip := 1.0
	if roll <= 20:
		race_track_condition = "PREPPED ASPHALT"
		base_grip = 1.08
	elif roll <= 65:
		race_track_condition = "DRY ASPHALT"
		base_grip = 1.0
	elif roll <= 85:
		race_track_condition = "DAMP TRACK"
		base_grip = 0.90
	else:
		race_track_condition = "WET TRACK"
		base_grip = 0.78
	var upgrades: Dictionary = car_upgrades.get(active_car, {})
	var tyre_level := int(upgrades.get("Tyres", 0))
	var tyre_protection := float(tyre_level) * 0.025
	player_grip_multiplier = base_grip
	if base_grip < 1.0:
		player_grip_multiplier = minf(1.0, base_grip + tyre_protection)
	rival_grip_multiplier = base_grip


func _start_race() -> void:
	last_jasper_job_message = ""
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
	race_top_speed = 0.0
	var active_upgrades: Dictionary = car_upgrades.get(active_car, {})
	var nitro_level := int(active_upgrades.get("Nitro", 0))
	nitro_capacity = 100.0 + float(nitro_level) * 25.0
	nitro_remaining = nitro_capacity
	nitro_used = 0.0
	nitro_down = false
	nitro_active = false
	_roll_track_condition()
	throttle_down = false
	if career_race:
		rival_name = str(rival_names[(career_wins + career_losses) % rival_names.size()])
		var selected_record: Dictionary = rival_records.get(rival_name, {})
		var rival_car := str(selected_record.get("car", "Street Compact"))
		var rival_upgrades := int(selected_record.get("upgrade_level", 0))
		var rival_rating := int(selected_record.get("rating", 50))
		var car_speed_bonus := 0.0
		var car_acceleration_bonus := 0.0
		if rival_car == "Turbo Coupe":
			car_speed_bonus = 6.0
			car_acceleration_bonus = 1.2
		elif rival_car == "Muscle V8":
			car_speed_bonus = 12.0
			car_acceleration_bonus = 2.4
		rival_target_speed = float(_get_selected_event()["rival_speed"]) + float(rival_rating - 50) * 0.22 + float(rival_upgrades) * 0.8 + car_speed_bonus
		rival_acceleration = 19.0 + float(rival_upgrades) * 0.35 + car_acceleration_bonus + float(rival_rating - 50) * 0.025
	else:
		rival_name = quick_rival_name if quick_rival_name != "" else rival_names[randi_range(0, rival_names.size() - 1)]
		rival_target_speed = 238.0
		rival_acceleration = 19.0
	title_label.text = "GET READY"
	status_label.text = "Hold ACCELERATE now. Launch when the countdown says GO!"
	_clear_section()
	_add_section_label("TRACK CONDITION  |  " + race_track_condition)
	_add_section_label("HOLD ACCELERATE TO PREPARE YOUR LAUNCH")
	var countdown_label := _large_label("3")
	countdown_label.add_theme_font_size_override("font_size", 76)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_panel.add_child(countdown_label)
	if is_instance_valid(throttle_button):
		throttle_button.text = "HOLD TO LAUNCH!"
	race_panel.show()
	for count in [3, 2, 1]:
		countdown_label.text = str(count)
		await get_tree().create_timer(0.85).timeout
	countdown_label.text = "GO!"
	countdown_label.add_theme_color_override("font_color", Color("#f5a623"))
	title_label.text = "MAKE YOUR MOVE"
	await get_tree().create_timer(0.45).timeout
	section_panel.hide()
	if is_instance_valid(throttle_button):
		throttle_button.text = "HOLD TO ACCELERATE"
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
	if is_instance_valid(nitro_bar):
		nitro_bar.max_value = nitro_capacity
		nitro_bar.value = nitro_remaining
	if is_instance_valid(nitro_button):
		nitro_button.text = "NITRO  |  %d%%" % int(nitro_remaining / maxf(1.0, nitro_capacity) * 100.0)
		nitro_button.disabled = nitro_remaining <= 0.0

func _finish_race() -> void:
	race_active = false
	throttle_down = false
	nitro_down = false
	nitro_active = false
	var was_career_race := career_race
	var won := player_distance >= race_distance and player_distance >= rival_distance
	var record_key := selected_event_id if career_race else "quick_402"
	var previous_best := float(personal_bests.get(record_key, 0.0))
	var new_personal_best := previous_best <= 0.0 or race_time < previous_best
	if new_personal_best:
		personal_bests[record_key] = race_time
	var previous_top_speed := float(personal_top_speeds.get(record_key, 0.0))
	last_top_speed_record = race_top_speed > previous_top_speed
	if last_top_speed_record:
		personal_top_speeds[record_key] = race_top_speed
	var race_prize := race_reward if was_career_race and won else 0
	var condition_before := clampf(float(car_condition.get(active_car, 100.0)), 0.0, 100.0)
	var condition_after := maxf(0.0, condition_before - race_distance / 1000.0)
	last_condition_loss = condition_before - condition_after
	car_condition[active_car] = condition_after
	var fuel_before := clampf(float(car_fuel.get(active_car, 100.0)), 0.0, 100.0)
	var fuel_consumption := race_distance / 402.0 * 1.5 + nitro_used * 0.03
	last_fuel_used = minf(fuel_before, fuel_consumption)
	var fuel_after := maxf(0.0, fuel_before - last_fuel_used)
	car_fuel[active_car] = fuel_after
	_apply_active_car()
	race_history.push_front({
		"event": race_event_name,
		"opponent": rival_name,
		"result": "WIN" if won else "LOSS",
		"time": race_time,
		"top_speed": race_top_speed,
		"nitro_used": nitro_used,
		"condition": race_track_condition,
		"car_condition": condition_after,
		"fuel_remaining": fuel_after,
		"fuel_used": last_fuel_used,
		"distance": int(race_distance),
		"prize": race_prize,
		"mode": "Career" if was_career_race else "Quick Race",
		"season": season_number if was_career_race else 0,
		"date": Time.get_datetime_string_from_system()
	})
	while race_history.size() > 30:
		race_history.pop_back()
	race_finished = true
	last_xp_earned = 0
	last_level_up = false
	if was_career_race:
		var old_level := _driver_level()
		last_xp_earned = 100 if won else 50
		career_xp += last_xp_earned
		last_level_up = _driver_level() > old_level
		_update_rival_career_results(won)
		_update_season_progress(won)
		_update_sponsor_contract(won)
		if won:
			career_wins += 1
			current_win_streak += 1
			best_win_streak = maxi(best_win_streak, current_win_streak)
			career_cash += race_reward
			career_reputation += 10
			last_result = "Victory vs " + rival_name
			_update_story_progress()
		else:
			career_losses += 1
			current_win_streak = 0
			last_result = "Defeat vs " + rival_name
		_update_jasper_job_progress()
		_advance_career_month()
		career_race = false
		_check_achievements(new_personal_best)
		_save_career()
	else:
		_save_career()
	_show_race_results(was_career_race, won, new_personal_best)

func _show_race_results(was_career_race: bool, won: bool, new_personal_best: bool) -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "RACE WON!" if won else "RACE LOST"
	status_label.text = "You beat %s." % rival_name if won else "%s reached the finish first." % rival_name
	_clear_section()
	_add_section_label("RACE RESULTS  |  " + race_event_name.to_upper())
	_add_section_label("OPPONENT  |  " + rival_name)
	_add_section_label("YOUR TIME  |  %.2f seconds" % race_time)
	_add_section_label("TOP SPEED  |  %d km/h%s" % [int(race_top_speed), "  •  NEW RECORD!" if last_top_speed_record else ""])
	_add_section_label("NITRO USED  |  %d%%" % int(nitro_used / maxf(1.0, nitro_capacity) * 100.0))
	_add_section_label("TRACK CONDITION  |  " + race_track_condition)
	_add_section_label("CAR CONDITION  |  %.1f%%  ( -%.2f%% wear )" % [float(car_condition.get(active_car, 100.0)), last_condition_loss])
	_add_section_label("FUEL REMAINING  |  %.1f%%  ( -%.2f%% used )" % [float(car_fuel.get(active_car, 100.0)), last_fuel_used])
	_add_section_label("DISTANCE  |  %d metres" % int(race_distance))
	_add_section_label("PRIZE MONEY  |  $%s" % str(race_reward if was_career_race and won else 0))
	if was_career_race and last_story_message != "":
		_add_section_label(last_story_message)
	if was_career_race and last_jasper_job_message != "":
		_add_section_label(last_jasper_job_message)
	if was_career_race:
		if last_season_message != "":
			_add_section_label(last_season_message)
		if last_sponsor_message != "":
			_add_section_label(last_sponsor_message)
		if last_achievement_message != "":
			_add_section_label(last_achievement_message)
		_add_section_label("DRIVER XP  |  +%d" % last_xp_earned)
		_add_section_label("DRIVER LEVEL  |  %d" % _driver_level())
		if last_level_up:
			_add_section_label("LEVEL UP!  NEW DRIVER LEVEL %d" % _driver_level())
	if new_personal_best:
		_add_section_label("NEW PERSONAL BEST!")
	else:
		var best := float(personal_bests.get(selected_event_id if was_career_race else "quick_402", 0.0))
		_add_section_label("PERSONAL BEST  |  %.2f seconds" % best if best > 0.0 else "PERSONAL BEST  |  No record yet")
	if was_career_race:
		var continue_button := _make_button("BACK TO CAREER", Color("#f5a623"))
		continue_button.pressed.connect(_show_career_dashboard)
		section_panel.add_child(continue_button)
		var again_button := _make_button("RACE THIS EVENT AGAIN", Color("#2675a8"))
		again_button.add_theme_color_override("font_color", Color.WHITE)
		again_button.pressed.connect(func():
			career_race = true
			_start_race()
		)
		section_panel.add_child(again_button)
	else:
		var continue_button := _make_button("QUICK RACE", Color("#38a8e8"))
		continue_button.pressed.connect(_show_quick_matchmaking)
		section_panel.add_child(continue_button)
		var menu_button := _make_button("MAIN MENU", Color("#263545"))
		menu_button.add_theme_color_override("font_color", Color.WHITE)
		menu_button.pressed.connect(_show_menu)
		section_panel.add_child(menu_button)

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


func _driver_level() -> int:
	return 1 + int(floor(float(career_xp) / 250.0))

func _load_career_save() -> void:
	var save := ConfigFile.new()
	var error := save.load("user://career_save.cfg")
	if error != OK:
		return
	career_wins = int(save.get_value("career", "wins", 0))
	career_losses = int(save.get_value("career", "losses", 0))
	career_cash = int(save.get_value("career", "cash", 0))
	career_reputation = int(save.get_value("career", "reputation", 0))
	career_xp = int(save.get_value("career", "xp", 0))
	season_number = int(save.get_value("career", "season_number", 1))
	season_points = save.get_value("career", "season_points", {})
	season_events_completed = save.get_value("career", "season_events_completed", [])
	last_season_points = save.get_value("career", "last_season_points", {})
	last_season_number = int(save.get_value("career", "last_season_number", 0))
	last_season_champion = str(save.get_value("career", "last_season_champion", ""))
	sponsor_contract_name = str(save.get_value("career", "sponsor_contract_name", ""))
	sponsor_contract_target = int(save.get_value("career", "sponsor_contract_target", 0))
	sponsor_contract_progress = int(save.get_value("career", "sponsor_contract_progress", 0))
	sponsor_contract_reward = int(save.get_value("career", "sponsor_contract_reward", 0))
	achievements = save.get_value("career", "achievements", {})
	rival_records = save.get_value("career", "rival_records", {})
	personal_bests = save.get_value("career", "personal_bests", {})
	personal_top_speeds = save.get_value("career", "personal_top_speeds", {})
	race_history = save.get_value("career", "race_history", [])
	current_win_streak = int(save.get_value("career", "current_win_streak", 0))
	best_win_streak = int(save.get_value("career", "best_win_streak", 0))
	selected_event_id = str(save.get_value("career", "selected_event_id", "quarter_mile"))
	race_event_name = str(_get_selected_event()["name"])
	last_result = str(save.get_value("career", "last_result", "No races completed"))
	story_stage = int(save.get_value("career", "story_stage", 0))
	active_jasper_job = str(save.get_value("career", "active_jasper_job", ""))
	jasper_job_progress = int(save.get_value("career", "jasper_job_progress", 0))
	completed_jasper_jobs = save.get_value("career", "completed_jasper_jobs", [])
	last_jasper_job_message = str(save.get_value("career", "last_jasper_job_message", ""))
	career_month = int(save.get_value("career", "career_month", 1))
	races_this_month = int(save.get_value("career", "races_this_month", 0))
	child_support_due = int(save.get_value("career", "child_support_due", 0))
	household_expenses_due = int(save.get_value("career", "household_expenses_due", 0))
	child_support_paid_total = int(save.get_value("career", "child_support_paid_total", 0))
	household_paid_total = int(save.get_value("career", "household_paid_total", 0))
	missed_payment_months = int(save.get_value("career", "missed_payment_months", 0))
	last_finance_message = str(save.get_value("career", "last_finance_message", ""))
	story_completed = bool(save.get_value("career", "story_completed", false))
	last_story_message = str(save.get_value("career", "last_story_message", ""))
	owned_cars = save.get_value("garage", "owned_cars", ["Street Compact"])
	active_car = str(save.get_value("garage", "active_car", "Street Compact"))
	car_upgrades = save.get_value("garage", "car_upgrades", {})
	car_condition = save.get_value("garage", "car_condition", {})
	car_fuel = save.get_value("garage", "car_fuel", {})
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
	save.set_value("career", "xp", career_xp)
	save.set_value("career", "season_number", season_number)
	save.set_value("career", "season_points", season_points)
	save.set_value("career", "season_events_completed", season_events_completed)
	save.set_value("career", "last_season_points", last_season_points)
	save.set_value("career", "last_season_number", last_season_number)
	save.set_value("career", "last_season_champion", last_season_champion)
	save.set_value("career", "sponsor_contract_name", sponsor_contract_name)
	save.set_value("career", "sponsor_contract_target", sponsor_contract_target)
	save.set_value("career", "sponsor_contract_progress", sponsor_contract_progress)
	save.set_value("career", "sponsor_contract_reward", sponsor_contract_reward)
	save.set_value("career", "achievements", achievements)
	save.set_value("career", "rival_records", rival_records)
	save.set_value("career", "personal_bests", personal_bests)
	save.set_value("career", "personal_top_speeds", personal_top_speeds)
	save.set_value("career", "race_history", race_history)
	save.set_value("career", "current_win_streak", current_win_streak)
	save.set_value("career", "best_win_streak", best_win_streak)
	save.set_value("career", "selected_event_id", selected_event_id)
	save.set_value("career", "last_result", last_result)
	save.set_value("career", "story_stage", story_stage)
	save.set_value("career", "active_jasper_job", active_jasper_job)
	save.set_value("career", "jasper_job_progress", jasper_job_progress)
	save.set_value("career", "completed_jasper_jobs", completed_jasper_jobs)
	save.set_value("career", "last_jasper_job_message", last_jasper_job_message)
	save.set_value("career", "career_month", career_month)
	save.set_value("career", "races_this_month", races_this_month)
	save.set_value("career", "child_support_due", child_support_due)
	save.set_value("career", "household_expenses_due", household_expenses_due)
	save.set_value("career", "child_support_paid_total", child_support_paid_total)
	save.set_value("career", "household_paid_total", household_paid_total)
	save.set_value("career", "missed_payment_months", missed_payment_months)
	save.set_value("career", "last_finance_message", last_finance_message)
	save.set_value("career", "story_completed", story_completed)
	save.set_value("career", "last_story_message", last_story_message)
	save.set_value("garage", "owned_cars", owned_cars)
	save.set_value("garage", "active_car", active_car)
	save.set_value("garage", "car_upgrades", car_upgrades)
	save.set_value("garage", "car_condition", car_condition)
	save.set_value("garage", "car_fuel", car_fuel)
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
