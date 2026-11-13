extends Node3D

# Variabel Kontrol
var rotation_x = 0.0
var rotation_y = 0.0
var player = null
var camera = null
var senter = null
var monster = null
var mimic = null
var patung = null
var pintu_keluar = null
var loker = null
var medkit = null
var daftar_sekring = []
var daftar_catatan = []

# Joystick & UI
var joystick_center = Vector2.ZERO
var joystick_vector = Vector2.ZERO
var is_touching_joystick = false
var joystick_radius = 100.0
var ui_status = null
var ui_objektif = null
var ui_jumpscare = null
var ui_damage = null
var ui_lore = null

# Stats
var health = 100.0
var sanity = 100.0
var baterai = 100.0
var stamina = 100.0
var amunisi = 3
var sekring_didapat = 0
var is_game_over = false
var is_sembunyi = false
var is_terlihat_patung = false

# Monster AI
var monster_target_pos = Vector3.ZERO
var monster_stun_time = 0.0
var mimic_aktif = false
var patung_aktif = false

# Audio & Hallucination
var audio_player = null
var playback = null
var heart_timer = 0.0
var halusinasi_timer = 5.0
var flicker_timer = 0.0

func _ready():
# 1. Lingkungan & Kabut
var env = Environment.new()
env.background_mode = Environment.BG_COLOR
env.background_color = Color(0, 0, 0)
env.fog_enabled = true
env.fog_density = 0.08
env.fog_light_color = Color(0.05, 0.05, 0.05)
var world_env = WorldEnvironment.new()
world_env.environment = env
add_child(world_env)

# 2. Setup Audio
audio_player = AudioStreamPlayer.new()
var generator = AudioStreamGenerator.new()
generator.mix_rate = 22050 
audio_player.stream = generator
add_child(audio_player)
audio_player.play()
playback = audio_player.get_stream_playback()

# 3. Map & Player
_buat_lantai()
_buat_labirin_acak()

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
senter.spot_angle = 30.0
senter.visible = false 
camera.add_child(senter)

# 4. Monster Utama (The Stalker)
monster = _buat_monster(Color(0.8, 0, 0), Vector3(0, 1, -20))

# 5. Monster Kedua (The Mimic - Kotak Biru)
mimic = _buat_monster(Color(0, 0.2, 0.8), Vector3(10, 1, -10))

# 6. Monster Ketiga (The Weeping Angel - Patung Abu-abu)
patung = _buat_monster(Color(0.5, 0.5, 0.5), Vector3(-15, 1, -15))
patung.get_child(1).mesh.size = Vector3(1.5, 2.5, 1.5) # Patung lebih tinggi

# 7. Objek
pintu_keluar = _buat_item(Vector3(-20, 2, 20), Color(0, 1, 0), Vector3(4, 4, 1))
loker = _buat_item(Vector3(5, 2, 5), Color(0, 0.5, 1), Vector3(2, 4, 2))
medkit = _buat_item(Vector3(-5, 1, -10), Color(1, 1, 1), Vector3(0.5, 0.5, 0.5))

# 8. Spawn 3 Sekring & 2 Catatan Acak
for i in range(3):
var pos_acak = Vector3(randf_range(-30, 30), 1, randf_range(-30, 30))
daftar_sekring.append(_buat_item(pos_acak, Color(1, 0, 0), Vector3(0.5, 0.5, 0.5)))

for i in range(2):
var pos_acak = Vector3(randf_range(-30, 30), 0.5, randf_range(-30, 30))
var catatan = _buat_item(pos_acak, Color(1, 1, 0.5), Vector3(0.5, 0.1, 0.5)) # Kuning
daftar_catatan.append(catatan)

# 9. Cahaya Redup
var cahaya = DirectionalLight3D.new()
cahaya.name = "CahayaUtama"
cahaya.rotation_degrees = Vector3(-45, -30, 0)
cahaya.light_energy = 0.05
add_child(cahaya)

# 10. Setup UI
_setup_ui()

func _buat_monster(warna, pos):
var m = CharacterBody3D.new()
m.position = pos
var col = CollisionShape3D.new()
col.shape = CapsuleShape3D.new()
m.add_child(col)

