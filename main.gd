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
var last_race_record_key := "quarter_mile"

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
var story_race_active := false
var professional_license := false
var pro_championship_points := 0
var professional_season_number := 1
var professional_season_points: Dictionary = {}
var professional_events_completed: Array = []
var last_professional_points: Dictionary = {}
var last_professional_champion := ""
var last_professional_season_number := 0
var professional_season_message := ""
var professional_circuit_active := false
var selected_professional_event_id := "pro_402"
var professional_rival_names := ["Elena Cross", "Viktor Kane", "Nadia Stone", "Marcus Vale"]
var professional_rival_records: Dictionary = {}
var professional_team_points: Dictionary = {}
var last_professional_team_points: Dictionary = {}
var national_pathway_unlocked := false
var national_championship_active := false
var selected_national_event_id := "nat_402"
var national_season_number := 1
var national_season_points: Dictionary = {}
var national_events_completed: Array = []
var national_rival_names := ["Darius King", "Sofia Reyes", "Andre Mitchell", "Talia Brooks"]
var national_rival_records: Dictionary = {}
var national_team_points: Dictionary = {}
var last_national_points: Dictionary = {}
var last_national_team_points: Dictionary = {}
var last_national_champion := ""
var last_national_season_number := 0
var national_season_message := ""
var international_pathway_unlocked := false
var international_championship_active := false
var selected_international_event_id := "int_402"
var international_season_number := 1
var international_season_points: Dictionary = {}
var international_events_completed: Array = []
var international_rival_names := ["Luca Moretti", "Amara Okafor", "Diego Santos", "Hana Suzuki"]
var international_rival_records: Dictionary = {}
var international_team_points: Dictionary = {}
var last_international_points: Dictionary = {}
var last_international_team_points: Dictionary = {}
var last_international_champion := ""
var last_international_season_number := 0
var international_season_message := ""
var superstar_pathway_unlocked := false
var superstar_championship_active := false
var selected_superstar_event_id := "star_402"
var superstar_season_number := 1
var superstar_season_points: Dictionary = {}
var superstar_events_completed: Array = []
var superstar_rival_names := ["Rafael Cruz", "Zara Bennett", "Kenji Watanabe", "Malik Thompson", "Isabella Romano"]
var superstar_rival_records: Dictionary = {}
var last_superstar_points: Dictionary = {}
var last_superstar_champion := ""
var last_superstar_season_number := 0
var superstar_season_message := ""
var lifetime_earnings := 0
var superstar_titles := 0
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
var career_inbox: Array = []
var career_invites_sent: Array = []
var defeated_challenge_rivals: Array = []
var rival_challenge_active := false
var rival_challenge_name := ""
var last_career_notification := ""
var current_team := ""
var team_offers: Array = []
var team_invites_sent: Array = []
var team_contract_active := false
var team_contract_races_left := 0
var team_contract_races_completed := 0
var team_contract_wins := 0
var team_contract_win_target := 3
var team_contract_reward := 0
var last_team_message := ""
var last_team_race_message := ""
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
	_ensure_professional_rival_records()
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
	var achievements_menu_button := _make_button("ACHIEVEMENTS", Color("#34485d"))
	achievements_menu_button.add_theme_color_override("font_color", Color.WHITE)
	achievements_menu_button.pressed.connect(func(): _show_achievements(true))
	menu_panel.add_child(achievements_menu_button)
	var reset_menu_button := _make_button("RESET CAREER", Color("#8f3e3e"))
	reset_menu_button.add_theme_color_override("font_color", Color.WHITE)
	reset_menu_button.pressed.connect(_show_reset_career_confirmation)
	menu_panel.add_child(reset_menu_button)
	var settings_button := _make_button("SETTINGS", Color("#34485d"))
	settings_button.add_theme_color_override("font_color", Color.WHITE)
	settings_button.pressed.connect(func(): _show_info_page("SETTINGS", "Game settings will be added here."))
	menu_panel.add_child(settings_button)

	var section_scroll := ScrollContainer.new()
	section_scroll.name = "CareerContentScroll"
	section_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	section_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	root.add_child(section_scroll)
	section_panel = VBoxContainer.new()
	section_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	section_panel.add_theme_constant_override("separation", 10)
	section_scroll.add_child(section_panel)
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

func _show_reset_career_confirmation() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "RESET CAREER"
	status_label.text = "PERMANENT CAREER DATA RESET"
	_clear_section()
	_add_section_label("This will permanently erase your current career, including:")
	_add_section_label("• Race results, money, reputation and driver level")
	_add_section_label("• Cars, upgrades, records and achievements")
	_add_section_label("• Story progress, contracts and championship standings")
	_add_section_label("")
	_add_section_label("Quick Race and game settings are not part of the career save.")
	var confirm_button := _make_button("DELETE CAREER AND START OVER", Color("#a83d3d"))
	confirm_button.add_theme_color_override("font_color", Color.WHITE)
	confirm_button.pressed.connect(_reset_career_and_restart)
	section_panel.add_child(confirm_button)
	var cancel_button := _make_button("CANCEL  |  BACK TO MAIN MENU", Color("#34485d"))
	cancel_button.add_theme_color_override("font_color", Color.WHITE)
	cancel_button.pressed.connect(_show_menu)
	section_panel.add_child(cancel_button)

func _reset_career_and_restart() -> void:
	var save_path := ProjectSettings.globalize_path("user://career_save.cfg")
	if FileAccess.file_exists("user://career_save.cfg"):
		var error := DirAccess.remove_absolute(save_path)
		if error != OK:
			status_label.text = "RESET FAILED — SAVE FILE COULD NOT BE DELETED"
			_add_section_label("Your existing career has not been reset. Check available device storage and try again.")
			return
	get_tree().reload_current_scene()

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
	_refresh_team_offers()
	_add_section_label("DRIVER LEVEL  %d  •  XP %d / %d" % [_driver_level(), career_xp % 250, 250])
	_add_section_label("CAREER RECORD")
	_add_section_label("Wins: %d     Losses: %d" % [career_wins, career_losses])
	_add_section_label("Cash: $%s     Reputation: %d" % [str(career_cash), career_reputation])
	_add_section_label("LAST RESULT  |  " + last_result)
	_add_section_label("CAREER TIER  |  %s" % _career_tier_name())
	_add_section_label("NEXT UNLOCK  |  %s" % _next_career_tier_text())
	if professional_license:
		var pro_circuit_button := _make_button("PROFESSIONAL CIRCUIT", Color("#c17a28"))
		pro_circuit_button.pressed.connect(_show_professional_circuit)
		section_panel.add_child(pro_circuit_button)
		var pro_standings_button := _make_button("PROFESSIONAL STANDINGS", Color("#34485d"))
		pro_standings_button.add_theme_color_override("font_color", Color.WHITE)
		pro_standings_button.pressed.connect(_show_professional_standings)
		section_panel.add_child(pro_standings_button)
		var team_standings_button := _make_button("TEAM CHAMPIONSHIP", Color("#34485d"))
		team_standings_button.add_theme_color_override("font_color", Color.WHITE)
		team_standings_button.pressed.connect(_show_professional_team_standings)
		section_panel.add_child(team_standings_button)
	if international_pathway_unlocked:
		var international_button := _make_button("INTERNATIONAL CHAMPIONSHIP", Color("#c17a28"))
		international_button.pressed.connect(_show_international_championship)
		section_panel.add_child(international_button)
	if superstar_pathway_unlocked:
		var superstar_button := _make_button("SUPERSTAR CHAMPIONSHIP", Color("#d6a52d"))
		superstar_button.pressed.connect(_show_superstar_championship)
		section_panel.add_child(superstar_button)
		var hall_button := _make_button("GLOBAL HALL OF FAME", Color("#34485d"))
		hall_button.add_theme_color_override("font_color", Color.WHITE)
		hall_button.pressed.connect(_show_global_hall_of_fame)
		section_panel.add_child(hall_button)
	if national_pathway_unlocked:
		var national_button := _make_button("NATIONAL CHAMPIONSHIP", Color("#c17a28"))
		national_button.pressed.connect(_show_national_championship)
		section_panel.add_child(national_button)
		var national_standings_button := _make_button("NATIONAL STANDINGS", Color("#34485d"))
		national_standings_button.add_theme_color_override("font_color", Color.WHITE)
		national_standings_button.pressed.connect(_show_national_standings)
		section_panel.add_child(national_standings_button)
		var national_teams_button := _make_button("NATIONAL TEAM CHAMPIONSHIP", Color("#34485d"))
		national_teams_button.add_theme_color_override("font_color", Color.WHITE)
		national_teams_button.pressed.connect(_show_national_team_standings)
		section_panel.add_child(national_teams_button)
	var teams_button := _make_button("RACING TEAMS & CONTRACTS", Color("#2675a8"))
	teams_button.add_theme_color_override("font_color", Color.WHITE)
	teams_button.pressed.connect(_show_team_management)
	section_panel.add_child(teams_button)
	var inbox_button := _make_button("CAREER INBOX  |  %d NEW" % career_inbox.size(), Color("#2675a8"))
	inbox_button.add_theme_color_override("font_color", Color.WHITE)
	inbox_button.pressed.connect(_show_career_inbox)
	section_panel.add_child(inbox_button)
	var challenge_button := _make_button("RIVAL CHALLENGES", Color("#34485d"))
	challenge_button.add_theme_color_override("font_color", Color.WHITE)
	challenge_button.pressed.connect(_show_rival_challenges)
	section_panel.add_child(challenge_button)
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
	var repair_rate := 25.0 * (1.0 - _team_discount_rate())
	var repair_amount := minf(wear, float(career_cash) / maxf(1.0,repair_rate))
	var repair_cost := mini(career_cash, int(ceil(repair_amount * repair_rate)))
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
	var fuel_rate := 10.0 * (1.0 - _team_discount_rate())
	var refill_amount := minf(missing_fuel, float(career_cash) / maxf(1.0,fuel_rate))
	var refill_cost := mini(career_cash, int(ceil(refill_amount * fuel_rate)))
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
	if current_team != "":
		_add_section_label("TEAM DISCOUNT  |  %d%%" % int(_team_discount_rate()*100.0))
	var service_cost := int(ceil((100.0 - condition) * 25.0 * (1.0 - _team_discount_rate())))
	var service_button := _make_button("SERVICE CAR  |  $%s" % str(service_cost), Color("#25a9a1"))
	service_button.disabled = condition >= 99.9 or career_cash <= 0
	service_button.pressed.connect(_service_active_car)
	section_panel.add_child(service_button)
	var fuel := clampf(float(car_fuel.get(active_car, 100.0)), 0.0, 100.0)
	_add_section_label("FUEL LEVEL  |  %.1f%%" % fuel)
	_add_section_label("Low fuel reduces engine performance. Team discounts apply to refuelling.")
	var refuel_cost := int(ceil((100.0 - fuel) * 10.0 * (1.0 - _team_discount_rate())))
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
		var price := int(ceil(float(int(part["base_price"]) * (level + 1)) * (1.0 - _team_discount_rate())))
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
			var price := int(ceil(float(int(part["base_price"]) * (level + 1)) * (1.0 - _team_discount_rate())))
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

func _career_tier_name() -> String:
	if career_reputation >= 800:
		return "SUPERSTAR"
	if career_reputation >= 500:
		return "INTERNATIONAL"
	if career_reputation >= 300:
		return "NATIONAL"
	if career_reputation >= 150:
		return "PROFESSIONAL"
	if career_reputation >= 75:
		return "AMATEUR"
	if career_reputation >= 30:
		return "LOCAL CHAMPION"
	return "UNDERGROUND RACER"

