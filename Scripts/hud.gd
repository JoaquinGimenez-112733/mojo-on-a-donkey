extends Control
@onready var coins_label: Label = $CoinsLabel


func set_text_label(new_text : int):
	coins_label.text = str(new_text)
