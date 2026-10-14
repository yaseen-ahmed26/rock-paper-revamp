extends Control


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)

func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")