func _next_career_tier_text() -> String:
	var thresholds := [30, 75, 150, 300, 500, 800]
	var names := ["LOCAL CHAMPION", "AMATEUR", "PROFESSIONAL", "NATIONAL", "INTERNATIONAL", "SUPERSTAR"]
	for index in range(thresholds.size()):
		if career_reputation < int(thresholds[index]):
			return "%s at %d reputation (%d to go)" % [names[index], int(thresholds[index]), int(thresholds[index]) - career_reputation]
	return "MAXIMUM TIER REACHED"

func _team_catalog() -> Array:
	return [
		{"name":"Street Kings","rep":30,"signing":500,"discount":5,"reward":1200,"description":"A local underground crew with affordable workshop access."},
		{"name":"Apex Performance","rep":75,"signing":1200,"discount":8,"reward":2200,"description":"An amateur outfit focused on consistent race wins."},
		{"name":"Velocity Motorsport","rep":150,"signing":2500,"discount":10,"reward":4000,"description":"A professional team with strong technical support."},
		{"name":"National Racing Union","rep":300,"signing":5000,"discount":12,"reward":6500,"description":"A national-level operation with major race ambitions."},
		{"name":"International Elite","rep":500,"signing":9000,"discount":15,"reward":10000,"description":"An international team with premium workshop benefits."},
		{"name":"Superstar Works","rep":800,"signing":15000,"discount":18,"reward":16000,"description":"An elite factory-backed team for the sport's biggest names."}
	]

func _team_discount_rate() -> float:
	for team in _team_catalog():
		if str(team["name"]) == current_team:
			return float(team["discount"]) / 100.0
	return 0.0

func _refresh_team_offers() -> void:
	for team in _team_catalog():
		var team_name := str(team["name"])
		if career_reputation >= int(team["rep"]) and team_name != current_team and not team_offers.has(team_name) and not team_invites_sent.has(team_name):
			team_offers.append(team_name)
			team_invites_sent.append(team_name)
			_add_career_notification("TEAM OFFER: %s wants to sign you. Review Racing Teams & Contracts." % team_name)

func _show_team_management() -> void:
	_refresh_team_offers()
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "RACING TEAMS"
	status_label.text = "Team relationships, contracts and driver benefits."
	_clear_section()
	if current_team != "":
		var data: Dictionary = {}
		for team in _team_catalog():
			if str(team["name"]) == current_team:
				data = team
				break
		_add_section_label("CURRENT TEAM  |  " + current_team.to_upper())
		_add_section_label("BENEFIT  |  %d%% off upgrades, servicing and fuel" % int(data.get("discount",0)))
		if team_contract_active:
			_add_section_label("CONTRACT  |  %d / 6 races completed" % team_contract_races_completed)
			_add_section_label("OBJECTIVE  |  Win %d races; current wins: %d" % [team_contract_win_target,team_contract_wins])
			_add_section_label("RACES REMAINING  |  %d" % team_contract_races_left)
			_add_section_label("COMPLETION BONUS  |  $%s" % str(team_contract_reward))
		else:
			_add_section_label("CONTRACT EXPIRED  |  Renewal available")
		var renew := _make_button("RENEW 6-RACE CONTRACT",Color("#25a9a1"))
		renew.pressed.connect(_renew_team_contract)
		section_panel.add_child(renew)
		var leave := _make_button("LEAVE CURRENT TEAM",Color("#a84444"))
		leave.add_theme_color_override("font_color",Color.WHITE)
		leave.pressed.connect(_leave_team)
		section_panel.add_child(leave)
	else:
		_add_section_label("NO TEAM SIGNED — offers arrive as reputation grows.")
	if team_offers.is_empty():
		_add_section_label("No new team offers available.")
	for team_name in team_offers:
		for team in _team_catalog():
			if str(team["name"]) != str(team_name):
				continue
			_add_section_label("%s  |  %d reputation required" % [team_name,int(team["rep"])])
			_add_section_label(str(team["description"]))
			_add_section_label("Signing bonus $%s  •  %d%% discount" % [str(team["signing"]),int(team["discount"])])
			var join := _make_button("SIGN WITH "+str(team_name).to_upper(),Color("#f5a623"))
			join.pressed.connect(_join_team.bind(str(team_name)))
			section_panel.add_child(join)
	var back := _make_button("BACK TO CAREER",Color("#263545"))
	back.add_theme_color_override("font_color",Color.WHITE)
	back.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back)

func _join_team(team_name: String) -> void:
	if not team_offers.has(team_name):
		return
	for team in _team_catalog():
		if str(team["name"]) != team_name or career_reputation < int(team["rep"]):
			continue
		current_team = team_name
		career_cash += int(team["signing"])
		team_offers.erase(team_name)
		team_contract_active = true
		team_contract_races_left = 6
		team_contract_races_completed = 0
		team_contract_wins = 0
		team_contract_win_target = 3
		team_contract_reward = int(team["reward"])
		last_team_message = "SIGNED: %s. $%s signing bonus received. Win 3 of your next 6 Career races for a $%s bonus." % [team_name,str(team["signing"]),str(team_contract_reward)]
		_add_career_notification(last_team_message)
		_save_career()
		_show_team_management()
		return

func _renew_team_contract() -> void:
	if current_team == "" or team_contract_active:
		return
	for team in _team_catalog():
		if str(team["name"]) == current_team:
			team_contract_active = true
			team_contract_races_left = 6
			team_contract_races_completed = 0
			team_contract_wins = 0
			team_contract_win_target = 3
			team_contract_reward = int(team["reward"])
			last_team_message = "CONTRACT RENEWED: %s. Win 3 of your next 6 Career races." % current_team
			_add_career_notification(last_team_message)
			_save_career()
			_show_team_management()
			return

func _leave_team() -> void:
	if current_team == "":
		return
	var old_team := current_team
	current_team = ""
	team_contract_active = false
	team_contract_races_left = 0
	team_contract_races_completed = 0
	team_contract_wins = 0
	team_contract_reward = 0
	last_team_message = "You left %s. Team discounts and contract access have ended." % old_team
	_add_career_notification(last_team_message)
	_refresh_team_offers()
	_save_career()
	_show_team_management()

func _update_team_contract(won: bool) -> void:
	last_team_race_message = ""
	if current_team == "" or not team_contract_active:
		return
	team_contract_races_completed += 1
	team_contract_races_left = maxi(0,team_contract_races_left-1)
	if won:
		team_contract_wins += 1
	if team_contract_wins >= team_contract_win_target:
		career_cash += team_contract_reward
		last_team_race_message = "TEAM CONTRACT COMPLETED: %s — $%s bonus paid." % [current_team,str(team_contract_reward)]
		_add_career_notification(last_team_race_message)
		team_contract_active = false
	elif team_contract_races_left <= 0:
		last_team_race_message = "TEAM CONTRACT EXPIRED: %s — %d/%d wins. You can renew." % [current_team,team_contract_wins,team_contract_win_target]
		_add_career_notification(last_team_race_message)
		team_contract_active = false
	else:
		last_team_race_message = "TEAM CONTRACT: %s — %d/%d wins, %d races remaining." % [current_team,team_contract_wins,team_contract_win_target,team_contract_races_left]

func _event_min_reputation(event_id: String) -> int:
	match event_id:
		"eighth_mile", "quarter_mile":
			return 0
		"pro_quarter":
			return 50
		"half_mile":
			return 100
		"top_speed":
			return 200
		"mile_run":
			return 350
	return 0

func _event_entry_fee(event_id: String) -> int:
	match event_id:
		"eighth_mile", "quarter_mile":
			return 0
		"pro_quarter":
			return 100
		"half_mile":
			return 200
		"top_speed":
			return 350
		"mile_run":
			return 500
	return 0

func _add_career_notification(message: String) -> void:
	career_inbox.push_front({"message": message, "date": Time.get_datetime_string_from_system()})
	while career_inbox.size() > 30:
		career_inbox.pop_back()
	last_career_notification = message
	_save_career()

func _check_career_tier_unlocks() -> void:
	var tiers := [
		{"rep": 30, "name": "LOCAL CHAMPION"},
		{"rep": 75, "name": "AMATEUR"},
		{"rep": 150, "name": "PROFESSIONAL"},
		{"rep": 300, "name": "NATIONAL"},
		{"rep": 500, "name": "INTERNATIONAL"},
		{"rep": 800, "name": "SUPERSTAR"}
	]
	for tier in tiers:
		var threshold := int(tier["rep"])
		if career_reputation >= threshold and not career_invites_sent.has(threshold):
			career_invites_sent.append(threshold)
			_add_career_notification("CAREER UNLOCK: %s division invitation received." % str(tier["name"]))

func _show_career_inbox() -> void:
	var body := "CAREER INBOX\n\n"
	if career_inbox.is_empty():
		body += "No messages yet. Invitations and career updates will appear here."
	else:
		for index in range(career_inbox.size()):
			var item: Dictionary = career_inbox[index]
			body += "%d. %s\n%s\n\n" % [index + 1, str(item.get("message", "")), str(item.get("date", ""))]
	_show_subpage("CAREER INBOX", body, "BACK TO CAREER")

func _show_rival_challenges() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "RIVAL CHALLENGES"
	status_label.text = "Settle the score on the strip."
	_clear_section()
	_add_section_label("Challenge a rival over your selected event. A win pays a bonus and reputation. Each rival can be defeated for this challenge once.")
	_add_section_label("SELECTED EVENT  |  %s" % race_event_name)
	for name in rival_names:
		if defeated_challenge_rivals.has(name):
			_add_section_label("%s  |  CHALLENGE WON" % name)
			continue
		var challenge_button := _make_button("CHALLENGE  |  " + str(name), Color("#b34d43"))
		challenge_button.add_theme_color_override("font_color", Color.WHITE)
		challenge_button.pressed.connect(func():
			if career_reputation < _event_min_reputation(selected_event_id):
				_add_career_notification("Challenge unavailable: build more reputation to enter this event.")
				_show_rival_challenges()
				return
			if career_cash < _event_entry_fee(selected_event_id):
				_add_career_notification("Challenge unavailable: not enough cash for the event entry fee.")
				_show_rival_challenges()
				return
			rival_challenge_active = true
			rival_challenge_name = str(name)
			career_race = true
			_start_race()
		)
		section_panel.add_child(challenge_button)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _event_catalog() -> Array:
	return [
		{"id": "eighth_mile", "name": "Eighth-Mile Dash", "distance": 201.0, "reward": 300, "rival_speed": 232.0, "description": "A short explosive sprint. Launch reaction and acceleration decide the winner."},
		{"id": "quarter_mile", "name": "Quarter-Mile Sprint", "distance": 402.0, "reward": 500, "rival_speed": 238.0, "description": "Classic drag race. A balanced test of launch and shifting."},
		{"id": "pro_quarter", "name": "Pro Quarter-Mile", "distance": 402.0, "reward": 900, "rival_speed": 247.0, "description": "A tougher quarter-mile event with a stronger rival field."},
		{"id": "half_mile", "name": "Half-Mile Challenge", "distance": 804.0, "reward": 1200, "rival_speed": 250.0, "description": "Longer run. Top speed and clean gear changes matter."},
		{"id": "top_speed", "name": "Top Speed Shootout", "distance": 1000.0, "reward": 1600, "rival_speed": 255.0, "description": "A high-speed test against experienced drivers."},
		{"id": "mile_run", "name": "One-Mile Showdown", "distance": 1609.0, "reward": 2500, "rival_speed": 260.0, "description": "The ultimate endurance drag event. Hold speed and shift cleanly."}
	]

