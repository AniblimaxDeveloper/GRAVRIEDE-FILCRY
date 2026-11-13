extends Node3D

var rotation_x = 0.0
var rotation_y = 0.0
var player = null
var camera = null
var senter = null
var monster = null
var sekring = null
var pintu_keluar = null
var is_walking = false
var is_sprinting = false
var tap_count = 0

# Survival Stats
var ui_status = null
var ui_objektif = null
var ui_jumpscare = null
var sanity = 100.0
var baterai = 100.0
var stamina = 100.0
var amunisi = 3
var is_game_over = false
var punya_sekring = false

# Audio Jantung
var audio_player = null
var playback = null
var heart_timer = 0.0
var heart_speed = 1.0

func _ready():
# 1. Lingkungan & Kabut
var env = Environment.new()
env.background_mode = Environment.BG_COLOR
env.background_color = Color(0, 0, 0)
env.fog_enabled = true
env.fog_density = 0.06
env.fog_light_color = Color(0.05, 0.05, 0.05)
var world_env = WorldEnvironment.new()
world_env.environment = env
add_child(world_env)

# 2. Setup Audio & Map
_setup_audio()
_buat_lantai()
_buat_labirin_acak()

# 3. Player & Kamera
player = CharacterBody3D.new()
player.position = Vector3(0, 1.5, 5)
var col_player = CollisionShape3D.new()
col_player.shape = CapsuleShape3D.new()
player.add_child(col_player)
add_child(player)

camera = Camera3D.new()
camera.current = true
player.add_child(camera)

senter = SpotLight3D.new()
senter.light_energy = 3.0
senter.spot_range = 15.0
senter.visible = false 
camera.add_child(senter)

# 4. Monster
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

# 5. Objek: Sekring (Merah), Pintu (Hijau), Baterai (Hijau Kecil)
sekring = _buat_item(Vector3(15, 1, -20), Color(1, 0, 0), Vector3(0.5, 0.5, 0.5))
pintu_keluar = _buat_item(Vector3(-20, 2, 20), Color(0, 1, 0), Vector3(4, 4, 1))
_buat_item(Vector3(-10, 1, -5), Color(0, 0.5, 0), Vector3(0.5, 0.5, 0.5)) # Baterai

# 6. Cahaya & UI
var cahaya = DirectionalLight3D.new()
cahaya.rotation_degrees = Vector3(-45, -30, 0)
cahaya.light_energy = 0.05
add_child(cahaya)

_setup_ui()

func _setup_audio():
audio_player = AudioStreamPlayer.new()
var generator = AudioStreamGenerator.new()
generator.mix_rate = 22050 
audio_player.stream = generator
add_child(audio_player)
audio_player.play()
playback = audio_player.get_stream_playback()

func _setup_ui():
var ui_layer = CanvasLayer.new()
add_child(ui_layer)

ui_status = Label.new()
ui_status.position = Vector2(10, 10)
ui_status.add_theme_font_size_override("font_size", 18)
ui_layer.add_child(ui_status)

ui_objektif = Label.new()
ui_objektif.position = Vector2(10, 40)
ui_objektif.add_theme_font_size_override("font_size", 16)
ui_objektif.text = "Cari Sekring Merah!"
ui_layer.add_child(ui_objektif)

ui_jumpscare = ColorRect.new()
ui_jumpscare.color = Color(1, 0, 0, 0)
ui_jumpscare.set_anchors_preset(Control.PRESET_FULL_RECT)
ui_layer.add_child(ui_jumpscare)

# Tombol SPRINT & TEMBAK
var btn_sprint = Button.new()
btn_sprint.text = "SPRINT"
btn_sprint.size = Vector2(100, 100)
btn_sprint.position = Vector2(get_viewport().size.x - 120, get_viewport().size.y - 150)
btn_sprint.button_down.connect(func(): is_sprinting = true)
btn_sprint.button_up.connect(func(): is_sprinting = false)
ui_layer.add_child(btn_sprint)

var btn_tembak = Button.new()
btn_tembak.text = "TEMBAK"
btn_tembak.size = Vector2(100, 100)
btn_tembak.position = Vector2(get_viewport().size.x - 240, get_viewport().size.y - 150)
btn_tembak.pressed.connect(_tembak)
ui_layer.add_child(btn_tembak)

func _tembak():
if amunisi <= 0 or is_game_over: return
amunisi -= 1

# Efek Kilatan (Muzzle Flash sederhana)
senter.light_energy = 10.0
await get_tree().create_timer(0.1).timeout
senter.light_energy = 3.0

# Logika Raycast (Tembakan Laser tak terlihat)
var space_state = get_world_3d().direct_space_state
var origin = camera.global_position
var end = -camera.global_transform.basis.z * 50.0 # Tembak sejauh 50 meter
var query = PhysicsRayQueryParameters3D.create(origin, end)
var result = space_state.intersect_ray(query)

