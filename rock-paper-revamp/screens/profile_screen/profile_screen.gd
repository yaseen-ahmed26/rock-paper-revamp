extends Control

const TAB_BTN_SELECTED = preload("res://screens/settings_screen/ui_resources/tab_selected_btn.tres")
const TAB_BTN_NORMAL = preload("res://screens/settings_screen/ui_resources/tab_normal_btn.tres")

# Tabs
@onready var tab_btns: HBoxContainer = $TopBar/Tabs
@onready var career_view: Control = $Career
@onready var ach_view: Control = $Achievements

@onready var holder: VBoxContainer = $Achievements/List/ScrollContainer/Holder
@onready var template_static: Panel = $Achievements/List/ScrollContainer/Holder/TemplateStatic
@onready var template_completed: Panel = $Achievements/List/ScrollContainer/Holder/TemplateCompleted
@onready var completed_heading: RichTextLabel = $Achievements/List/ScrollContainer/Holder/Completed
@onready var search_bar: LineEdit = $Achievements/Filters/SearchBar
@onready var filter_holder: HBoxContainer = $Achievements/Filters/Holder
@onready var info_banner_label: RichTextLabel = $InformationBanner/Label

var current_filter: Button
var current_search: String = ""

var current_tab: Button

func _ready() -> void:
	$ReturnButton.pressed.connect(func(): Signals.change_screen.emit("main_menu"))

	for btn in tab_btns.get_children():
		btn.pressed.connect(_change_tab.bind(btn))
	
	for btn in filter_holder.get_children():
		btn.pressed.connect(_on_filter_pressed.bind(btn.name.to_upper()))

	search_bar.text_changed.connect(_on_search_changed)

	current_tab = $TopBar/Tabs/Career
	current_filter = $Achievements/Filters/Holder/All

	on_screen_change({})
	
func _change_tab(btn: Button):
	if current_tab:
		var old_tab: Control = get_node(str(current_tab.name))
		
		if old_tab:
			old_tab.visible = false
			current_tab.add_theme_stylebox_override("normal", TAB_BTN_NORMAL)
			
	var new_tab: Control = get_node(str(btn.name))
	
	if new_tab:
		new_tab.visible = true
		btn.add_theme_stylebox_override("normal", TAB_BTN_SELECTED)
		current_tab = btn
		
		match btn.name:
			"Career": _update_career_tab()
			"Achievements": _update_achievements_tab()
		
func on_screen_change(_args):
	_update_career_tab()
	_update_achievements_tab()

func _on_filter_pressed(btn: Button):
	if current_filter:
		current_filter.add_theme_stylebox_override("normal", TAB_BTN_NORMAL)

	btn.add_theme_stylebox_override("normal", TAB_BTN_SELECTED)
	current_tab = btn
	
	_update_achievements_tab()

func _on_search_changed(new_text: String) -> void:
	current_search = new_text.strip_edges().to_lower()
	_update_achievements_tab()

func _matches_filter(achievement: AchievementBase) -> bool:
	match current_filter.name:
		"Modifiers":
			return achievement.stat_key == &"modifiers"
		"Gamemodes":
			return achievement.stat_key == &"gamemodes"
		"opponents":
			return achievement.stat_key == &"opponents"
		"suits":
			return achievement.stat_key.begins_with("played_")
		_:
			return true

func _update_achievements_tab() -> void:
	var save_data = SaveManager.local_saved_data
	
	for child in holder.get_children():
		if child == template_static: continue
		if child == template_completed: continue 
		if child == completed_heading: continue
		
		child.queue_free()

	var in_progress_list: Array[AchievementBase] = []
	var completed_list: Array[AchievementBase] = []

	var achievements = ContentManager.achievements.values()
	var total_completed_count: int = 0

	for achievement: AchievementBase in achievements:
		var completed: bool = achievement.is_completed(save_data)
		
		if completed: total_completed_count += 1

		if not _matches_filter(achievement): continue
		
		if not current_search.is_empty():
			var title_match = current_search in achievement.display_name.to_lower()
			
			if not title_match: continue

		if completed:
			completed_list.append(achievement)
		else:
			in_progress_list.append(achievement)

	info_banner_label.text = "[color=#94a3b8]COMPLETED:[/color] [color=#34d399]%d / %d[/color]" % [total_completed_count, achievements.size()]

	var insert_index = completed_heading.get_index()
	
	for achievement in in_progress_list:
		var card = _create_in_progress_card(achievement, save_data)
		
		holder.add_child(card)
		holder.move_child(card, insert_index)
		
		insert_index += 1

	completed_heading.text = "[color=#34d399]COMPLETED ACHIEVEMENTS[/color]  [color=#64748b](%d)[/color]" % completed_list.size()
	completed_heading.visible = not completed_list.is_empty()

	for achievement in completed_list:
		var card = _create_completed_card(achievement, save_data)
		
		holder.add_child(card)