func _professional_event_catalog() -> Array:
	return [
		{"id":"pro_402","name":"National Pro Quarter-Mile","distance":402.0,"reward":2200,"rival_speed":260.0,"entry_fee":250,"points":10},
		{"id":"pro_804","name":"National Half-Mile Grand Prix","distance":804.0,"reward":3000,"rival_speed":265.0,"entry_fee":350,"points":10},
		{"id":"pro_1000","name":"National Top Speed Cup","distance":1000.0,"reward":4200,"rival_speed":270.0,"entry_fee":500,"points":12},
		{"id":"pro_1609","name":"National Mile Championship","distance":1609.0,"reward":5500,"rival_speed":275.0,"entry_fee":650,"points":12},
		{"id":"pro_201","name":"National Eighth-Mile Shootout","distance":201.0,"reward":2600,"rival_speed":268.0,"entry_fee":300,"points":10},
		{"id":"pro_final","name":"National Grand Final","distance":1609.0,"reward":9000,"rival_speed":282.0,"entry_fee":900,"points":15}
	]

func _get_professional_event() -> Dictionary:
	for event in _professional_event_catalog():
		if str(event["id"]) == selected_professional_event_id:
			return event
	return _professional_event_catalog()[0]

func _show_professional_circuit() -> void:
	if not professional_license:
		_show_story_missions()
		return
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "PROFESSIONAL CIRCUIT"
	status_label.text = "NATIONAL DRAG ASSOCIATION  |  SEASON %d" % professional_season_number
	_clear_section()
	_add_section_label("LICENSE ACTIVE  |  NATIONAL DRAG ASSOCIATION")
	_add_section_label("SEASON PROGRESS  |  %d / %d events completed" % [professional_events_completed.size(), _professional_event_catalog().size()])
	_add_section_label("YOUR TEAM  |  %s" % (current_team if current_team != "" else "INDEPENDENT"))
	for event in _professional_event_catalog():
		var event_id := str(event["id"])
		_add_section_label("%s  |  %d m  |  Prize $%s  |  Entry $%s" % [str(event["name"]), int(event["distance"]), str(event["reward"]), str(event["entry_fee"])])
		_add_section_label("CHAMPIONSHIP POINTS  |  %d" % int(event["points"]))
		var completed := professional_events_completed.has(event_id)
		var event_button := _make_button(("COMPLETED  |  " if completed else "ENTER  |  ") + str(event["name"]), Color("#34485d") if completed else Color("#f5a623"))
		event_button.disabled = completed
		if completed:
			event_button.add_theme_color_override("font_color", Color.WHITE)
		event_button.pressed.connect(_enter_professional_event.bind(event_id))
		section_panel.add_child(event_button)
	var standings_button := _make_button("VIEW PROFESSIONAL STANDINGS", Color("#2675a8"))
	standings_button.add_theme_color_override("font_color", Color.WHITE)
	standings_button.pressed.connect(_show_professional_standings)
	section_panel.add_child(standings_button)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _enter_professional_event(event_id: String) -> void:
	if not professional_license or professional_events_completed.has(event_id):
		return
	for event in _professional_event_catalog():
		if str(event["id"]) == event_id:
			selected_professional_event_id = event_id
			professional_circuit_active = true
			career_race = true
			_start_race()
			return

func _ensure_professional_rival_records() -> void:
	for index in range(professional_rival_names.size()):
		var name := str(professional_rival_names[index])
		if not professional_rival_records.has(name):
			professional_rival_records[name] = {"wins":0,"losses":0,"rating":68 + index * 5,"car":"Turbo Coupe" if index < 2 else "Muscle V8","upgrade_level":index + 2}

func _update_professional_rival_results(player_won: bool) -> void:
	if not professional_rival_records.has(rival_name):
		professional_rival_records[rival_name] = {"wins":0,"losses":0,"rating":68 + professional_rival_names.find(rival_name) * 5}
	var opponent: Dictionary = professional_rival_records[rival_name]
	if player_won:
		opponent["losses"] = int(opponent.get("losses", 0)) + 1
	else:
		opponent["wins"] = int(opponent.get("wins", 0)) + 1
		opponent["rating"] = mini(100, int(opponent.get("rating", 70)) + 1)
	professional_rival_records[rival_name] = opponent
	for name in professional_rival_names:
		if name == rival_name:
			continue
		if not professional_rival_records.has(name):
			professional_rival_records[name] = {"wins":0,"losses":0,"rating":68 + professional_rival_names.find(name) * 5}
		var record: Dictionary = professional_rival_records[name]
		if randf() < 0.58:
			record["wins"] = int(record.get("wins", 0)) + 1
		else:
			record["losses"] = int(record.get("losses", 0)) + 1
		professional_rival_records[name] = record

func _update_professional_season(player_won: bool) -> void:
	professional_season_message = ""
	if professional_events_completed.has(selected_professional_event_id):
		professional_season_message = "PRO SEASON EVENT ALREADY COMPLETED — NO EXTRA POINTS"
		return
	var event := _get_professional_event()
	professional_events_completed.append(selected_professional_event_id)
	var player_points := int(event["points"]) if player_won else 3
	professional_season_points["YOU"] = int(professional_season_points.get("YOU", 0)) + player_points
	professional_season_message = "PRO SEASON POINTS  |  +%d" % player_points
	for name in professional_rival_names:
		var rival_points := 10 if randf() < 0.58 else 3
		professional_season_points[name] = int(professional_season_points.get(name, 0)) + rival_points
	var team_name := current_team if current_team != "" else "Independent"
	professional_team_points[team_name] = int(professional_team_points.get(team_name, 0)) + player_points
	for name in professional_rival_names:
		var rival_team := "Apex Performance" if name == "Elena Cross" else ("Velocity Motorsport" if name == "Viktor Kane" else ("National Racing Union" if name == "Nadia Stone" else "International Elite"))
		var team_score := 10 if randf() < 0.58 else 3
		professional_team_points[rival_team] = int(professional_team_points.get(rival_team, 0)) + team_score
	if professional_events_completed.size() >= _professional_event_catalog().size():
		var rows: Array = []
		for driver in ["YOU"] + professional_rival_names:
			rows.append({"name":driver,"points":int(professional_season_points.get(driver,0))})
		rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
		last_professional_champion = str(rows[0]["name"])
		last_professional_points = professional_season_points.duplicate(true)
		last_professional_season_number = professional_season_number
		if last_professional_champion == "YOU":
			career_cash += 12000
			career_reputation += 50
			pro_championship_points += 1
			national_pathway_unlocked = true
			professional_season_message = "PRO SEASON %d CHAMPION! $12,000 + 50 REP. NATIONAL CHAMPIONSHIP PATHWAY UNLOCKED." % professional_season_number
			_add_career_notification("PROFESSIONAL CHAMPION: National Championship pathway unlocked.")
		else:
			professional_season_message = "PRO SEASON %d CHAMPION: %s. Keep competing for the title." % [professional_season_number, last_professional_champion]
		last_professional_team_points = professional_team_points.duplicate(true)
		professional_season_number += 1
		professional_season_points = {}
		professional_events_completed = []
		professional_team_points = {}
		_save_career()

func _national_event_catalog() -> Array:
	return [
		{"id":"nat_402","name":"National Quarter-Mile Championship","distance":402.0,"reward":5000,"rival_speed":286.0,"entry_fee":1200,"points":15},
		{"id":"nat_804","name":"National Half-Mile Grand Prix","distance":804.0,"reward":6500,"rival_speed":291.0,"entry_fee":1500,"points":15},
		{"id":"nat_1000","name":"National Top Speed Masters","distance":1000.0,"reward":8000,"rival_speed":296.0,"entry_fee":1800,"points":18},
		{"id":"nat_1609","name":"National Mile Endurance","distance":1609.0,"reward":10000,"rival_speed":300.0,"entry_fee":2200,"points":18},
		{"id":"nat_201","name":"National Eighth-Mile Sprint","distance":201.0,"reward":6000,"rival_speed":294.0,"entry_fee":1400,"points":15},
		{"id":"nat_final","name":"National Championship Final","distance":1609.0,"reward":18000,"rival_speed":308.0,"entry_fee":3000,"points":25}
	]

func _get_national_event() -> Dictionary:
	for event in _national_event_catalog():
		if str(event["id"]) == selected_national_event_id:
			return event
	return _national_event_catalog()[0]

func _ensure_national_rival_records() -> void:
	for index in range(national_rival_names.size()):
		var name := str(national_rival_names[index])
		if not national_rival_records.has(name):
			national_rival_records[name] = {"wins":0,"losses":0,"rating":82 + index * 3,"car":"Muscle V8","upgrade_level":5 + index}

func _begin_national_story() -> void:
	if not (national_pathway_unlocked and career_wins >= 25 and _driver_level() >= 10 and career_reputation >= 300):
		_show_national_pathway()
		return
	if story_stage < 15:
		story_stage = 15
		last_story_message = "National Drag Association: Your qualification is approved. The national title is now within reach."
	_save_career()
	_show_story_missions()

func _show_national_championship() -> void:
	var qualified := national_pathway_unlocked and career_wins >= 25 and _driver_level() >= 10 and career_reputation >= 300
	if not qualified:
		_show_national_pathway()
		return
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "NATIONAL CHAMPIONSHIP"
	status_label.text = "NATIONAL DRAG ASSOCIATION  |  SEASON %d" % national_season_number
	_clear_section()
	_add_section_label("NATIONAL LICENCE  |  ENTRY APPROVED")
	_add_section_label("SEASON PROGRESS  |  %d / %d events completed" % [national_events_completed.size(), _national_event_catalog().size()])
	_add_section_label("TEAM  |  %s" % (current_team if current_team != "" else "INDEPENDENT"))
	for event in _national_event_catalog():
		var event_id := str(event["id"])
		_add_section_label("%s  |  %d m  |  Prize $%s  |  Entry $%s  |  %d pts" % [str(event["name"]), int(event["distance"]), str(event["reward"]), str(event["entry_fee"]), int(event["points"])])
		var completed := national_events_completed.has(event_id)
		var event_button := _make_button(("COMPLETED  |  " if completed else "ENTER  |  ") + str(event["name"]), Color("#34485d") if completed else Color("#c17a28"))
		event_button.disabled = completed
		event_button.pressed.connect(_enter_national_event.bind(event_id))
		section_panel.add_child(event_button)
	var standings_button := _make_button("VIEW NATIONAL STANDINGS", Color("#2675a8"))
	standings_button.add_theme_color_override("font_color", Color.WHITE)
	standings_button.pressed.connect(_show_national_standings)
	section_panel.add_child(standings_button)
	var team_button := _make_button("VIEW TEAM CHAMPIONSHIP", Color("#34485d"))
	team_button.add_theme_color_override("font_color", Color.WHITE)
	team_button.pressed.connect(_show_national_team_standings)
	section_panel.add_child(team_button)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _enter_national_event(event_id: String) -> void:
	if national_events_completed.has(event_id):
		return
	for event in _national_event_catalog():
		if str(event["id"]) == event_id:
			selected_national_event_id = event_id
			national_championship_active = true
			career_race = true
			_start_race()
			return

