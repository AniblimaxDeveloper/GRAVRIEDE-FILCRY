extends Node3D

func _ready():
# 1. Kamera
var camera = Camera3D.new()
camera.position = Vector3(0, 0, 5)
camera.current = true
add_child(camera)

# 2. Cahaya
var light = DirectionalLight3D.new()
light.rotation_degrees = Vector3(-45, 0, 0)
add_child(light)

# 3. Kotak Putih
var box = MeshInstance3D.new()
box.mesh = BoxMesh.new()
var mat = StandardMaterial3D.new()
mat.albedo_color = Color.WHITE
box.material_override = mat
add_child(box)

# 4. Teks
var ui = CanvasLayer.new()
add_child(ui)
var label = Label.new()
label.text = "HALO GRAVRIEDE!"
label.position = Vector2(100, 100)
label.add_theme_font_size_override("font_size", 40)
ui.add_child(label)
