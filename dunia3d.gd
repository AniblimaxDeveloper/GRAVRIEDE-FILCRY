extends Node3D

func _ready():
# 1. Membuat Lantai 3D
var lantai = MeshInstance3D.new()
var mesh_lantai = PlaneMesh.new()
mesh_lantai.size = Vector2(100, 100)
lantai.mesh = mesh_lantai
add_child(lantai)

# 2. Membuat "Monster" (Kotak Merah 3D)
var monster = MeshInstance3D.new()
var mesh_monster = BoxMesh.new()
mesh_monster.size = Vector3(2, 3, 2)
monster.mesh = mesh_monster
monster.position = Vector3(0, 1.5, -10) # Posisi di depan pemain

var material = StandardMaterial3D.new()
material.albedo_color = Color(1, 0, 0) # Warna Merah
monster.material_override = material
add_child(monster)

# 3. Membuat Kamera (Sudut Pandang Pemain)
var kamera = Camera3D.new()
kamera.position = Vector3(0, 2, 5) # Posisi kamera
kamera.current = true # Jadikan kamera utama
add_child(kamera)

# 4. Membuat Cahaya (Matahari)
var cahaya = DirectionalLight3D.new()
cahaya.rotation_degrees = Vector3(-45, -30, 0)
add_child(cahaya)