var mesh = MeshInstance3D.new()
var box = BoxMesh.new()
box.size = Vector3(1, 2, 1)
mesh.mesh = box
var mat = StandardMaterial3D.new()
mat.albedo_color = warna
mesh.material_override = mat
m.add_child(mesh)
add_child(m)
return m

func _setup_ui():
var ui_layer = CanvasLayer.new()
add_child(ui_layer)

ui_damage = ColorRect.new()
ui_damage.color = Color(1, 0, 0, 0)
ui_damage.set_anchors_preset(Control.PRESET_FULL_RECT)
ui_layer.add_child(ui_damage)

ui_lore = Label.new()
ui_lore.position = Vector2(50, get_viewport().size.y / 2)
ui_lore.add_theme_font_size_override("font_size", 20)
ui_lore.add_theme_color_override("font_color", Color(1, 1, 0.5))
ui_lore.size.x = get_viewport().size.x - 100
ui_lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
ui_layer.add_child(ui_lore)

var crosshair = Label.new()
crosshair.text = "+"
crosshair.add_theme_font_size_override("font_size", 30)
crosshair.set_anchors_preset(Control.PRESET_CENTER)
crosshair.position -= Vector2(10, 20)
ui_layer.add_child(crosshair)

ui_status = Label.new()
ui_status.position = Vector2(10, 10)
ui_status.add_theme_font_size_override("font_size", 18)
ui_layer.add_child(ui_status)

ui_objektif = Label.new()
ui_objektif.position = Vector2(10, 40)
ui_objektif.add_theme_font_size_override("font_size", 16)
ui_objektif.text = "Kumpulkan 3 Sekring Merah! (0/3)"
ui_layer.add_child(ui_objektif)

ui_jumpscare = ColorRect.new()
ui_jumpscare.color = Color(1, 0, 0, 0)
ui_jumpscare.set_anchors_preset(Control.PRESET_FULL_RECT)
ui_layer.add_child(ui_jumpscare)

_buat_tombol(ui_layer, "TEMBAK", Vector2(get_viewport().size.x - 120, get_viewport().size.y - 250), _tembak)
_buat_tombol(ui_layer, "SPRINT", Vector2(get_viewport().size.x - 120, get_viewport().size.y - 150), func(): pass, func(): pass, true)
_buat_tombol(ui_layer, "SEMBUNYI", Vector2(get_viewport().size.x - 240, get_viewport().size.y - 150), _sembunyi)

joystick_center = Vector2(150, get_viewport().size.y - 150)
var joystick_bg = ColorRect.new()
joystick_bg.color = Color(1, 1, 1, 0.2)
joystick_bg.size = Vector2(joystick_radius * 2, joystick_radius * 2)
joystick_bg.position = joystick_center - Vector2(joystick_radius, joystick_radius)
ui_layer.add_child(joystick_bg)

func _buat_tombol(parent, teks, pos, func_pressed, func_released = null, is_hold = false):
var btn = Button.new()
btn.text = teks
btn.size = Vector2(100, 100)
btn.position = pos
if is_hold:
btn.button_down.connect(func(): is_sprinting = true)
btn.button_up.connect(func(): is_sprinting = false)
else:
btn.pressed.connect(func_pressed)
parent.add_child(btn)

func _input(event):
if is_game_over: return
if event is InputEventScreenDrag:
if event.position.x < get_viewport().size.x / 2:
is_touching_joystick = true
var diff = event.position - joystick_center
if diff.length() > joystick_radius: diff = diff.normalized() * joystick_radius
joystick_vector = diff / joystick_radius
else:
rotation_y -= event.relative.x * 0.005
rotation_x -= event.relative.y * 0.005
rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
player.rotation = Vector3(0, rotation_y, 0)
camera.rotation = Vector3(rotation_x, 0, 0)
elif event is InputEventScreenTouch:
if not event.pressed:
if event.position.x < get_viewport().size.x / 2:
is_touching_joystick = false
joystick_vector = Vector2.ZERO

func _process(delta):
if is_game_over: return

# --- GERAKAN PEMAIN ---
var current_speed = 4.0
if is_sprinting and stamina > 0 and joystick_vector.length() > 0.1:
current_speed = 7.0
stamina -= 25.0 * delta
else:
stamina += 10.0 * delta
is_sprinting = false
stamina = clamp(stamina, 0, 100)

