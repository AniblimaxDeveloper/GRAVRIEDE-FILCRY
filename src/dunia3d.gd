extends Node3D

func _ready():
print("GAME DIMULAI")

# 1. Kamera
var kamera = Camera3D.new()
kamera.position = Vector3(0, 0, 5)
kamera.current = true
add_child(kamera)

# 2. Cahaya
var cahaya = DirectionalLight3D.new()
cahaya.rotation_degrees = Vector3(-45, 0, 0)
add_child(cahaya)

# 3. Kotak Biru
var kotak = MeshInstance3D.new()
kotak.mesh = BoxMesh.new()
var mat = StandardMaterial3D.new()
mat.albedo_color = Color.BLUE
kotak.material_override = mat
add_child(kotak)

# 4. Teks UI
var ui = CanvasLayer.new()
add_child(ui)
var label = Label.new()
label.text = "GAME BERHASIL DIMUAT!\n(Kotak Biru 3D)"
label.position = Vector2(50, 50)
label.add_theme_font_size_override("font_size", 30)
ui.add_child(label)
