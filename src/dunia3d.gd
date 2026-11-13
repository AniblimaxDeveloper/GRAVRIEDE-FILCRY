extends Node3D

var rotation_x = 0.0
var rotation_y = 0.0
var player = null
var camera = null
var senter = null
var monster = null
var objek_kunci = null
var is_walking = false
var tap_count = 0

# UI & Sanity
var ui_sanity = null
var sanity = 100.0
var is_game_over = false

func _ready():
# 1. Membangun Map (Labirin Sederhana)
_buat_lantai()
_buat_dinding()

# 2. Membuat Player
player = CharacterBody3D.new()
player.position = Vector3(0, 1.5, 5)
var col_player = CollisionShape3D.new()
var shape_player = CapsuleShape3D.new()
col_player.shape = shape_player
player.add_child(col_player)
add_child(player)

# 3. Kamera & Senter Player
camera = Camera3D.new()
camera.current = true
player.add_child(camera)

senter = SpotLight3D.new()
senter.light_energy = 2.0
senter.spot_range = 20.0
senter.visible = false 
camera.add_child(senter)

# 4. Monster
monster = CharacterBody3D.new()
monster.position = Vector3(0, 1, -15)
var col_monster = CollisionShape3D.new()
col_monster.shape = CapsuleShape3D.new()
monster.add_child(col_monster)

var mesh_monster = MeshInstance3D.new()
var box_mesh = BoxMesh.new()
box_mesh.size = Vector3(1, 2, 1)
mesh_monster.mesh = box_mesh
var mat_monster = StandardMaterial3D.new()
mat_monster.albedo_color = Color(0.8, 0, 0) # Merah Darah
mesh_monster.material_override = mat_monster
monster.add_child(mesh_monster)
add_child(monster)

# 5. Objek Kunci (Kubus Biru)
objek_kunci = MeshInstance3D.new()
var mesh_kunci = BoxMesh.new()
mesh_kunci.size = Vector3(0.5, 0.5, 0.5)
objek_kunci.mesh = mesh_kunci
objek_kunci.position = Vector3(15, 1, -20) # Sembunyikan di pojok map
var mat_kunci = StandardMaterial3D.new()
mat_kunci.albedo_color = Color(0, 0.5, 1) # Biru
mat_kunci.emission_enabled = true
mat_kunci.emission = Color(0, 0.5, 1)
objek_kunci.material_override = mat_kunci
add_child(objek_kunci)

# 6. Cahaya Lingkungan (Gelap)
var cahaya = DirectionalLight3D.new()
cahaya.rotation_degrees = Vector3(-45, -30, 0)
cahaya.light_energy = 0.15
add_child(cahaya)

# 7. Setup UI (Sanity & Objektif)
var ui_layer = CanvasLayer.new()
add_child(ui_layer)

ui_sanity = Label.new()
ui_sanity.text = "Sanity: 100%"
ui_sanity.position = Vector2(20, 20)
ui_sanity.add_theme_font_size_override("font_size", 24)
ui_layer.add_child(ui_sanity)

var ui_obj = Label.new()
ui_obj.text = "Objektif: Temukan Kubus Biru"
ui_obj.position = Vector2(20, 60)
ui_obj.add_theme_font_size_override("font_size", 18)
ui_layer.add_child(ui_obj)

# --- Fungsi Pembuat Map ---
func _buat_lantai():
var lantai = MeshInstance3D.new()
var mesh_lantai = PlaneMesh.new()
mesh_lantai.size = Vector2(100, 100)
lantai.mesh = mesh_lantai
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(0.1, 0.1, 0.1) # Lantai gelap
lantai.material_override = mat
add_child(lantai)

func _buat_dinding():
# Membuat dinding kotak-kotak di sekitar map
var posisi_dinding = [
Vector3(0, 2, -25), Vector3(10, 2, -25), Vector3(-10, 2, -25),
Vector3(20, 2, -10), Vector3(-20, 2, -10),
Vector3(5, 2, -10), Vector3(-5, 2, -10),
Vector3(15, 2, 0), Vector3(-15, 2, 0)
]

for pos in posisi_dinding:
var dinding = StaticBody3D.new()
dinding.position = pos

var col = CollisionShape3D.new()
var shape = BoxShape3D.new()
shape.size = Vector3(4, 4, 4)
col.shape = shape
dinding.add_child(col)

var mesh = MeshInstance3D.new()
var box = BoxMesh.new()
box.size = Vector3(4, 4, 4)
mesh.mesh = box
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(0.3, 0.3, 0.3) # Warna beton
mesh.material_override = mat
dinding.add_child(mesh)

add_child(dinding)

# --- Kontrol & Logika ---
func _input(event):
if is_game_over: return

if event is InputEventScreenDrag:
rotation_y -= event.relative.x * 0.005
rotation_x -= event.relative.y * 0.005
rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
player.rotation = Vector3(0, rotation_y, 0)
camera.rotation = Vector3(rotation_x, 0, 0)

elif event is InputEventScreenTouch:
if event.pressed:
is_walking = true
tap_count += 1
if tap_count == 2:
senter.visible = not senter.visible
tap_count = 0
else:
is_walking = false

func _process(delta):
if is_game_over: return

if tap_count > 0 and not is_walking:
tap_count = 0

# Player Jalan
if is_walking:
var speed = 4.0
var arah_maju = player.transform.basis.z 
player.velocity.x = -arah_maju.x * speed
player.velocity.z = -arah_maju.z * speed
else:
player.velocity = Vector3.ZERO

player.move_and_slide()

# Logika Sanity Menurun
sanity -= 2.0 * delta
if ui_sanity:
ui_sanity.text = "Sanity: " + str(int(sanity)) + "%"

if sanity <= 0:
_game_over("Kamu Gila karena Ketakutan!")

# --- AI Monster ---
var jarak_ke_player = monster.position.distance_to(player.position)
var arah_ke_player = (player.position - monster.position).normalized()
var arah_ke_player_flat = Vector3(arah_ke_player.x, 0, arah_ke_player.z).normalized()

if jarak_ke_player < 15.0: # Jika dekat, kejar!
monster.velocity = arah_ke_player_flat * 4.5 # Kecepatan ngejar
monster.look_at(Vector3(player.position.x, monster.position.y, player.position.z), Vector3.UP)
else:
# Patroli malas (jalan acak)
monster.velocity = Vector3(randf_range(-1,1), 0, randf_range(-1,1)) * 1.0

monster.move_and_slide()

# Cek Tabrakan Monster vs Player
if jarak_ke_player < 1.5:
_game_over("Kamu Tertangkap Monster!")

# Cek Ambil Kunci
if objek_kunci and player.position.distance_to(objek_kunci.position) < 2.0:
objek_kunci.queue_free()
objek_kunci = null
_menang()

func _game_over(pesan):
is_game_over = true
print("GAME OVER: ", pesan)
if ui_sanity:
ui_sanity.text = "GAME OVER\n" + pesan + "\n\nRestarting..."
await get_tree().create_timer(3.0).timeout
get_tree().reload_current_scene()

func _menang():
is_game_over = true
print("KAMU MENANG!")
if ui_sanity:
ui_sanity.text = "SELAMAT!\nKamu Menemukan Kunci dan Kabur!\n\nRestarting..."
await get_tree().create_timer(4.0).timeout
get_tree().reload_current_scene()
