extends Control
@onready var coins_label: Label = $CoinsLabel
@onready var healt_label: Label = $HealtLabel


func set_text_label(new_text : int):
	coins_label.text = str(new_text)

func set_healt_label(new_text : int):
	healt_label.text = str(new_text)