var move_dir = Vector3(joystick_vector.x, 0, joystick_vector.y)
if move_dir.length() > 0.1:
var arah_maju = -player.transform.basis.z * -joystick_vector.y
var arah_samping = player.transform.basis.x * joystick_vector.x
var total_gerak = (arah_maju + arah_samping).normalized()
player.velocity.x = total_gerak.x * current_speed
player.velocity.z = total_gerak.z * current_speed
else:
player.velocity = Vector3.ZERO
player.move_and_slide()

# --- BATERAI & SANITY ---
if senter.visible and not is_sembunyi:
baterai -= 2.0 * delta
sanity -= 0.5 * delta
if baterai <= 0:
baterai = 0
senter.visible = false
else:
sanity -= 3.0 * delta 

# --- UI UPDATE ---
var hp_text = "HP: " + str(int(health)) + "%"
ui_status.text = hp_text + " | Sanity: " + str(int(sanity)) + "% | Baterai: " + str(int(baterai)) + "% | Amunisi: " + str(amunisi)
ui_damage.color = Color(1, 0, 0, (100.0 - health) / 200.0)

if sanity <= 0: _game_over("Kamu Gila!")
if health <= 0: _game_over("Kamu Mati!")

# --- EFEK KEDIP LAMPU (FLICKER) ---
flicker_timer -= delta
if flicker_timer <= 0:
var cahaya = get_node_or_null("CahayaUtama")
if cahaya: cahaya.light_energy = randf_range(0.0, 0.1)
await get_tree().create_timer(0.1).timeout
if cahaya: cahaya.light_energy = 0.05
flicker_timer = randf_range(2.0, 5.0)

# --- AI MONSTER UTAMA (The Stalker) ---
var jarak_ke_player = monster.position.distance_to(player.position)
var arah_ke_player = (player.position - monster.position).normalized()
var arah_flat = Vector3(arah_ke_player.x, 0, arah_ke_player.z).normalized()

_putar_suara_jantung(delta, jarak_ke_player)

if jarak_ke_player < 8.0 and senter.visible:
senter.light_energy = randf_range(0.5, 3.0)
else:
senter.light_energy = 3.0

if monster_stun_time > 0:
monster_stun_time -= delta
monster.velocity = Vector3.ZERO
else:
if is_sembunyi:
monster.velocity = Vector3.ZERO
elif jarak_ke_player < 25.0 and (senter.visible or joystick_vector.length() > 0.1):
monster.velocity = arah_flat * 5.0
else:
if monster.position.distance_to(monster_target_pos) < 2.0 or monster_target_pos == Vector3.ZERO:
monster_target_pos = Vector3(randf_range(-30, 30), 1, randf_range(-30, 30))
var arah_target = (monster_target_pos - monster.position).normalized()
monster.velocity = Vector3(arah_target.x, 0, arah_target.z) * 1.5
monster.move_and_slide()

# --- AI MIMIC ---
if mimic:
var jarak_mimic = mimic.position.distance_to(player.position)
if not mimic_aktif and jarak_mimic < 8.0:
mimic_aktif = true
mimic.get_child(1).material_override.albedo_color = Color(1, 0, 0)

if mimic_aktif:
var arah_mimic = (player.position - mimic.position).normalized()
mimic.velocity = Vector3(arah_mimic.x, 0, arah_mimic.z) * 6.0
if jarak_mimic < 1.5 and not is_sembunyi:
health -= 30.0
mimic.position = Vector3(randf_range(-30,30), 1, randf_range(-30,30))
mimic_aktif = false
mimic.get_child(1).material_override.albedo_color = Color(0, 0.2, 0.8)
mimic.move_and_slide()

# --- AI WEEPING ANGEL (Patung) ---
if patung:
var jarak_patung = patung.position.distance_to(player.position)
var arah_patung = (player.position - patung.position).normalized()

# Cek apakah player melihat patung (menggunakan arah kamera)
var kamera_maju = -camera.global_transform.basis.z
var arah_ke_patung = (patung.position - camera.global_position).normalized()
var dot_product = kamera_maju.dot(arah_ke_patung)