func _update_national_rival_results(player_won: bool) -> void:
	if not national_rival_records.has(rival_name):
		_ensure_national_rival_records()
	var opponent: Dictionary = national_rival_records.get(rival_name, {"wins":0,"losses":0,"rating":85})
	if player_won:
		opponent["losses"] = int(opponent.get("losses",0)) + 1
	else:
		opponent["wins"] = int(opponent.get("wins",0)) + 1
		opponent["rating"] = mini(100, int(opponent.get("rating",85)) + 1)
	national_rival_records[rival_name] = opponent
	for name in national_rival_names:
		if name == rival_name:
			continue
		var record: Dictionary = national_rival_records.get(name, {"wins":0,"losses":0,"rating":85})
		if randf() < 0.6:
			record["wins"] = int(record.get("wins",0)) + 1
		else:
			record["losses"] = int(record.get("losses",0)) + 1
		national_rival_records[name] = record

func _update_national_season(player_won: bool) -> void:
	national_season_message = ""
	if national_events_completed.has(selected_national_event_id):
		national_season_message = "NATIONAL EVENT ALREADY COMPLETED — NO EXTRA POINTS"
		return
	var event := _get_national_event()
	national_events_completed.append(selected_national_event_id)
	var earned_points := int(event["points"]) if player_won else 4
	national_season_points["YOU"] = int(national_season_points.get("YOU",0)) + earned_points
	national_season_message = "NATIONAL CHAMPIONSHIP POINTS  |  +%d" % earned_points
	var player_team := current_team if current_team != "" else "Independent"
	national_team_points[player_team] = int(national_team_points.get(player_team,0)) + earned_points
	for name in national_rival_names:
		var rival_points := 15 if randf() < 0.6 else 5
		national_season_points[name] = int(national_season_points.get(name,0)) + rival_points
		var rival_team := "Apex Performance" if name == "Darius King" else ("Velocity Motorsport" if name == "Sofia Reyes" else ("National Racing Union" if name == "Andre Mitchell" else "International Elite"))
		national_team_points[rival_team] = int(national_team_points.get(rival_team,0)) + rival_points
	if national_events_completed.size() >= _national_event_catalog().size():
		var rows: Array = []
		for driver in ["YOU"] + national_rival_names:
			rows.append({"name":driver,"points":int(national_season_points.get(driver,0))})
		rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
		last_national_champion = str(rows[0]["name"])
		last_national_points = national_season_points.duplicate(true)
		last_national_team_points = national_team_points.duplicate(true)
		last_national_season_number = national_season_number
		if last_national_champion == "YOU":
			career_cash += 30000
			career_reputation += 100
			story_stage = 16
			last_story_message = "CHAPTER 4 COMPLETE: You won the National Drag Association championship."
			national_season_message = "NATIONAL CHAMPION! $30,000 + 100 REP. NATIONAL TITLE SECURED."
			_add_career_notification("NATIONAL CHAMPION: You won the National Drag Association title.")
		else:
			national_season_message = "NATIONAL SEASON %d CHAMPION: %s. The next season awaits." % [national_season_number,last_national_champion]
		if last_national_champion == "YOU":
			international_pathway_unlocked = true
		national_season_number += 1
		national_season_points = {}
		national_events_completed = []
		national_team_points = {}
	_save_career()

func _show_national_standings() -> void:
	var display: Dictionary = national_season_points
	var season_display := national_season_number
	var heading := "CURRENT NATIONAL SEASON"
	if national_events_completed.is_empty() and last_national_season_number > 0:
		display = last_national_points
		season_display = last_national_season_number
		heading = "LAST NATIONAL CHAMPION  |  " + last_national_champion
	var rows: Array = [{"name":"YOU","points":int(display.get("YOU",0))}]
	for name in national_rival_names:
		rows.append({"name":name,"points":int(display.get(name,0))})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := "%s\nSEASON %d\n\n" % [heading,season_display]
	for index in range(rows.size()):
		body += "%d. %s — %d points\n" % [index + 1,str(rows[index]["name"]),int(rows[index]["points"])]
	body += "\nEVENTS COMPLETED  |  %d / %d" % [national_events_completed.size(),_national_event_catalog().size()]
	_show_subpage("NATIONAL STANDINGS",body,"BACK TO CAREER")

func _show_national_team_standings() -> void:
	var display: Dictionary = national_team_points
	var heading := "CURRENT NATIONAL TEAM TABLE"
	if display.is_empty() and not last_national_team_points.is_empty():
		display = last_national_team_points
		heading = "LAST NATIONAL TEAM CHAMPIONSHIP"
	var rows: Array = []
	for team in display.keys():
		rows.append({"name":str(team),"points":int(display[team])})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := heading + "\n\n"
	if rows.is_empty():
		body += "Team points will appear after the first national event."
	else:
		for index in range(rows.size()):
			body += "%d. %s — %d points\n" % [index + 1,str(rows[index]["name"]),int(rows[index]["points"])]
	_show_subpage("NATIONAL TEAM CHAMPIONSHIP",body,"BACK TO CAREER")

func _show_national_pathway() -> void:
	var body := "NATIONAL CHAMPIONSHIP PATHWAY\n\n"
	body += "Your professional season victory has earned you an invitation to pursue the National Championship.\n\n"
	body += "QUALIFICATION REQUIREMENTS\n"
	body += "Professional Season Title  |  %s\n" % ("COMPLETE" if national_pathway_unlocked else "LOCKED")
	body += "Career Wins  |  %d / 25\n" % mini(career_wins, 25)
	body += "Driver Level  |  %d / 10\n" % mini(_driver_level(), 10)
	body += "Reputation  |  %d / 300\n" % mini(career_reputation, 300)
	var qualified := national_pathway_unlocked and career_wins >= 25 and _driver_level() >= 10 and career_reputation >= 300
	body += "\nSTATUS  |  %s" % ("QUALIFIED — NATIONAL SERIES ENTRY READY" if qualified else "INVITATION SECURED — COMPLETE THE REMAINING REQUIREMENTS")
	_show_subpage("NATIONAL CHAMPIONSHIP", body, "BACK TO CAREER")
	if qualified:
		var enter_button := _make_button("REGISTER FOR NATIONAL CHAMPIONSHIP", Color("#c17a28"))
		enter_button.pressed.connect(_begin_national_story)
		section_panel.add_child(enter_button)

func _international_event_catalog() -> Array:
	return [
		{"id":"int_402","name":"World Quarter-Mile Invitational","distance":402.0,"reward":12000,"rival_speed":320.0,"entry_fee":4000,"points":15},
		{"id":"int_804","name":"Continental Half-Mile Grand Prix","distance":804.0,"reward":16000,"rival_speed":326.0,"entry_fee":5500,"points":15},
		{"id":"int_1000","name":"Global Top Speed Masters","distance":1000.0,"reward":22000,"rival_speed":332.0,"entry_fee":7000,"points":18},
		{"id":"int_1609","name":"World Mile Endurance","distance":1609.0,"reward":28000,"rival_speed":338.0,"entry_fee":8500,"points":18},
		{"id":"int_201","name":"International Eighth-Mile Sprint","distance":201.0,"reward":18000,"rival_speed":330.0,"entry_fee":5000,"points":15},
		{"id":"int_final","name":"World Drag Racing Final","distance":1609.0,"reward":50000,"rival_speed":348.0,"entry_fee":12000,"points":25}
	]

func _get_international_event() -> Dictionary:
	for event in _international_event_catalog():
		if str(event["id"]) == selected_international_event_id:
			return event
	return _international_event_catalog()[0]

func _ensure_international_rival_records() -> void:
	for index in range(international_rival_names.size()):
		var name := str(international_rival_names[index])
		if not international_rival_records.has(name):
			international_rival_records[name] = {"wins":0,"losses":0,"rating":90 + index * 2,"car":"Muscle V8","upgrade_level":8 + index}

func _show_international_pathway() -> void:
	var body := "INTERNATIONAL CHAMPIONSHIP PATHWAY\n\n"
	body += "Your national championship victory has attracted international attention. The Global Drag Racing Federation is reviewing your application.\n\n"
	body += "QUALIFICATION REQUIREMENTS\n"
	body += "National Championship Title  |  %s\n" % ("COMPLETE" if international_pathway_unlocked else "LOCKED")
	body += "Career Wins  |  %d / 40\n" % mini(career_wins, 40)
	body += "Driver Level  |  %d / 15\n" % mini(_driver_level(), 15)
	body += "Reputation  |  %d / 500\n" % mini(career_reputation, 500)
	var qualified := international_pathway_unlocked and career_wins >= 40 and _driver_level() >= 15 and career_reputation >= 500
	body += "\nSTATUS  |  %s" % ("QUALIFIED — WORLD SERIES ENTRY READY" if qualified else "INVITATION RECEIVED — COMPLETE THE REMAINING REQUIREMENTS")
	_show_subpage("INTERNATIONAL CHAMPIONSHIP", body, "BACK TO CAREER")
	if qualified:
		var enter_button := _make_button("REGISTER FOR INTERNATIONAL CHAMPIONSHIP", Color("#c17a28"))
		enter_button.pressed.connect(_begin_international_story)
		section_panel.add_child(enter_button)

func _begin_international_story() -> void:
	if not (international_pathway_unlocked and career_wins >= 40 and _driver_level() >= 15 and career_reputation >= 500):
		_show_international_pathway()
		return
	if story_stage < 17:
		story_stage = 17
		last_story_message = "Global Drag Racing Federation: Your international licence is approved. The world championship begins now."
	_save_career()
	_show_story_missions()

func _show_international_championship() -> void:
	var qualified := international_pathway_unlocked and career_wins >= 40 and _driver_level() >= 15 and career_reputation >= 500
	if not qualified:
		_show_international_pathway()
		return
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "INTERNATIONAL CHAMPIONSHIP"
	status_label.text = "GLOBAL DRAG RACING FEDERATION  |  SEASON %d" % international_season_number
	_clear_section()
	_add_section_label("WORLD SERIES LICENCE  |  ENTRY APPROVED")
	_add_section_label("SEASON PROGRESS  |  %d / %d events completed" % [international_events_completed.size(), _international_event_catalog().size()])
	_add_section_label("TEAM  |  %s" % (current_team if current_team != "" else "INDEPENDENT"))
	for event in _international_event_catalog():
		var event_id := str(event["id"])
		_add_section_label("%s  |  %d m  |  Prize $%s  |  Entry $%s  |  %d pts" % [str(event["name"]), int(event["distance"]), str(event["reward"]), str(event["entry_fee"]), int(event["points"])])
		var completed := international_events_completed.has(event_id)
		var event_button := _make_button(("COMPLETED  |  " if completed else "ENTER  |  ") + str(event["name"]), Color("#34485d") if completed else Color("#c17a28"))
		event_button.disabled = completed
		event_button.pressed.connect(_enter_international_event.bind(event_id))
		section_panel.add_child(event_button)
	var standings_button := _make_button("VIEW INTERNATIONAL STANDINGS", Color("#2675a8"))
	standings_button.add_theme_color_override("font_color", Color.WHITE)
	standings_button.pressed.connect(_show_international_standings)
	section_panel.add_child(standings_button)
	var team_button := _make_button("VIEW WORLD TEAM CHAMPIONSHIP", Color("#34485d"))
	team_button.pressed.connect(_show_international_team_standings)
	section_panel.add_child(team_button)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _enter_international_event(event_id: String) -> void:
	if international_events_completed.has(event_id):
		return
	for event in _international_event_catalog():
		if str(event["id"]) == event_id:
			selected_international_event_id = event_id
			international_championship_active = true
			career_race = true
			_start_race()
			return