func _create_in_progress_card(achievement: AchievementBase, save_data: Dictionary):
	var card: Panel = template_static.duplicate(true)
	card.visible = true

	var current_progress = achievement.get_progress(save_data)
	var current_tier = achievement.get_current_tier(current_progress)
	var target_value = achievement.get_active_target(current_tier)

	card.get_node("Title").text = achievement.display_name.to_upper()
	card.get_node("Step/Label").text = achievement.get_stars_bbcode(current_tier)
	
	if achievement.icon:
		card.get_node("Icon").texture = achievement.icon

	#if "%d" in desc_text:
		#desc_text = desc_text % target_val
	
	# card.get_node("Description").text = "[color=#cbd5e1]TASK: %s[/color]" % desc_text
	
	card.get_node("ProgressBar").max_value = target_value
	card.get_node("ProgressBar").value = current_progress

	var pct: int = int((float(current_progress) / float(maxi(target_value, 1))) * 100.0)
	card.get_node("ProgressCounter").text = "[color=#c084fc]%d / %d[/color] [color=#94a3b8](%d%%)[/color]" % [current_progress, target_value, pct]

	card.get_node("Reward").visible = false

	return card

func _create_completed_card(achievement: AchievementBase, _save_data: Dictionary):
	var card: Panel = template_completed.duplicate(true)
	card.visible = true

	var final_target = achievement.thresholds.back() if not achievement.thresholds.is_empty() else 1

	card.get_node("Title").text = "[color=#cbd5e1]%s[/color]" % achievement.display_name.to_upper()
	
	if achievement.icon:
		card.get_node("Icon").texture = achievement.icon

	#var desc_text = ach.description
	#if "%d" in desc_text:
		#desc_text = desc_text % final_target
	#card.get_node("Description").text = "[color=#94a3b8]TASK: %s[/color]" % desc_text

	card.get_node("ProgressBar").max_value = final_target
	card.get_node("ProgressBar").value = final_target

	card.get_node("ProgressCounter").text = "[color=#34d399]%d / %d (100%%)[/color]" % [final_target, final_target]
	card.get_node("Reward").visible = false

	return card

func _update_career_tab():
	var s = SaveManager.local_saved_data
	
	$Career/Matches/Wins/Label.text = "[center][color=#94a3b8]WINS[/color]\n[font_size=28][color=#34d399]%d[/color][/font_size][/center]" % s.get("total_wins", 0)
	$Career/Matches/Losses/Label.text = "[center][color=#94a3b8]LOSSES[/color]\n[font_size=28][color=#f87171]%d[/color][/font_size][/center]" % s.get("total_losses", 0)
	$Career/Matches/Draws/Label.text = "[center][color=#94a3b8]DRAWS[/color]\n[font_size=28][color=#c084fc]%d[/color][/font_size][/center]" % s.get("total_draws", 0)
	
	var p_won = s.get("points_won", 0)
	var p_lost = s.get("points_lost", 0)
	$Career/Matches/PointsBox/Points.text = "[color=#94a3b8]BANK[/color]\n[font_size=20]Won [color=#facc15]%d[/color]  •  [color=#94a3b8]%d[/color] Lost[/font_size]" % [p_won, p_lost]
	$Career/Matches/PointsBox/PointsRatioBar.max_value = maxi(p_won + p_lost, 1)
	$Career/Matches/PointsBox/PointsRatioBar.value = p_won

	$Career/Matches/RoundsPlayed/Label.text = "[color=#94a3b8]ROUNDS PLAYED[/color]\n[font_size=22][color=#ffffff]%d[/color][/font_size]" % s.get("rounds_played", 0)
	$Career/Matches/MatchesPlayed/Label.text = "[color=#94a3b8]MATCHES PLAYED[/color]\n[font_size=22][color=#ffffff]%d[/color][/font_size]" % s.get("matches_played", 0)

	$Career/Matches/Moves/Rock/Label.text = "[right][color=#c084fc]%d times[/color][/right]" % s.get("played_rock", 0)
	$Career/Matches/Moves/Paper/Label.text = "[right][color=#c084fc]%d times[/color][/right]" % s.get("played_paper", 0)
	$Career/Matches/Moves/Scissors/Label.text = "[right][color=#c084fc]%d times[/color][/right]" % s.get("played_scissors", 0)
	$Career/Matches/Moves/Lizard/Label.text = "[right][color=#c084fc]%d times[/color][/right]" % s.get("played_lizard", 0)
	$Career/Matches/Moves/Spock/Label.text = "[right][color=#c084fc]%d times[/color][/right]" % s.get("played_spock", 0)
