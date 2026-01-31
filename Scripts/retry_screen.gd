extends Control


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_reintentar_pressed() -> void:
	get_tree().reload_current_scene()