func _update_international_rival_results(player_won: bool) -> void:
	_ensure_international_rival_records()
	var opponent: Dictionary = international_rival_records.get(rival_name, {"wins":0,"losses":0,"rating":90})
	if player_won:
		opponent["losses"] = int(opponent.get("losses",0)) + 1
	else:
		opponent["wins"] = int(opponent.get("wins",0)) + 1
		opponent["rating"] = mini(100, int(opponent.get("rating",90)) + 1)
	international_rival_records[rival_name] = opponent
	for name in international_rival_names:
		if name == rival_name:
			continue
		var record: Dictionary = international_rival_records.get(name, {"wins":0,"losses":0,"rating":90})
		if randf() < 0.6:
			record["wins"] = int(record.get("wins",0)) + 1
		else:
			record["losses"] = int(record.get("losses",0)) + 1
		international_rival_records[name] = record

func _update_international_season(player_won: bool) -> void:
	international_season_message = ""
	if international_events_completed.has(selected_international_event_id):
		international_season_message = "INTERNATIONAL EVENT ALREADY COMPLETED — NO EXTRA POINTS"
		return
	var event := _get_international_event()
	international_events_completed.append(selected_international_event_id)
	var earned_points := int(event["points"]) if player_won else 5
	international_season_points["YOU"] = int(international_season_points.get("YOU",0)) + earned_points
	international_season_message = "WORLD CHAMPIONSHIP POINTS  |  +%d" % earned_points
	var player_team := current_team if current_team != "" else "Independent"
	international_team_points[player_team] = int(international_team_points.get(player_team,0)) + earned_points
	var rival_teams := ["Scuderia Milano","Pan-African Velocity","Santos Motorsport","Tokyo Apex"]
	for index in range(international_rival_names.size()):
		var name := str(international_rival_names[index])
		var rival_points := 15 if randf() < 0.6 else 5
		international_season_points[name] = int(international_season_points.get(name,0)) + rival_points
		var rival_team := str(rival_teams[index])
		international_team_points[rival_team] = int(international_team_points.get(rival_team,0)) + rival_points
	if international_events_completed.size() >= _international_event_catalog().size():
		var rows: Array = []
		for driver in ["YOU"] + international_rival_names:
			rows.append({"name":driver,"points":int(international_season_points.get(driver,0))})
		rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
		last_international_champion = str(rows[0]["name"])
		last_international_points = international_season_points.duplicate(true)
		last_international_team_points = international_team_points.duplicate(true)
		last_international_season_number = international_season_number
		if last_international_champion == "YOU":
			career_cash += 75000
			lifetime_earnings += 75000
			superstar_pathway_unlocked = true
			career_reputation += 150
			story_stage = 18
			last_story_message = "CHAPTER 5 COMPLETE: You conquered the World Drag Racing Championship."
			international_season_message = "WORLD CHAMPION! $75,000 + 150 REP. GLOBAL TITLE SECURED."
			_add_career_notification("WORLD CHAMPION: You won the International Drag Racing title.")
		else:
			international_season_message = "INTERNATIONAL SEASON %d CHAMPION: %s. The next season awaits." % [international_season_number,last_international_champion]
		international_season_number += 1
		international_season_points = {}
		international_events_completed = []
		international_team_points = {}
	_save_career()

func _show_international_standings() -> void:
	var display: Dictionary = international_season_points
	var season_display := international_season_number
	var heading := "CURRENT INTERNATIONAL SEASON"
	if international_events_completed.is_empty() and last_international_season_number > 0:
		display = last_international_points
		season_display = last_international_season_number
		heading = "LAST WORLD CHAMPION  |  " + last_international_champion
	var rows: Array = [{"name":"YOU","points":int(display.get("YOU",0))}]
	for name in international_rival_names:
		rows.append({"name":name,"points":int(display.get(name,0))})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := "%s\nSEASON %d\n\n" % [heading,season_display]
	for index in range(rows.size()):
		body += "%d. %s — %d points\n" % [index + 1,str(rows[index]["name"]),int(rows[index]["points"])]
	body += "\nEVENTS COMPLETED  |  %d / %d" % [international_events_completed.size(),_international_event_catalog().size()]
	_show_subpage("INTERNATIONAL STANDINGS",body,"BACK TO CAREER")

func _show_international_team_standings() -> void:
	var display: Dictionary = international_team_points
	var heading := "CURRENT WORLD TEAM TABLE"
	if display.is_empty() and not last_international_team_points.is_empty():
		display = last_international_team_points
		heading = "LAST WORLD TEAM CHAMPIONSHIP"
	var rows: Array = []
	for team in display.keys():
		rows.append({"name":str(team),"points":int(display[team])})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := heading + "\n\n"
	if rows.is_empty():
		body += "Team points will appear after the first international event."
	else:
		for index in range(rows.size()):
			body += "%d. %s — %d points\n" % [index + 1,str(rows[index]["name"]),int(rows[index]["points"])]
	_show_subpage("WORLD TEAM CHAMPIONSHIP",body,"BACK TO CAREER")


func _superstar_event_catalog() -> Array:
	return [
		{"id":"star_402","name":"Legends Quarter-Mile Crown","distance":402.0,"reward":30000,"rival_speed":360.0,"entry_fee":15000,"points":18},
		{"id":"star_804","name":"Apex Half-Mile Masters","distance":804.0,"reward":38000,"rival_speed":366.0,"entry_fee":18000,"points":18},
		{"id":"star_1000","name":"Global Velocity Record","distance":1000.0,"reward":48000,"rival_speed":372.0,"entry_fee":22000,"points":20},
		{"id":"star_1609","name":"Legends Mile Endurance","distance":1609.0,"reward":60000,"rival_speed":378.0,"entry_fee":26000,"points":20},
		{"id":"star_201","name":"Superstar Sprint Shootout","distance":201.0,"reward":42000,"rival_speed":374.0,"entry_fee":20000,"points":18},
		{"id":"star_final","name":"World Legends Grand Final","distance":1609.0,"reward":100000,"rival_speed":390.0,"entry_fee":40000,"points":30}
	]

func _get_superstar_event() -> Dictionary:
	for event in _superstar_event_catalog():
		if str(event["id"]) == selected_superstar_event_id:
			return event
	return _superstar_event_catalog()[0]

func _ensure_superstar_rivals() -> void:
	for index in range(superstar_rival_names.size()):
		var name := str(superstar_rival_names[index])
		if not superstar_rival_records.has(name):
			superstar_rival_records[name] = {"wins":0,"losses":0,"rating":96 + index,"car":"Muscle V8","upgrade_level":12 + index}

func _show_superstar_pathway() -> void:
	var body := "SUPERSTAR WORLD LEGENDS PATHWAY\n\n"
	body += "The world title has made you a global icon. The Legends Racing Council has invited you to face five decorated drivers.\n\n"
	body += "International title  |  %s\n" % ("EARNED" if superstar_pathway_unlocked else "LOCKED")
	body += "Career wins  |  %d / 60\n" % mini(career_wins,60)
	body += "Driver level  |  %d / 20\n" % mini(_driver_level(),20)
	body += "Reputation  |  %d / 750\n" % mini(career_reputation,750)
	var ready := superstar_pathway_unlocked and career_wins >= 60 and _driver_level() >= 20 and career_reputation >= 750
	body += "\nSTATUS  |  %s" % ("QUALIFIED" if ready else "COMPLETE THE REMAINING REQUIREMENTS")
	_show_subpage("SUPERSTAR PATHWAY",body,"BACK TO CAREER")
	if ready:
		var register := _make_button("REGISTER FOR LEGENDS SERIES",Color("#d6a52d"))
		register.pressed.connect(_begin_superstar_story)
		section_panel.add_child(register)

func _begin_superstar_story() -> void:
	if not (superstar_pathway_unlocked and career_wins >= 60 and _driver_level() >= 20 and career_reputation >= 750):
		_show_superstar_pathway()
		return
	story_stage = maxi(story_stage,19)
	last_story_message = "Legends Racing Council: Your invitation is official. Defend your place among the greats."
	_save_career()
	_show_story_missions()

func _show_superstar_championship() -> void:
	if not (superstar_pathway_unlocked and career_wins >= 60 and _driver_level() >= 20 and career_reputation >= 750):
		_show_superstar_pathway()
		return
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "SUPERSTAR CHAMPIONSHIP"
	status_label.text = "LEGENDS RACING COUNCIL  |  SEASON %d" % superstar_season_number
	_clear_section()
	_add_section_label("GLOBAL LEGENDS LICENCE  |  ACTIVE")
	_add_section_label("PROGRESS  |  %d / 6 EVENTS" % superstar_events_completed.size())
	for event in _superstar_event_catalog():
		var event_id := str(event["id"])
		_add_section_label("%s  |  %d m  |  Prize $%s  |  Entry $%s" % [str(event["name"]),int(event["distance"]),str(event["reward"]),str(event["entry_fee"])])
		var done := superstar_events_completed.has(event_id)
		var race_button := _make_button(("COMPLETED  |  " if done else "ENTER  |  ")+str(event["name"]),Color("#34485d") if done else Color("#d6a52d"))
		race_button.disabled = done
		race_button.pressed.connect(_enter_superstar_event.bind(event_id))
		section_panel.add_child(race_button)
	var standings := _make_button("LEGENDS STANDINGS",Color("#2675a8"))
	standings.add_theme_color_override("font_color",Color.WHITE)
	standings.pressed.connect(_show_superstar_standings)
	section_panel.add_child(standings)
	var hall := _make_button("GLOBAL HALL OF FAME",Color("#34485d"))
	hall.add_theme_color_override("font_color",Color.WHITE)
	hall.pressed.connect(_show_global_hall_of_fame)
	section_panel.add_child(hall)
	var back := _make_button("BACK TO CAREER",Color("#263545"))
	back.add_theme_color_override("font_color",Color.WHITE)
	back.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back)

func _enter_superstar_event(event_id: String) -> void:
	if superstar_events_completed.has(event_id):
		return
	for event in _superstar_event_catalog():
		if str(event["id"]) == event_id:
			selected_superstar_event_id = event_id
			superstar_championship_active = true
			career_race = true
			_start_race()
			return

func _update_superstar_rival_results(player_won: bool) -> void:
	_ensure_superstar_rivals()
	var record: Dictionary = superstar_rival_records.get(rival_name,{})
	if player_won:
		record["losses"] = int(record.get("losses",0)) + 1
	else:
		record["wins"] = int(record.get("wins",0)) + 1
		record["rating"] = mini(100,int(record.get("rating",96)) + 1)
	superstar_rival_records[rival_name] = record

func _update_superstar_season(player_won: bool) -> void:
	if superstar_events_completed.has(selected_superstar_event_id):
		superstar_season_message = "LEGENDS EVENT ALREADY COMPLETED"
		return
	var event := _get_superstar_event()
	superstar_events_completed.append(selected_superstar_event_id)
	var points := int(event["points"]) if player_won else 6
	superstar_season_points["YOU"] = int(superstar_season_points.get("YOU",0)) + points
	superstar_season_message = "LEGENDS CHAMPIONSHIP POINTS  |  +%d" % points
	for name in superstar_rival_names:
		superstar_season_points[name] = int(superstar_season_points.get(name,0)) + (18 if randf() < 0.65 else 7)
	if superstar_events_completed.size() == _superstar_event_catalog().size():
		var rows: Array = []
		for driver in ["YOU"] + superstar_rival_names:
			rows.append({"name":driver,"points":int(superstar_season_points.get(driver,0))})
		rows.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
		last_superstar_champion = str(rows[0]["name"])
		last_superstar_points = superstar_season_points.duplicate(true)
		last_superstar_season_number = superstar_season_number
		if last_superstar_champion == "YOU":
			career_cash += 200000
			lifetime_earnings += 200000
			career_reputation += 250
			superstar_titles += 1
			story_stage = 20
			last_story_message = "CHAPTER 6 COMPLETE: You became a global drag racing legend."
			superstar_season_message = "GLOBAL LEGENDS CHAMPION! $200,000 + 250 REP."
			_add_career_notification("GLOBAL LEGENDS CHAMPION: You reached the summit.")
		else:
			superstar_season_message = "LEGENDS SEASON CHAMPION: %s" % last_superstar_champion
		superstar_season_number += 1
		superstar_season_points = {}
		superstar_events_completed = []
	_save_career()