if result:
var collider = result.collider
# Jika yang ditembak adalah monster
if collider == monster:
print("Monster Terkena Tembakan!")
# Pentalan monster (mundur)
var arah_mundur = (monster.position - player.position).normalized()
monster.position += arah_mundur * 10.0
# Efek Monster pingsan sementara
monster.velocity = Vector3.ZERO

func _buat_item(pos, warna, ukuran):
var item = MeshInstance3D.new()
var mesh = BoxMesh.new()
mesh.size = ukuran
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

func _buat_labirin_acak():
var grid_size = 10
var cell_size = 4
var mat_dinding = StandardMaterial3D.new()
mat_dinding.albedo_color = Color(0.2, 0.2, 0.2)
for i in range(-grid_size, grid_size + 1):
_buat_dinding(Vector3(i * cell_size, 2, -grid_size * cell_size), mat_dinding)
_buat_dinding(Vector3(i * cell_size, 2, grid_size * cell_size), mat_dinding)
for x in range(-grid_size + 1, grid_size):
for z in range(-grid_size + 1, grid_size):
if randf() < 0.3:
_buat_dinding(Vector3(x * cell_size, 2, z * cell_size), mat_dinding)

func _buat_dinding(pos, material):
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
mesh.material_override = material
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

if tap_count > 0 and not is_walking: tap_count = 0

var current_speed = 4.0
if is_sprinting and stamina > 0:
current_speed = 7.0
stamina -= 25.0 * delta
else:
stamina += 10.0 * delta
is_sprinting = false

stamina = clamp(stamina, 0, 100)

if is_walking:
var arah_maju = player.transform.basis.z 
player.velocity.x = -arah_maju.x * current_speed
player.velocity.z = -arah_maju.z * current_speed
else:
player.velocity = Vector3.ZERO
player.move_and_slide()

# Baterai & Sanity
if senter.visible:
baterai -= 2.0 * delta
sanity -= 0.5 * delta
if baterai <= 0:
baterai = 0
senter.visible = false
else:
sanity -= 3.0 * delta 

ui_status.text = "Sanity: " + str(int(sanity)) + "% | Baterai: " + str(int(baterai)) + "% | Stamina: " + str(int(stamina)) + "% | Amunisi: " + str(amunisi)

if sanity <= 0: _game_over("Kamu Gila!")

# --- AI MONSTER ---
var jarak_ke_player = monster.position.distance_to(player.position)
var arah_ke_player = (player.position - monster.position).normalized()
var arah_flat = Vector3(arah_ke_player.x, 0, arah_ke_player.z).normalized()

_putar_suara_jantung(delta, jarak_ke_player)

if jarak_ke_player < 8.0 and senter.visible:
senter.light_energy = randf_range(0.5, 3.0)
else:
senter.light_energy = 3.0

if jarak_ke_player < 25.0 and (senter.visible or is_walking):
monster.velocity = arah_flat * 5.0
monster.look_at(Vector3(player.position.x, monster.position.y, player.position.z), Vector3.UP)
else:
monster.velocity = Vector3(randf_range(-1,1), 0, randf_range(-1,1)) * 1.0

monster.move_and_slide()

if jarak_ke_player < 1.5: _jumpscare()

# --- LOGIKA OBJEKTIF ---
# 1. Ambil Sekring
if sekring and player.position.distance_to(sekring.position) < 2.0:
sekring.queue_free()
sekring = null
punya_sekring = true
ui_objektif.text = "Sekring didapat! Menuju Pintu Keluar Hijau."
print("Sekring didapat!")

# 2. Menang jika sudah punya sekring dan menyentuh pintu
if punya_sekring and pintu_keluar and player.position.distance_to(pintu_keluar.position) < 3.0:
_menang()

func _putar_suara_jantung(delta, jarak):
heart_speed = clamp(1.0 / (jarak + 0.1), 0.5, 5.0)
heart_timer -= delta * heart_speed
var frames = playback.get_frames_available()
for i in range(frames):
var sample = 0.0
if heart_timer > 0.0 and heart_timer < 0.2:
sample = sin(Time.get_ticks_msec() * 0.05) * 0.5 
playback.push_frame(Vector2(sample, sample))
if heart_timer <= 0.0: heart_timer = 1.0

func _jumpscare():
is_game_over = true
var tween = create_tween()
tween.tween_property(ui_jumpscare, "color", Color(1, 0, 0, 1), 0.1)
tween.tween_property(camera, "rotation:z", deg_to_rad(10), 0.05)
tween.tween_property(camera, "rotation:z", deg_to_rad(-10), 0.05)
ui_status.text = "TERTANGKAP!"
await get_tree().create_timer(2.0).timeout
get_tree().reload_current_scene()

func _game_over(pesan):
is_game_over = true
ui_status.text = "GAME OVER\n" + pesan
await get_tree().create_timer(3.0).timeout
get_tree().reload_current_scene()

func _menang():
is_game_over = true
ui_status.text = "SELAMAT!\nKamu Berhasil Kabur!"
await get_tree().create_timer(4.0).timeout
get_tree().reload_current_scene()