# Jika dot_product > 0.5, berarti patung ada di depan layar (terlihat)
if dot_product > 0.5 and senter.visible:
is_terlihat_patung = true
else:
is_terlihat_patung = false

if not is_terlihat_patung:
# Bergerak cepat saat tidak dilihat
patung.velocity = Vector3(arah_patung.x, 0, arah_patung.z) * 8.0
else:
# Membeku saat dilihat
patung.velocity = Vector3.ZERO

patung.move_and_slide()

if jarak_patung < 1.5 and not is_sembunyi:
_jumpscare() # Patung langsung membunuh

# Cek Tabrakan Stalker
if jarak_ke_player < 1.5 and not is_sembunyi and monster_stun_time <= 0:
health -= 25.0
monster_stun_time = 1.5
var tween = create_tween()
tween.tween_property(camera, "rotation:z", deg_to_rad(5), 0.1)
tween.tween_property(camera, "rotation:z", deg_to_rad(-5), 0.1)
tween.tween_property(camera, "rotation:z", 0, 0.1)

# --- LOGIKA OBJEKTIF ---
for s in daftar_sekring:
if is_instance_valid(s) and player.position.distance_to(s.position) < 2.0:
s.queue_free()
sekring_didapat += 1
ui_objektif.text = "Kumpulkan 3 Sekring Merah! (" + str(sekring_didapat) + "/3)"
if sekring_didapat >= 3:
ui_objektif.text = "Semua Sekring didapat! Menuju Pintu Keluar Hijau!"

# Logika Baca Catatan
for c in daftar_catatan:
if is_instance_valid(c) and player.position.distance_to(c.position) < 2.0:
ui_lore.text = "Catatan: 'Mereka bilang ini rumah sakit. Tapi tidak ada pasien... hanya patung...'"
await get_tree().create_timer(4.0).timeout
if is_instance_valid(ui_lore): ui_lore.text = ""

if medkit and player.position.distance_to(medkit.position) < 2.0:
medkit.queue_free()
medkit = null
health = clamp(health + 50.0, 0, 100)

if sekring_didapat >= 3 and pintu_keluar and player.position.distance_to(pintu_keluar.position) < 3.0:
_menang()

func _sembunyi():
if loker and player.position.distance_to(loker.position) < 3.0:
is_sembunyi = not is_sembunyi
if is_sembunyi:
player.position = loker.position
ui_objektif.text = "Kamu Bersembunyi."
else:
player.position += Vector3(0, 0, 2)
ui_objektif.text = "Kumpulkan 3 Sekring Merah! (" + str(sekring_didapat) + "/3)"

func _tembak():
if is_game_over: return
if amunisi <= 0:
senter.light_energy = 20.0
senter.spot_range = 50.0
await get_tree().create_timer(0.2).timeout
senter.light_energy = 3.0
senter.spot_range = 15.0
monster_stun_time = 3.0
return

amunisi -= 1
senter.light_energy = 10.0
await get_tree().create_timer(0.1).timeout
senter.light_energy = 3.0

var space_state = get_world_3d().direct_space_state
var origin = camera.global_position
var end = -camera.global_transform.basis.z * 50.0
var query = PhysicsRayQueryParameters3D.create(origin, end)
var result = space_state.intersect_ray(query)

if result:
if result.collider == monster:
monster.position += (monster.position - player.position).normalized() * 10.0
monster_stun_time = 3.0
elif result.collider == mimic:
mimic.position += (mimic.position - player.position).normalized() * 10.0
mimic_aktif = false
mimic.get_child(1).material_override.albedo_color = Color(0, 0.2, 0.8)
elif result.collider == patung:
# Menembak patung tidak berguna, dia hanya mundur sedikit
patung.position += (patung.position - player.position).normalized() * 5.0

func _putar_suara_jantung(delta, jarak):
var heart_speed = clamp(1.0 / (jarak + 0.1), 0.5, 5.0)
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
var frames = playback.get_frames_available()
for i in range(frames):
var sample = sin(Time.get_ticks_msec() * 0.8) * 0.8
playback.push_frame(Vector2(sample, sample))
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