func _show_superstar_standings() -> void:
	var display: Dictionary = last_superstar_points if superstar_events_completed.is_empty() and last_superstar_season_number > 0 else superstar_season_points
	var rows: Array = [{"name":"YOU","points":int(display.get("YOU",0))}]
	for name in superstar_rival_names:
		rows.append({"name":name,"points":int(display.get(name,0))})
	rows.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := "GLOBAL LEGENDS  |  SEASON %d\n\n" % (last_superstar_season_number if superstar_events_completed.is_empty() and last_superstar_season_number > 0 else superstar_season_number)
	for index in range(rows.size()):
		body += "%d. %s — %d points\n" % [index+1,str(rows[index]["name"]),int(rows[index]["points"])]
	_show_subpage("LEGENDS STANDINGS",body,"BACK TO CAREER")

func _show_global_hall_of_fame() -> void:
	var body := "GLOBAL HALL OF FAME\n\n"
	body += "Superstar titles  |  %d\n" % superstar_titles
	body += "Career wins / losses  |  %d / %d\n" % [career_wins,career_losses]
	body += "Best win streak  |  %d\n" % best_win_streak
	body += "Lifetime prize earnings  |  $%s\n" % str(lifetime_earnings)
	body += "Driver level  |  %d\n" % _driver_level()
	body += "Reputation  |  %d\n" % career_reputation
	body += "International title pathway  |  %s\n" % ("UNLOCKED" if international_pathway_unlocked else "LOCKED")
	body += "Legends invitation  |  %s" % ("UNLOCKED" if superstar_pathway_unlocked else "LOCKED")
	_show_subpage("GLOBAL HALL OF FAME",body,"BACK TO CAREER")

func _show_professional_standings() -> void:
	var display_points: Dictionary = professional_season_points
	var heading := "CURRENT PROFESSIONAL SEASON"
	var display_number := professional_season_number
	if professional_events_completed.is_empty() and last_professional_season_number > 0:
		display_points = last_professional_points
		display_number = last_professional_season_number
		heading = "LAST SEASON CHAMPION  |  " + last_professional_champion
	var rows: Array = [{"name":"YOU","points":int(display_points.get("YOU",0))}]
	for name in professional_rival_names:
		rows.append({"name":name,"points":int(display_points.get(name,0))})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := "%s\nSEASON %d\n\n" % [heading, display_number]
	for index in range(rows.size()):
		body += "%d. %s — %d points\n" % [index + 1, str(rows[index]["name"]), int(rows[index]["points"])]
	body += "\nEVENTS COMPLETED  |  %d / %d\n" % [professional_events_completed.size(), _professional_event_catalog().size()]
	body += "PROFESSIONAL LICENSE  |  ACTIVE\nNATIONAL PATHWAY  |  %s" % ("UNLOCKED" if national_pathway_unlocked else "LOCKED — WIN A PRO SEASON")
	_show_subpage("PROFESSIONAL STANDINGS", body, "BACK TO CAREER")

func _show_professional_team_standings() -> void:
	var display_teams: Dictionary = professional_team_points
	var heading := "CURRENT TEAM CHAMPIONSHIP"
	if display_teams.is_empty() and not last_professional_team_points.is_empty():
		display_teams = last_professional_team_points
		heading = "LAST COMPLETED TEAM CHAMPIONSHIP"
	var rows: Array = []
	for team_name in display_teams.keys():
		rows.append({"name":str(team_name),"points":int(display_teams[team_name])})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["points"]) > int(b["points"]))
	var body := heading + "\n\n"
	if rows.is_empty():
		body += "No team points recorded yet. Enter a professional event to begin."
	else:
		for index in range(rows.size()):
			body += "%d. %s — %d points\n" % [index + 1, str(rows[index]["name"]), int(rows[index]["points"])]
	body += "\nYour team: %s" % (current_team if current_team != "" else "Independent")
	_show_subpage("TEAM CHAMPIONSHIP", body, "BACK TO CAREER")

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
		var required_rep := _event_min_reputation(event_id)
		var entry_fee := _event_entry_fee(event_id)
		var unlocked := career_reputation >= required_rep
		_add_section_label("ENTRY FEE  |  $%s  •  REQUIRED REP  |  %d" % [str(entry_fee), required_rep])
		if not unlocked:
			_add_section_label("LOCKED  |  Need %d more reputation" % (required_rep - career_reputation))
		var caption := ("SELECTED  •  " + event_name) if event_id == selected_event_id else ("SELECT  •  " + event_name)
		if not unlocked:
			caption = "LOCKED  •  " + event_name
		var event_button := _make_button(caption, Color("#f5a623") if event_id == selected_event_id else Color("#34485d"))
		if event_id != selected_event_id:
			event_button.add_theme_color_override("font_color", Color.WHITE)
		event_button.disabled = not unlocked
		event_button.pressed.connect(_select_event.bind(event_id))
		section_panel.add_child(event_button)
	var back_button := _make_button("BACK TO CAREER", Color("#263545"))
	back_button.add_theme_color_override("font_color", Color.WHITE)
	back_button.pressed.connect(_show_career_dashboard)
	section_panel.add_child(back_button)

func _select_event(event_id: String) -> void:
	for event in _event_catalog():
		if str(event["id"]) == event_id:
			if career_reputation < _event_min_reputation(event_id):
				return
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

func _show_achievements(return_to_menu: bool = false) -> void:
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
	_show_subpage("ACHIEVEMENTS", body, "BACK TO MAIN MENU" if return_to_menu else "BACK TO CAREER", return_to_menu)

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

func _show_subpage(page_title: String, body: String, back_caption: String, back_to_menu: bool = false) -> void:
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
	var back_action: Callable = _show_menu if back_to_menu else _show_career_dashboard
	back_button.pressed.connect(back_action)
	section_panel.add_child(back_button)

func _add_story_race_button(button_text: String, event_id: String) -> void:
	var race_button := _make_button(button_text, Color("#b34d43"))
	race_button.add_theme_color_override("font_color", Color.WHITE)
	race_button.pressed.connect(func():
		selected_event_id = event_id
		story_race_active = true
		career_race = true
		_start_race()
	)
	section_panel.add_child(race_button)


