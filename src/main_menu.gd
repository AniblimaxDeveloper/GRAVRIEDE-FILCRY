extends Control

func _ready():
# Membuat label teks secara manual lewat kode
var label = Label.new()
label.text = "GRAVRIEDE FILCRY\n(APK Test Build)"
label.add_theme_font_size_override("font_size", 50)
label.set_anchors_preset(Control.PRESET_CENTER)
add_child(label)
