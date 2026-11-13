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

# UI & Survival
var ui_status = null
var ui_objektif = null
var ui_jumpscare = null
var sanity = 100.0
var baterai = 100.0
var is_game_over = false
var is_chased = false

func _ready():
# 1. Lingkungan & Kabut (Fog)
var env = Environment.new()
env.background_mode = Environment.BG_COLOR
env.background_color = Color(0, 0, 0) # Hitam pekat
env.fog_enabled = true
env.fog_density = 0.05 # Kabut tebal
env.fog_light_color = Color(0.1, 0.1, 0.1)
var world_env = WorldEnvironment.new()
world_env.environment = env
add_child(world_env)

# 2. Membangun Map
_buat_lantai()
_buat_dinding()

# 3. Player
player = CharacterBody3D.new()
player.position = Vector3(0, 1.5, 5)
var col_player = CollisionShape3D.new()
col_player.shape = CapsuleShape3D.new()
player.add_child(col_player)
add_child(player)

# 4. Kamera & Senter
camera = Camera3D.new()
camera.current = true
player.add_child(camera)

senter = SpotLight3D.new()
senter.light_energy = 3.0
senter.spot_range = 15.0
senter.spot_angle = 30.0
senter.visible = false 
camera.add_child(senter)

# 5. Monster (Kotak Merah)
monster = CharacterBody3D.new()
monster.position = Vector3(0, 1, -20)
var col_monster = CollisionShape3D.new()
col_monster.shape = CapsuleShape3D.new()
monster.add_child(col_monster)

var mesh_monster = MeshInstance3D.new()
var box_mesh = BoxMesh.new()
box_mesh.size = Vector3(1, 2, 1)
mesh_monster.mesh = box_mesh
var mat_monster = StandardMaterial3D.new()
mat_monster.albedo_color = Color(0.8, 0, 0)
mesh_monster.material_override = mat_monster
monster.add_child(mesh_monster)
add_child(monster)

# 6. Objek Kunci (Kubus Biru)
objek_kunci = _buat_item(Vector3(15, 1, -20), Color(0, 0.5, 1)) # Kunci

# 7. Item Baterai (Kotak Hijau)
_buat_item(Vector3(-10, 1, -5), Color(0, 1, 0))
_buat_item(Vector3(10, 1, -15), Color(0, 1, 0))
_buat_item(Vector3(-15, 1, -20), Color(0, 1, 0))

# 8. Cahaya Lingkungan (Sangat Redup)
var cahaya = DirectionalLight3D.new()
cahaya.rotation_degrees = Vector3(-45, -30, 0)
cahaya.light_energy = 0.05
add_child(cahaya)

# 9. Setup UI
_setup_ui()

func _setup_ui():
var ui_layer = CanvasLayer.new()
add_child(ui_layer)

ui_status = Label.new()
ui_status.text = "Sanity: 100% | Baterai: 100%"
ui_status.position = Vector2(20, 20)
ui_status.add_theme_font_size_override("font_size", 20)
ui_layer.add_child(ui_status)

ui_objektif = Label.new()
ui_objektif.text = "Cari Kunci Biru. Ambil Baterai Hijau."
ui_objektif.position = Vector2(20, 50)
ui_objektif.add_theme_font_size_override("font_size", 16)
ui_layer.add_child(ui_objektif)

# Efek Jumpscare (Layar Merah Darah)
ui_jumpscare = ColorRect.new()
ui_jumpscare.color = Color(1, 0, 0, 0) # Transparan
ui_jumpscare.set_anchors_preset(Control.PRESET_FULL_RECT)
ui_layer.add_child(ui_jumpscare)

func _buat_item(pos, warna):
var item = MeshInstance3D.new()
var mesh = BoxMesh.new()
mesh.size = Vector3(0.5, 0.5, 0.5)
item.mesh = mesh
item.position = pos
var mat = StandardMaterial3D.new()
mat.albedo_color = warna
mat.emission_enabled = true
mat.emission = warna
item.material_override = mat
add_child(item)
return item