func _show_story_missions() -> void:
	menu_panel.hide()
	race_panel.hide()
	section_panel.show()
	title_label.text = "STORY & MISSIONS"
	status_label.text = "FROM THE UNDERGROUND TO THE PROFESSIONAL CIRCUIT"
	_clear_section()
	if story_stage == 0:
		_add_section_label("CHAPTER 1  |  A FRESH START")
		_add_section_label("Your old life has fallen apart. You lost your job, your marriage ended, and the court has ordered you to pay monthly child support. You need a way to rebuild.")
		_add_section_label("Jasper, an old friend, knows the underground racing scene and can get you small jobs, but he expects you to prove yourself.")
		var begin_button := _make_button("CALL JASPER", Color("#f5a623"))
		begin_button.pressed.connect(func():
			story_stage = 1
			last_story_message = "Jasper: Win your first career race and show them you belong."
			_save_career()
			_show_story_missions()
		)
		section_panel.add_child(begin_button)
	elif story_stage <= 4:
		_add_section_label("CHAPTER 1  |  A FRESH START")
		if story_stage == 1:
			_add_section_label("MISSION 1  |  PROVE YOURSELF")
			_add_section_label("Jasper: Win your first career race and show them you belong.")
			_add_section_label("OBJECTIVE  |  Win 1 Career race")
		elif story_stage == 2:
			_add_section_label("MISSION 2  |  BUILD A NAME")
			_add_section_label("Jasper has noticed your first result. Now prove it wasn't a one-off.")
			_add_section_label("OBJECTIVE  |  Win 3 Career races in total")
		elif story_stage == 3:
			_add_section_label("MISSION 3  |  BIGGER OPPORTUNITIES")
			_add_section_label("A serious racing organizer is watching. Reach 50 reputation and win 5 Career races.")
			_add_section_label("OBJECTIVE  |  5 Career wins and 50 reputation")
		else:
			_add_section_label("CHAPTER 1 COMPLETE  |  CHAPTER 2 UNLOCKED")
			_add_section_label("Jasper: Rico Vale controls a bigger part of the underground circuit.")
			var meet_button := _make_button("MEET RICO VALE", Color("#f5a623"))
			meet_button.pressed.connect(func():
				story_stage = 5
				last_story_message = "Rico Vale: Beat Viktor Kane and earn your place in my circuit."
				_save_career()
				_show_story_missions()
			)
			section_panel.add_child(meet_button)
		if story_stage < 4:
			_add_section_label("CAREER WINS  |  %d / 5" % career_wins)
			_add_section_label("REPUTATION  |  %d / 50" % career_reputation)
	elif story_stage <= 8:
		_add_section_label("CHAPTER 2  |  THE UNDERGROUND CIRCUIT")
		if story_stage == 5:
			_add_section_label("MISSION 1  |  THE FIRST IMPRESSION")
			_add_section_label("Rico: Viktor Kane is waiting at the quarter-mile strip.")
			_add_section_label("OBJECTIVE  |  Defeat Viktor in the Quarter-Mile Sprint")
			_add_section_label("REWARD  |  $1,000 and +10 reputation")
			_add_story_race_button("RACE VIKTOR  |  QUARTER-MILE", "quarter_mile")
		elif story_stage == 6:
			_add_section_label("MISSION 2  |  NO EASY WINS")
			_add_section_label("Viktor wants a rematch. Rico has arranged a tougher Pro Quarter-Mile.")
			_add_section_label("OBJECTIVE  |  Defeat Viktor in the Pro Quarter-Mile")
			_add_section_label("REWARD  |  $1,800 and +15 reputation")
			_add_story_race_button("REMATCH VIKTOR  |  PRO QUARTER", "pro_quarter")
		elif story_stage == 7:
			_add_section_label("MISSION 3  |  OWN THE NIGHT")
			_add_section_label("Rico's final underground test is the Half-Mile Challenge.")
			_add_section_label("OBJECTIVE  |  Defeat Viktor in the Half-Mile Challenge")
			_add_section_label("REWARD  |  $3,500 and +25 reputation")
			_add_story_race_button("UNDERGROUND FINAL  |  HALF-MILE", "half_mile")
		else:
			_add_section_label("CHAPTER 2 COMPLETE  |  UNDERGROUND CIRCUIT CHAMPION")
			_add_section_label("Rico: You have conquered my circuit. Now prove you belong in sanctioned motorsport.")
			_add_section_label("NEXT  |  Apply for a professional racing licence.")
			var apply_button := _make_button("APPLY FOR PRO LICENCE", Color("#f5a623"))
			apply_button.pressed.connect(func():
				story_stage = 9
				last_story_message = "National Drag Association: Your application is on file. Meet the qualification standards to receive a licence."
				_save_career()
				_show_story_missions()
			)
			section_panel.add_child(apply_button)
	else:
		_add_section_label("CHAPTER 3  |  THE PROFESSIONAL CIRCUIT")
		if story_stage == 9:
			_add_section_label("LICENCE QUALIFICATION  |  NATIONAL DRAG ASSOCIATION")
			_add_section_label("Professional racing requires proven results, experience and public standing.")
			_add_section_label("REQUIREMENTS  |  10 Career wins • Driver Level 5 • 150 reputation")
			_add_section_label("YOUR RECORD  |  %d wins • Level %d • %d reputation" % [career_wins, _driver_level(), career_reputation])
			if career_wins >= 10 and _driver_level() >= 5 and career_reputation >= 150:
				var qualify_button := _make_button("TAKE LICENCE QUALIFIER", Color("#f5a623"))
				qualify_button.pressed.connect(func():
					story_stage = 10
					last_story_message = "NDA Official: Your record qualifies. Pass the sanctioned Pro Quarter-Mile assessment."
					_save_career()
					_show_story_missions()
				)
				section_panel.add_child(qualify_button)
			else:
				_add_section_label("NOT YET QUALIFIED  |  Keep racing in the available divisions.")
		elif story_stage == 10:
			_add_section_label("LICENCE TEST  |  SANCTIONED QUALIFIER")
			_add_section_label("Official: This is a regulated event. Beat experienced driver Elena Cross to earn your professional licence.")
			_add_section_label("EVENT  |  Pro Quarter-Mile")
			_add_story_race_button("RACE ELENA CROSS  |  LICENCE TEST", "pro_quarter")
		elif story_stage >= 11 and story_stage <= 13:
			_add_section_label("OFFICIAL CHAMPIONSHIP  |  PROFESSIONAL DEBUT")
			var round_events := [
				{"id":"pro_quarter","name":"Pro Quarter-Mile"},
				{"id":"half_mile","name":"Half-Mile Challenge"},
				{"id":"top_speed","name":"Top Speed Shootout"}
			]
			var round_index := story_stage - 11
			var round: Dictionary = round_events[round_index]
			_add_section_label("ROUND %d OF 3  |  %s" % [round_index + 1, str(round["name"])])
			_add_section_label("Win each round to secure the inaugural professional championship.")
			_add_section_label("CHAMPIONSHIP WINS  |  %d / 3" % pro_championship_points)
			_add_story_race_button("ENTER ROUND %d" % (round_index + 1), str(round["id"]))
		elif story_stage == 14:
			_add_section_label("CHAPTER 3 COMPLETE  |  PROFESSIONAL CHAMPION")
			_add_section_label("You earned your National Drag Association licence and won your first sanctioned professional championship. Your career has entered the professional ranks.")
			_add_section_label("PRO LICENCE  |  ACTIVE")
			_add_section_label("CHAMPIONSHIP WINS  |  %d / 3" % pro_championship_points)
		else:
			_add_section_label("CHAPTER 4  |  THE NATIONAL STAGE")
			if story_stage == 15:
				_add_section_label("Your professional season title secured an invitation. After meeting the career requirements, the National Drag Association has approved your national entry.")
				_add_section_label("OBJECTIVE  |  Compete across all six national events and win the overall championship.")
				var national_story_button := _make_button("ENTER NATIONAL CHAMPIONSHIP", Color("#c17a28"))
				national_story_button.pressed.connect(_show_national_championship)
				section_panel.add_child(national_story_button)
			elif story_stage == 16:
				_add_section_label("CHAPTER 4 COMPLETE  |  NATIONAL CHAMPION")
				_add_section_label("You conquered the national series and established yourself among the country's elite drag racers.")
				_add_section_label("NEXT  |  The Global Drag Racing Federation has noticed your results.")
			else:
				_add_section_label("CHAPTER 5  |  THE WORLD STAGE")
				if story_stage == 17:
					_add_section_label("Your national title earned an international invitation. Prove yourself against elite drivers from around the world.")
					_add_section_label("OBJECTIVE  |  Qualify, enter all six international events and win the world championship.")
					var international_story_button := _make_button("ENTER INTERNATIONAL CHAMPIONSHIP", Color("#c17a28"))
					international_story_button.pressed.connect(_show_international_championship)
					section_panel.add_child(international_story_button)
				elif story_stage == 18:
					_add_section_label("CHAPTER 5 COMPLETE  |  WORLD CHAMPION")
					_add_section_label("You have conquered the international circuit and claimed the world title.")
					_add_section_label("NEXT  |  The Legends Racing Council is preparing an invitation.")
				else:
					_add_section_label("CHAPTER 6  |  THE LEGEND")
					if story_stage == 19:
						_add_section_label("Five legendary drivers stand between you and immortality.")
						_add_section_label("OBJECTIVE  |  Win the six-event Global Legends championship.")
						var legends_button := _make_button("ENTER SUPERSTAR CHAMPIONSHIP",Color("#d6a52d"))
						legends_button.pressed.connect(_show_superstar_championship)
						section_panel.add_child(legends_button)
					else:
						_add_section_label("CHAPTER 6 COMPLETE  |  GLOBAL LEGEND")
						_add_section_label("Your name is now part of drag racing history.")
	if last_story_message != "":
		_add_section_label(last_story_message)
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
		last_story_message = "CHAPTER 1 COMPLETE: You earned $2,500. Jasper has connected you to Rico Vale."
	elif story_race_active and story_stage == 5 and selected_event_id == "quarter_mile":
		story_stage = 6
		career_cash += 1000
		career_reputation += 10
		last_story_message = "MISSION COMPLETE: Viktor Kane is beaten. Rico pays $1,000 and puts you on the Pro Quarter-Mile card."
	elif story_race_active and story_stage == 6 and selected_event_id == "pro_quarter":
		story_stage = 7
		career_cash += 1800
		career_reputation += 15
		last_story_message = "MISSION COMPLETE: You beat Viktor in the rematch. Rico pays $1,800 and books the underground final."
	elif story_race_active and story_stage == 7 and selected_event_id == "half_mile":
		story_stage = 8
		career_cash += 3500
		career_reputation += 25
		story_completed = true
		last_story_message = "CHAPTER 2 COMPLETE: You defeated Viktor Kane and earned $3,500 plus 25 reputation. You are the Underground Circuit Champion."
	elif story_race_active and story_stage == 10 and selected_event_id == "pro_quarter":
		story_stage = 11
		professional_license = true
		career_cash += 2000
		career_reputation += 20
		last_story_message = "PRO LICENCE EARNED: The National Drag Association issues your professional licence. Championship registration is approved."
	elif story_race_active and story_stage >= 11 and story_stage <= 13:
		pro_championship_points += 1
		career_cash += 1500
		career_reputation += 15
		if story_stage == 13:
			story_stage = 14
			last_story_message = "CHAMPIONSHIP WON: Three professional round victories. You are the sanctioned series champion."
		else:
			story_stage += 1
			last_story_message = "PRO CHAMPIONSHIP ROUND WON: $1,500 and +15 reputation. Your next round is ready."
	else:
		return
	story_race_active = false
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
	professional_season_message = ""
	international_season_message = ""
	if race_countdown_active:
		return
	race_countdown_active = true
	section_panel.show()
	menu_panel.hide()
	race_panel.hide()
	if career_race:
		var event: Dictionary = _get_superstar_event() if superstar_championship_active else (_get_international_event() if international_championship_active else (_get_national_event() if national_championship_active else (_get_professional_event() if professional_circuit_active else _get_selected_event())))
		var entry_fee := int(event.get("entry_fee", _event_entry_fee(selected_event_id))) if (professional_circuit_active or national_championship_active or international_championship_active or superstar_championship_active) else _event_entry_fee(selected_event_id)
		if superstar_championship_active and not (superstar_pathway_unlocked and career_wins >= 60 and _driver_level() >= 20 and career_reputation >= 750):
			career_race = false
			superstar_championship_active = false
			race_countdown_active = false
			_show_superstar_pathway()
			return
		if international_championship_active and not (international_pathway_unlocked and career_wins >= 40 and _driver_level() >= 15 and career_reputation >= 500):
			career_race = false
			international_championship_active = false
			race_countdown_active = false
			_show_international_pathway()
			return
		if national_championship_active and not (national_pathway_unlocked and career_wins >= 25 and _driver_level() >= 10 and career_reputation >= 300):
			career_race = false
			national_championship_active = false
			race_countdown_active = false
			_show_national_pathway()
			return
		if professional_circuit_active and not professional_license:
			career_race = false
			professional_circuit_active = false
			race_countdown_active = false
			_show_career_dashboard()
			return
		if not professional_circuit_active and not national_championship_active and career_reputation < _event_min_reputation(selected_event_id):
			career_race = false
			story_race_active = false
			race_countdown_active = false
			status_label.text = "This event is locked. Build more reputation first."
			_show_event_selection()
			return
		if career_cash < entry_fee:
			career_race = false
			story_race_active = false
			race_countdown_active = false
			status_label.text = "You need $%s for this event's entry fee." % str(entry_fee)
			if superstar_championship_active:
				_show_superstar_championship()
			elif international_championship_active:
				_show_international_championship()
			elif national_championship_active:
				_show_national_championship()
			elif professional_circuit_active:
				_show_professional_circuit()
			else:
				_show_event_selection()
			return
		career_cash -= entry_fee
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
		if superstar_championship_active:
			rival_name = str(superstar_rival_names[(superstar_events_completed.size() + superstar_season_number - 1) % superstar_rival_names.size()])
		elif international_championship_active:
			rival_name = str(international_rival_names[(international_events_completed.size() + international_season_number - 1) % international_rival_names.size()])
		elif national_championship_active:
			rival_name = str(national_rival_names[(national_events_completed.size() + national_season_number - 1) % national_rival_names.size()])
		elif professional_circuit_active:
			rival_name = str(professional_rival_names[(professional_events_completed.size() + professional_season_number - 1) % professional_rival_names.size()])
		else:
			rival_name = ("Viktor Kane" if story_stage >= 5 and story_stage <= 7 else "Elena Cross") if story_race_active else (rival_challenge_name if rival_challenge_active else str(rival_names[(career_wins + career_losses) % rival_names.size()]))
		var selected_record: Dictionary = superstar_rival_records.get(rival_name, {}) if superstar_championship_active else (international_rival_records.get(rival_name, {}) if international_championship_active else (national_rival_records.get(rival_name, {}) if national_championship_active else (professional_rival_records.get(rival_name, {}) if professional_circuit_active else rival_records.get(rival_name, {}))))
		if superstar_championship_active and selected_record.is_empty():
			_ensure_superstar_rivals()
			selected_record = superstar_rival_records.get(rival_name,{})
		if international_championship_active and selected_record.is_empty():
			_ensure_international_rival_records()
			selected_record = international_rival_records.get(rival_name, {})
		if national_championship_active and selected_record.is_empty():
			_ensure_national_rival_records()
			selected_record = national_rival_records.get(rival_name, {})
		if professional_circuit_active and selected_record.is_empty():
			var pro_index := professional_rival_names.find(rival_name)
			selected_record = {"rating": 68 + pro_index * 5, "upgrade_level": pro_index + 2, "car": "Turbo Coupe" if pro_index < 2 else "Muscle V8"}
			professional_rival_records[rival_name] = selected_record
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
		var race_event_data: Dictionary = _get_superstar_event() if superstar_championship_active else (_get_international_event() if international_championship_active else (_get_national_event() if national_championship_active else (_get_professional_event() if professional_circuit_active else _get_selected_event())))
		rival_target_speed = float(race_event_data["rival_speed"]) + float(rival_rating - 50) * 0.22 + float(rival_upgrades) * 0.8 + car_speed_bonus
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
	var record_key := (selected_superstar_event_id if superstar_championship_active else (selected_international_event_id if international_championship_active else (selected_national_event_id if national_championship_active else (selected_professional_event_id if professional_circuit_active else selected_event_id)))) if career_race else "quick_402"
	last_race_record_key = record_key
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
		if superstar_championship_active:
			_update_superstar_rival_results(won)
			_update_superstar_season(won)
		elif international_championship_active:
			_update_international_rival_results(won)
			_update_international_season(won)
		elif national_championship_active:
			_update_national_rival_results(won)
			_update_national_season(won)
		elif professional_circuit_active:
			_update_professional_rival_results(won)
			_update_professional_season(won)
		else:
			_update_rival_career_results(won)
			_update_season_progress(won)
		_update_sponsor_contract(won)
		if won:
			career_wins += 1
			current_win_streak += 1
			best_win_streak = maxi(best_win_streak, current_win_streak)
			career_cash += race_reward
			lifetime_earnings += race_reward
			career_reputation += 10
			last_result = "Victory vs " + rival_name
			_check_career_tier_unlocks()
			_update_story_progress()
			_check_career_tier_unlocks()
		else:
			career_losses += 1
			current_win_streak = 0
			last_result = "Defeat vs " + rival_name
			if story_race_active:
				last_story_message = "Viktor Kane: Not tonight. Rico will give you another shot when you're ready."
				story_race_active = false
		_update_jasper_job_progress()
		_update_team_contract(won)
		_advance_career_month()
		_refresh_team_offers()
		if rival_challenge_active:
			if won:
				var challenge_bonus := 750 + career_reputation * 2
				career_cash += challenge_bonus
				career_reputation += 8
				_check_career_tier_unlocks()
				defeated_challenge_rivals.append(rival_challenge_name)
				_add_career_notification("RIVAL DEFEATED: %s. Bonus $%s and +8 reputation." % [rival_challenge_name, str(challenge_bonus)])
			else:
				_add_career_notification("RIVAL CHALLENGE LOST: %s wants another shot someday." % rival_challenge_name)
			rival_challenge_active = false
			rival_challenge_name = ""
		career_race = false
		story_race_active = false
		professional_circuit_active = false
		national_championship_active = false
		international_championship_active = false
		superstar_championship_active = false
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
	if was_career_race and last_team_race_message != "":
		_add_section_label(last_team_race_message)
	if was_career_race and last_jasper_job_message != "":
		_add_section_label(last_jasper_job_message)
	if was_career_race:
		if last_season_message != "":
			_add_section_label(last_season_message)
		if professional_season_message != "":
			_add_section_label(professional_season_message)
		if national_season_message != "":
			_add_section_label(national_season_message)
		if international_season_message != "":
			_add_section_label(international_season_message)
		if superstar_season_message != "":
			_add_section_label(superstar_season_message)
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
		var best := float(personal_bests.get(last_race_record_key, 0.0))
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
	career_inbox = save.get_value("career", "career_inbox", [])
	current_team = str(save.get_value("career", "current_team", ""))
	team_offers = save.get_value("career", "team_offers", [])
	team_invites_sent = save.get_value("career", "team_invites_sent", [])
	team_contract_active = bool(save.get_value("career", "team_contract_active", false))
	team_contract_races_left = int(save.get_value("career", "team_contract_races_left", 0))
	team_contract_races_completed = int(save.get_value("career", "team_contract_races_completed", 0))
	team_contract_wins = int(save.get_value("career", "team_contract_wins", 0))
	team_contract_win_target = int(save.get_value("career", "team_contract_win_target", 3))
	team_contract_reward = int(save.get_value("career", "team_contract_reward", 0))
	last_team_message = str(save.get_value("career", "last_team_message", ""))
	career_invites_sent = save.get_value("career", "career_invites_sent", [])
	defeated_challenge_rivals = save.get_value("career", "defeated_challenge_rivals", [])
	career_month = int(save.get_value("career", "career_month", 1))
	races_this_month = int(save.get_value("career", "races_this_month", 0))
	child_support_due = int(save.get_value("career", "child_support_due", 0))
	household_expenses_due = int(save.get_value("career", "household_expenses_due", 0))
	child_support_paid_total = int(save.get_value("career", "child_support_paid_total", 0))
	household_paid_total = int(save.get_value("career", "household_paid_total", 0))
	missed_payment_months = int(save.get_value("career", "missed_payment_months", 0))
	last_finance_message = str(save.get_value("career", "last_finance_message", ""))
	story_completed = bool(save.get_value("career", "story_completed", false))
	professional_license = bool(save.get_value("career", "professional_license", false))
	pro_championship_points = int(save.get_value("career", "pro_championship_points", 0))
	professional_season_number = int(save.get_value("career", "professional_season_number", 1))
	professional_season_points = save.get_value("career", "professional_season_points", {})
	professional_events_completed = save.get_value("career", "professional_events_completed", [])
	last_professional_points = save.get_value("career", "last_professional_points", {})
	last_professional_champion = str(save.get_value("career", "last_professional_champion", ""))
	last_professional_season_number = int(save.get_value("career", "last_professional_season_number", 0))
	professional_rival_records = save.get_value("career", "professional_rival_records", {})
	professional_team_points = save.get_value("career", "professional_team_points", {})
	last_professional_team_points = save.get_value("career", "last_professional_team_points", {})
	national_pathway_unlocked = bool(save.get_value("career", "national_pathway_unlocked", false))
	international_pathway_unlocked = bool(save.get_value("career", "international_pathway_unlocked", false))
	superstar_pathway_unlocked = bool(save.get_value("career", "superstar_pathway_unlocked", false))
	superstar_season_number = int(save.get_value("career", "superstar_season_number", 1))
	superstar_season_points = save.get_value("career", "superstar_season_points", {})
	superstar_events_completed = save.get_value("career", "superstar_events_completed", [])
	superstar_rival_records = save.get_value("career", "superstar_rival_records", {})
	last_superstar_points = save.get_value("career", "last_superstar_points", {})
	last_superstar_champion = str(save.get_value("career", "last_superstar_champion", ""))
	last_superstar_season_number = int(save.get_value("career", "last_superstar_season_number", 0))
	superstar_titles = int(save.get_value("career", "superstar_titles", 0))
	lifetime_earnings = int(save.get_value("career", "lifetime_earnings", 0))
	international_season_number = int(save.get_value("career", "international_season_number", 1))
	international_season_points = save.get_value("career", "international_season_points", {})
	international_events_completed = save.get_value("career", "international_events_completed", [])
	international_rival_records = save.get_value("career", "international_rival_records", {})
	international_team_points = save.get_value("career", "international_team_points", {})
	last_international_points = save.get_value("career", "last_international_points", {})
	last_international_team_points = save.get_value("career", "last_international_team_points", {})
	last_international_champion = str(save.get_value("career", "last_international_champion", ""))
	last_international_season_number = int(save.get_value("career", "last_international_season_number", 0))
	national_season_number = int(save.get_value("career", "national_season_number", 1))
	national_season_points = save.get_value("career", "national_season_points", {})
	national_events_completed = save.get_value("career", "national_events_completed", [])
	national_rival_records = save.get_value("career", "national_rival_records", {})
	national_team_points = save.get_value("career", "national_team_points", {})
	last_national_points = save.get_value("career", "last_national_points", {})
	last_national_team_points = save.get_value("career", "last_national_team_points", {})
	last_national_champion = str(save.get_value("career", "last_national_champion", ""))
	last_national_season_number = int(save.get_value("career", "last_national_season_number", 0))
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
	save.set_value("career", "career_inbox", career_inbox)
	save.set_value("career", "current_team", current_team)
	save.set_value("career", "team_offers", team_offers)
	save.set_value("career", "team_invites_sent", team_invites_sent)
	save.set_value("career", "team_contract_active", team_contract_active)
	save.set_value("career", "team_contract_races_left", team_contract_races_left)
	save.set_value("career", "team_contract_races_completed", team_contract_races_completed)
	save.set_value("career", "team_contract_wins", team_contract_wins)
	save.set_value("career", "team_contract_win_target", team_contract_win_target)
	save.set_value("career", "team_contract_reward", team_contract_reward)
	save.set_value("career", "last_team_message", last_team_message)
	save.set_value("career", "career_invites_sent", career_invites_sent)
	save.set_value("career", "defeated_challenge_rivals", defeated_challenge_rivals)
	save.set_value("career", "career_month", career_month)
	save.set_value("career", "races_this_month", races_this_month)
	save.set_value("career", "child_support_due", child_support_due)
	save.set_value("career", "household_expenses_due", household_expenses_due)
	save.set_value("career", "child_support_paid_total", child_support_paid_total)
	save.set_value("career", "household_paid_total", household_paid_total)
	save.set_value("career", "missed_payment_months", missed_payment_months)
	save.set_value("career", "last_finance_message", last_finance_message)
	save.set_value("career", "story_completed", story_completed)
	save.set_value("career", "professional_license", professional_license)
	save.set_value("career", "pro_championship_points", pro_championship_points)
	save.set_value("career", "professional_season_number", professional_season_number)
	save.set_value("career", "professional_season_points", professional_season_points)
	save.set_value("career", "professional_events_completed", professional_events_completed)
	save.set_value("career", "last_professional_points", last_professional_points)
	save.set_value("career", "last_professional_champion", last_professional_champion)
	save.set_value("career", "last_professional_season_number", last_professional_season_number)
	save.set_value("career", "professional_rival_records", professional_rival_records)
	save.set_value("career", "professional_team_points", professional_team_points)
	save.set_value("career", "last_professional_team_points", last_professional_team_points)
	save.set_value("career", "national_pathway_unlocked", national_pathway_unlocked)
	save.set_value("career", "international_pathway_unlocked", international_pathway_unlocked)
	save.set_value("career", "superstar_pathway_unlocked", superstar_pathway_unlocked)
	save.set_value("career", "superstar_season_number", superstar_season_number)
	save.set_value("career", "superstar_season_points", superstar_season_points)
	save.set_value("career", "superstar_events_completed", superstar_events_completed)
	save.set_value("career", "superstar_rival_records", superstar_rival_records)
	save.set_value("career", "last_superstar_points", last_superstar_points)
	save.set_value("career", "last_superstar_champion", last_superstar_champion)
	save.set_value("career", "last_superstar_season_number", last_superstar_season_number)
	save.set_value("career", "superstar_titles", superstar_titles)
	save.set_value("career", "lifetime_earnings", lifetime_earnings)
	save.set_value("career", "international_season_number", international_season_number)
	save.set_value("career", "international_season_points", international_season_points)
	save.set_value("career", "international_events_completed", international_events_completed)
	save.set_value("career", "international_rival_records", international_rival_records)
	save.set_value("career", "international_team_points", international_team_points)
	save.set_value("career", "last_international_points", last_international_points)
	save.set_value("career", "last_international_team_points", last_international_team_points)
	save.set_value("career", "last_international_champion", last_international_champion)
	save.set_value("career", "last_international_season_number", last_international_season_number)
	save.set_value("career", "national_season_number", national_season_number)
	save.set_value("career", "national_season_points", national_season_points)
	save.set_value("career", "national_events_completed", national_events_completed)
	save.set_value("career", "national_rival_records", national_rival_records)
	save.set_value("career", "national_team_points", national_team_points)
	save.set_value("career", "last_national_points", last_national_points)
	save.set_value("career", "last_national_team_points", last_national_team_points)
	save.set_value("career", "last_national_champion", last_national_champion)
	save.set_value("career", "last_national_season_number", last_national_season_number)
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
