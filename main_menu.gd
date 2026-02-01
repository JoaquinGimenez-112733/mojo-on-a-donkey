extends Control
@onready var sprite_2d: Sprite2D = $ParallaxBackground/ParallaxLayer/Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_music(preload("res://Assets/Songs/TIKI_MUS_MainMenu_Loop.mp3"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite_2d.region_rect.position += delta * Vector2(15,15)

func _on_play_pressed() -> void:
	MusicManager.play_music(preload("res://Assets/Songs/TIKI_MUS_Gameplay_Loop.mp3"))
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")



func _on_créditos_pressed() -> void:
	pass # Replace with function body. 


func _on_salir_pressed() -> void:
	get_tree().quit()
