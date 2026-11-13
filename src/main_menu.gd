extends Control

func _ready():
# Background Hitam
var bg = ColorRect.new()
bg.color = Color(0, 0, 0, 1)
bg.set_anchors_preset(Control.PRESET_FULL_RECT)
add_child(bg)

# Judul Game
var judul = Label.new()
judul.text = "GRAVRIEDE FILCRY"
judul.add_theme_font_size_override("font_size", 50)
judul.add_theme_color_override("font_color", Color(1, 0, 0)) # Merah
judul.set_anchors_preset(Control.PRESET_CENTER_TOP)
judul.position.y = 100
judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
judul.size.x = get_viewport().size.x
add_child(judul)

# Tombol Mulai
var btn_mulai = Button.new()
btn_mulai.text = "MULAI GAME"
btn_mulai.add_theme_font_size_override("font_size", 30)
btn_mulai.size = Vector2(250, 80)
btn_mulai.position = Vector2((get_viewport().size.x - 250) / 2, get_viewport().size.y / 2)
btn_mulai.pressed.connect(_on_mulai_pressed)
add_child(btn_mulai)

func _on_mulai_pressed():
get_tree().change_scene_to_file("res://src/dunia3d.tscn")
