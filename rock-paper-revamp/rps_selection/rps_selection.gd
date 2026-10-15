extends Control
#extends Control
#
#@onready var overlay: ColorRect = $Overlay
#
#
#
#var selected_computer_btn: Button
##
#var current_overlay: Panel
##
## Godot
#func _ready() -> void:
	#$Tokens.text = "Tokens: " + str(int(SaveManager.local_saved_data.get("tokens")))		

	#for computer in ContentManager.computers.values():
		#_create_btn(
			#computer,
			#$Opponents/Holder,
			#$Opponents/Holder/TemplateButton,
			#_on_computer_btn_pressed
		#)
		
#
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and not event.echo:
		#match event.keycode:
			#KEY_ESCAPE:
				#if current_overlay and overlay.visible:				
					#_on_close_overlay_pressed()

## General Helpers
#func _create_btn(info, parent, template_btn, press_connection):
	#var clone: Button = template_btn.duplicate(true)
	#parent.add_child(clone)
	#
	#clone.name = info.display_name.to_lower()
	#clone.text = info.display_name
	#clone.visible = true
	#clone.tooltip_text = info.description
	#
	#var resource_duplicate = info.duplicate(true)
	#clone.set_meta("Resource", resource_duplicate)
	#
		#
	#clone.pressed.connect(press_connection.bind(clone))
#
#
## Button & Signal Connections

#
#func _on_computer_btn_pressed(btn: Button):
	#if selected_computer_btn:
		#var old_selected = selected_computer_btn.get_node("SelectedLabel")
		#if old_selected: old_selected.visible = false
		#
	#var selected = btn.get_node("SelectedLabel")
	#if selected: selected.visible = true
	#
	#selected_computer_btn = btn
	#
	#if selected_computer_btn and selected_gamemode:
		#$StartButton.disabled = false
	#else:
		#$StartButton.disabled = true
	#
	#var resource: ComputerBase = btn.get_meta("Resource")
	#$Computers/Description.text = "[color=gold]%s: [color=white]%s" % [resource.display_name, resource.description]
#
#func _on_return_btn_pressed() -> void:
	#Signals.change_screen.emit("main_menu")
#
#func _on_start_btn_pressed() -> void:
	#var modifier_resources: Array[ModifierBase] = []
	#
	#for btn: Button in selected_modifier_btns:
		#modifier_resources.append(btn.get_meta("Resource"))
	#
	#modifier_resources.sort_custom(func(a, b): return a.group < b.group)
	#
	#Signals.change_screen.emit(
		#"rps_game",
		#{
			#"gamemode_resource": selected_gamemode,
			#"modifier_resource": modifier_resources,
			#"computer_resource": selected_computer_btn.get_meta("Resource"),
		#}
	#)
#
	#
#func _on_pick_random_btn_pressed():
	#_show_overlay($Overlay/Tokens)
#
#func _on_close_overlay_pressed() -> void:
	#var old_btns: Array[Node] = current_overlay.find_children("*", "Button", true, false)
		#
	#for btn: Button in old_btns:
		#btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#
	#var tween: Tween = create_tween()
	#tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	#await tween.finished
	#overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#$Overlay/CloseOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

#
#func on_screen_change(_args):
	#$Tokens.text = "Tokens: " + str(int(SaveManager.local_saved_data.get("tokens")))
		#
	#var all_descendants: Array[Node] = $Modifiers/ScrollContainer/Holder.find_children("*", "Button", true, false)
	#
	#for child in all_descendants:
		#if child.name == "TemplateButton": continue
		#if child.name == "BuyButton": continue
		#
		#var modifier: ModifierBase = child.get_meta("Resource")
		#
		#if not modifier.challenge_required: continue
#
		#var completed_challenges: Array = SaveManager.local_saved_data.get("completed_challenges", [])
		#
		#if modifier.challenge_id in completed_challenges:
			#child.text = modifier.display_name
			#child.get_node("Locked").visible = false
			#child.set_meta("Locked", false)
#
#func _show_overlay(screen: Panel):
	#if current_overlay:
		#current_overlay.visible = false
		#
		#var old_btns: Array[Node] = current_overlay.find_children("*", "Button", true, false)
		#
		#for btn: Button in old_btns:
			#btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#
	#current_overlay = screen
	#screen.visible = true
	#
	#var all_descendants: Array[Node] = screen.find_children("*", "Button", true, false)
	#
	#for btn in all_descendants:
		#btn.mouse_filter = Control.MOUSE_FILTER_STOP
	#
	#var tween: Tween = create_tween()
	#tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
	#await tween.finished
	#overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	#$Overlay/CloseOverlay.mouse_filter = Control.MOUSE_FILTER_STOP
#
#