func _buat_lantai():
var lantai = MeshInstance3D.new()
var mesh_lantai = PlaneMesh.new()
mesh_lantai.size = Vector2(100, 100)
lantai.mesh = mesh_lantai
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(0.1, 0.1, 0.1)
lantai.material_override = mat
add_child(lantai)

func _buat_dinding():
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
mat.albedo_color = Color(0.3, 0.3, 0.3)
mesh.material_override = mat
dinding.add_child(mesh)
add_child(dinding)

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

# --- LOGIKA BATERAI ---
if senter.visible:
baterai -= 3.0 * delta # Baterai berkurang 3% per detik
if baterai <= 0:
baterai = 0
senter.visible = false # Senter mati otomatis

# --- LOGIKA SANITY ---
# Sanity menurun cepat kalau gelap, menurun lambat kalau senter nyala
if senter.visible:
sanity -= 0.5 * delta
else:
sanity -= 3.0 * delta 

# Update UI
ui_status.text = "Sanity: " + str(int(sanity)) + "% | Baterai: " + str(int(baterai)) + "%"

if sanity <= 0:
_game_over("Kamu Gila karena Ketakutan!")

# --- AI MONSTER (Stealth System) ---
var jarak_ke_player = monster.position.distance_to(player.position)
var arah_ke_player = (player.position - monster.position).normalized()
var arah_flat = Vector3(arah_ke_player.x, 0, arah_ke_player.z).normalized()

# Monster bisa melihatmu jika jarak < 20 DAN (Senter nyala ATAU kamu sedang jalan)
if jarak_ke_player < 20.0 and (senter.visible or is_walking):
is_chased = true
elif jarak_ke_player > 25.0:
is_chased = false # Kabur

if is_chased:
monster.velocity = arah_flat * 5.0 # Kejar cepat
monster.look_at(Vector3(player.position.x, monster.position.y, player.position.z), Vector3.UP)
else:
# Patroli malas
monster.velocity = Vector3(randf_range(-1,1), 0, randf_range(-1,1)) * 1.0

monster.move_and_slide()

# Cek Tabrakan Monster vs Player (JUMPSCARE)
if jarak_ke_player < 1.5:
_jumpscare()

# Cek Ambil Item
if objek_kunci and player.position.distance_to(objek_kunci.position) < 2.0:
objek_kunci.queue_free()
objek_kunci = null
_menang()

# Cek Ambil Baterai (Mencari node anak yang warnanya hijau)
for child in get_children():
if child is MeshInstance3D and child.material_override and child.material_override.albedo_color == Color(0, 1, 0):
if player.position.distance_to(child.position) < 2.0:
child.queue_free()
baterai = clamp(baterai + 40.0, 0, 100)
print("Baterai ditemukan!")

func _jumpscare():
is_game_over = true
print("JUMPSCARE!")

# Animasi Jumpscare (Layar Merah & Guncangan)
var tween = create_tween()
tween.tween_property(ui_jumpscare, "color", Color(1, 0, 0, 1), 0.1) # Kedip Merah
tween.tween_property(camera, "rotation:z", deg_to_rad(5), 0.05) # Getar
tween.tween_property(camera, "rotation:z", deg_to_rad(-5), 0.05)
tween.tween_property(camera, "rotation:z", 0, 0.05)

ui_status.text = "TERTANGKAP!"
await get_tree().create_timer(2.0).timeout
get_tree().reload_current_scene()

func _game_over(pesan):
is_game_over = true
print("GAME OVER: ", pesan)
ui_status.text = "GAME OVER\n" + pesan
await get_tree().create_timer(3.0).timeout
get_tree().reload_current_scene()

func _menang():
is_game_over = true
print("KAMU MENANG!")
ui_status.text = "SELAMAT!\nKamu Menemukan Kunci dan Kabur!"
await get_tree().create_timer(4.0).timeout
get_tree().reload_current_scene()
