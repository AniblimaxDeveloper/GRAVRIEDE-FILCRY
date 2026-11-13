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
var monster_buta = null
var pintu_keluar = null
var loker = null
var medkit = null
var generator = null
var daftar_sekring = []
var daftar_catatan = []
var daftar_pintu = []

# Joystick & UI
var joystick_center = Vector2.ZERO
var joystick_vector = Vector2.ZERO
var is_touching_joystick = false
var joystick_radius = 100.0

# UI Bars
var bar_hp = null
var bar_stamina = null
var bar_baterai = null
var ui_objektif = null
var ui_jumpscare = null
var ui_damage = null
var ui_lore = null

# Stats
var health = 100.0
var sanity = 100.0
var baterai = 100.0
var stamina = 100.0
var amunisi_mag = 3
var amunisi_res = 6
var sekring_didapat = 0
var is_game_over = false
var is_sembunyi = false
var is_terlihat_patung = false
var generator_nyala = false
var progress_generator = 0.0
var is_interacting = false

# Monster AI
var monster_target_pos = Vector3.ZERO
var monster_stun_time = 0.0
var mimic_aktif = false
var batu_dilempar = null
var batu_pos = Vector3.ZERO

# Audio
var audio_player = null
var playback = null
var heart_timer = 0.0
var growl_timer = 0.0

func _ready():
# 1. Lingkungan & Kabut
var env = Environment.new()
env.background_mode = Environment.BG_COLOR
env.background_color = Color(0, 0, 0)
env.fog_enabled = true
env.fog_density = 0.1
env.fog_light_color = Color(0.02, 0.02, 0.02)
var world_env = WorldEnvironment.new()
world_env.environment = env
add_child(world_env)

# 2. Setup Audio
audio_player = AudioStreamPlayer.new()
var generator_audio = AudioStreamGenerator.new()
generator_audio.mix_rate = 22050 
audio_player.stream = generator_audio
add_child(audio_player)
audio_player.play()
playback = audio_player.get_stream_playback()

# 3. Map & Player
_buat_lantai()
_buat_labirin_dfs()

player = CharacterBody3D.new()
player.position = Vector3(0, 1.5, 0)
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

# 4. Spawn Monsters
monster = _buat_monster(Color(0.8, 0, 0), _cari_posisi_kosong())
mimic = _buat_monster(Color(0, 0.2, 0.8), _cari_posisi_kosong())
patung = _buat_monster(Color(0.5, 0.5, 0.5), _cari_posisi_kosong())
monster_buta = _buat_monster(Color(1, 1, 1), _cari_posisi_kosong())

# 5. Objek Utama
pintu_keluar = _buat_item(Vector3(0, 2, -45), Color(0, 1, 0), Vector3(6, 6, 1)) 
generator = _buat_item(_cari_posisi_kosong(), Color(1, 1, 0), Vector3(2, 2, 2))
loker = _buat_item(_cari_posisi_kosong(), Color(0, 0.5, 1), Vector3(2, 4, 2))
medkit = _buat_item(_cari_posisi_kosong(), Color(1, 1, 1), Vector3(0.5, 0.5, 0.5))

# 6. Spawn Sekring, Catatan, dan Pintu
for i in range(3):
daftar_sekring.append(_buat_item(_cari_posisi_kosong(), Color(1, 0, 0), Vector3(0.5, 0.5, 0.5)))

for i in range(4):
_buat_pintu(_cari_posisi_kosong())

# 7. Cahaya
var cahaya = DirectionalLight3D.new()
cahaya.name = "CahayaUtama"
cahaya.rotation_degrees = Vector3(-45, -30, 0)
cahaya.light_energy = 0.05
add_child(cahaya)

_setup_ui()

func _buat_pintu(pos):
var pintu = StaticBody3D.new()
pintu.position = pos
var col = CollisionShape3D.new()
var shape = BoxShape3D.new()
shape.size = Vector3(4, 4, 0.5)
col.shape = shape
pintu.add_child(col)

var mesh = MeshInstance3D.new()
var box = BoxMesh.new()
box.size = Vector3(4, 4, 0.5)
mesh.mesh = box
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(0.4, 0.2, 0.1) # Warna kayu
mesh.material_override = mat
pintu.add_child(mesh)

pintu.set_meta("is_pintu", true)
pintu.set_meta("terbuka", false)
add_child(pintu)
daftar_pintu.append(pintu)

func _cari_posisi_kosong():
return Vector3(randf_range(-35, 35), 1, randf_range(-35, 35))

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

# Efek Darah Tepi Layar
ui_damage = ColorRect.new()
ui_damage.color = Color(1, 0, 0, 0)
ui_damage.set_anchors_preset(Control.PRESET_FULL_RECT)
ui_layer.add_child(ui_damage)

# Visual Bars (Kotak UI)
bar_hp = ColorRect.new()
bar_hp.color = Color(1, 0, 0)
bar_hp.position = Vector2(20, 20)
bar_hp.size = Vector2(200, 20)
ui_layer.add_child(bar_hp)

bar_stamina = ColorRect.new()
bar_stamina.color = Color(0, 1, 0)
bar_stamina.position = Vector2(20, 50)
bar_stamina.size = Vector2(200, 20)
ui_layer.add_child(bar_stamina)

bar_baterai = ColorRect.new()
bar_baterai.color = Color(1, 1, 0)
bar_baterai.position = Vector2(20, 80)
bar_baterai.size = Vector2(200, 20)
ui_layer.add_child(bar_baterai)

var crosshair = Label.new()
crosshair.text = "+"
crosshair.add_theme_font_size_override("font_size", 30)
crosshair.set_anchors_preset(Control.PRESET_CENTER)
crosshair.position -= Vector2(10, 20)
ui_layer.add_child(crosshair)

ui_objektif = Label.new()
ui_objektif.position = Vector2(20, 110)
ui_objektif.add_theme_font_size_override("font_size", 16)
ui_objektif.text = "Kumpulkan 3 Sekring! (0/3)"
ui_layer.add_child(ui_objektif)

ui_lore = Label.new()
ui_lore.position = Vector2(50, get_viewport().size.y / 2)
ui_lore.add_theme_font_size_override("font_size", 20)
ui_lore.add_theme_color_override("font_color", Color(1, 1, 0.5))
ui_lore.size.x = get_viewport().size.x - 100
ui_lore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
ui_layer.add_child(ui_lore)

ui_jumpscare = ColorRect.new()
ui_jumpscare.color = Color(1, 0, 0, 0)
ui_jumpscare.set_anchors_preset(Control.PRESET_FULL_RECT)
ui_layer.add_child(ui_jumpscare)

# Tombol UI
_buat_tombol(ui_layer, "TEMBAK", Vector2(get_viewport().size.x - 110, get_viewport().size.y - 280), _tembak)
_buat_tombol(ui_layer, "RELOAD", Vector2(get_viewport().size.x - 220, get_viewport().size.y - 280), _reload)
_buat_tombol(ui_layer, "SPRINT", Vector2(get_viewport().size.x - 110, get_viewport().size.y - 170), func(): pass, func(): pass, true)
_buat_tombol(ui_layer, "LEMPAR", Vector2(get_viewport().size.x - 220, get_viewport().size.y - 170), _lempat_batu)
_buat_tombol(ui_layer, "INTERAKSI", Vector2(get_viewport().size.x / 2 - 60, get_viewport().size.y - 100), _interaksi, func(): is_interacting = false, false, true)

joystick_center = Vector2(150, get_viewport().size.y - 150)
var joystick_bg = ColorRect.new()
joystick_bg.color = Color(1, 1, 1, 0.2)
joystick_bg.size = Vector2(joystick_radius * 2, joystick_radius * 2)
joystick_bg.position = joystick_center - Vector2(joystick_radius, joystick_radius)
ui_layer.add_child(joystick_bg)

func _buat_tombol(parent, teks, pos, func_pressed, func_released = null, is_hold = false, is_interact = false):
var btn = Button.new()
btn.text = teks
btn.size = Vector2(90, 90) if not is_interact else Vector2(120, 80)
btn.position = pos
if is_hold:
btn.button_down.connect(func(): is_sprinting = true)
btn.button_up.connect(func(): is_sprinting = false)
elif is_interact:
btn.button_down.connect(func(): is_interacting = true)
btn.button_up.connect(func_released)
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
if not event.pressed and event.position.x < get_viewport().size.x / 2:
is_touching_joystick = false
joystick_vector = Vector2.ZERO

func _process(delta):
if is_game_over: return

# --- GERAKAN PEMAIN & ADRENALIN ---
var current_speed = 4.0
var is_moving = joystick_vector.length() > 0.1

# Efek Adrenalin (HP Rendah = Jalan Lebih Cepat)
if health < 30.0:
current_speed = 4.5
# Layar berdenyut merah
ui_damage.color = Color(1, 0, 0, 0.3 + sin(Time.get_ticks_msec() * 0.01) * 0.2)
else:
ui_damage.color = Color(1, 0, 0, (100.0 - health) / 200.0)

if is_sprinting and stamina > 0 and is_moving:
current_speed += 3.0
stamina -= 25.0 * delta
else:
stamina += 10.0 * delta
is_sprinting = false
stamina = clamp(stamina, 0, 100)

if is_moving:
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

# --- UPDATE UI BARS (Lebar Bar Berubah) ---
bar_hp.size.x = (health / 100.0) * 200
bar_stamina.size.x = (stamina / 100.0) * 200
bar_baterai.size.x = (baterai / 100.0) * 200

if sanity <= 0: _game_over("Kamu Gila!")
if health <= 0: _game_over("Kamu Mati!")

# --- LOGIKA GENERATOR & INTERAKSI PINTU ---
if is_interacting:
# Interaksi Generator
if not generator_nyala and sekring_didapat >= 3:
if player.position.distance_to(generator.position) < 3.0:
progress_generator += 20.0 * delta
ui_objektif.text = "Menyalakan Generator... " + str(int(progress_generator)) + "%"
if progress_generator >= 100:
generator_nyala = true
generator.get_child(0).material_override.albedo_color = Color(0, 1, 0)
ui_objektif.text = "Generator Menyala! Menuju Pintu Keluar Hijau!"
pintu_keluar.position.y = 100

# Interaksi Pintu (Buka/Tutup)
for p in daftar_pintu:
if is_instance_valid(p) and player.position.distance_to(p.position) < 3.0:
var terbuka = p.get_meta("terbuka")
if not terbuka:
# Buka pintu (Rotasi 90 derajat)
var tween = create_tween()
tween.tween_property(p, "rotation:y", deg_to_rad(90), 0.5)
p.set_meta("terbuka", true)
else:
# Tutup pintu
var tween = create_tween()
tween.tween_property(p, "rotation:y", 0.0, 0.5)
p.set_meta("terbuka", false)
is_interacting = false # Reset agar tidak berkedip terus

# --- AI MONSTER UTAMA (The Stalker) ---
var jarak_ke_player = monster.position.distance_to(player.position)
var arah_flat = (player.position - monster.position).normalized()
_putar_suara_jantung(delta, jarak_ke_player)

if monster_stun_time > 0:
monster_stun_time -= delta
monster.velocity = Vector3.ZERO
else:
if not is_sembunyi and jarak_ke_player < 25.0 and (senter.visible or is_moving):
monster.velocity = Vector3(arah_flat.x, 0, arah_flat.z) * 5.0
else:
if monster.position.distance_to(monster_target_pos) < 2.0 or monster_target_pos == Vector3.ZERO:
monster_target_pos = _cari_posisi_kosong()
var arah_target = (monster_target_pos - monster.position).normalized()
monster.velocity = Vector3(arah_target.x, 0, arah_target.z) * 1.5
monster.move_and_slide()

# --- AI MIMIC & PATUNG & BLIND ONE (Logika Tetap Sama) ---
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
mimic.position = _cari_posisi_kosong()
mimic_aktif = false
mimic.get_child(1).material_override.albedo_color = Color(0, 0.2, 0.8)
mimic.move_and_slide()

if patung:
var jarak_patung = patung.position.distance_to(player.position)
var kamera_maju = -camera.global_transform.basis.z
var arah_ke_patung = (patung.position - camera.global_position).normalized()

if kamera_maju.dot(arah_ke_patung) > 0.5 and senter.visible:
is_terlihat_patung = true
else:
is_terlihat_patung = false

if not is_terlihat_patung:
patung.velocity = (player.position - patung.position).normalized() * 8.0
else:
patung.velocity = Vector3.ZERO
patung.move_and_slide()
if jarak_patung < 1.5 and not is_sembunyi: _jumpscare()

if monster_buta:
var jarak_buta = monster_buta.position.distance_to(player.position)
var arah_buta = (player.position - monster_buta.position).normalized()
if (is_moving and not is_sembunyi) or batu_dilempar != null:
var target_pos = batu_pos if batu_dilempar != null else player.position
var arah_target = (target_pos - monster_buta.position).normalized()
monster_buta.velocity = Vector3(arah_target.x, 0, arah_target.z) * 6.0
else:
monster_buta.velocity = Vector3(randf_range(-2,2), 0, randf_range(-2,2))
monster_buta.move_and_slide()
if jarak_buta < 1.5 and not is_sembunyi: _jumpscare()

# Logika Batu Dilempar
if batu_dilempar:
batu_dilempar.position.y -= 9.8 * delta
if batu_dilempar.position.y <= 0.5:
batu_dilempar.queue_free()
batu_dilempar = null

# Cek Tabrakan Stalker
if jarak_ke_player < 1.5 and not is_sembunyi and monster_stun_time <= 0:
health -= 25.0
monster_stun_time = 1.5
var tween = create_tween()
tween.tween_property(camera, "rotation:z", deg_to_rad(5), 0.1)
tween.tween_property(camera, "rotation:z", deg_to_rad(-5), 0.1)
tween.tween_property(camera, "rotation:z", 0, 0.1)

# --- LOGIKA OBJEKTIF & ITEM ---
for s in daftar_sekring:
if is_instance_valid(s) and player.position.distance_to(s.position) < 2.0:
s.queue_free()
sekring_didapat += 1
ui_objektif.text = "Kumpulkan 3 Sekring! (" + str(sekring_didapat) + "/3)"
if sekring_didapat >= 3:
ui_objektif.text = "Pergi ke Generator Kuning dan tahan [INTERAKSI]!"

if medkit and player.position.distance_to(medkit.position) < 2.0:
medkit.queue_free()
medkit = null
health = clamp(health + 50.0, 0, 100)

if generator_nyala and pintu_keluar and player.position.distance_to(pintu_keluar.position) < 4.0:
_menang()

func _interaksi():
# Fungsi ini dipanggil saat tombol interaksi ditahan (is_interacting = true)
pass

func _lempat_batu():
if batu_dilempar == null and not is_game_over:
batu_dilempar = MeshInstance3D.new()
var mesh = SphereMesh.new()
mesh.radius = 0.2
batu_dilempar.mesh = mesh
batu_dilempar.position = camera.global_position + (-camera.global_transform.basis.z * 2)
add_child(batu_dilempar)
batu_pos = camera.global_position + (-camera.global_transform.basis.z * 30)
var tween = create_tween()
tween.tween_property(batu_dilempar, "position", batu_pos, 0.5)
await get_tree().create_timer(0.5).timeout
if is_instance_valid(batu_dilempar):
batu_dilempar.queue_free()
batu_dilempar = null

func _reload():
if amunisi_res > 0 and amunisi_mag < 3:
var butuh = 3 - amunisi_mag
var diambil = min(butuh, amunisi_res)
amunisi_mag += diambil
amunisi_res -= diambil

func _tembak():
if is_game_over or amunisi_mag <= 0: return
amunisi_mag -= 1
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
elif result.collider == monster_buta:
monster_buta.position += (monster_buta.position - player.position).normalized() * 10.0

func _putar_suara_jantung(delta, jarak):
var heart_speed = clamp(1.0 / (jarak + 0.1), 0.5, 5.0)
heart_timer -= delta * heart_speed
var frames = playback.get_frames_available()

# Logika Geraman (Growl) saat monster dekat
growl_timer -= delta
if jarak < 15.0:
if growl_timer <= 0:
growl_timer = 2.0 # Geram setiap 2 detik

for i in range(frames):
var sample = 0.0
if heart_timer > 0.0 and heart_timer < 0.2:
sample += sin(Time.get_ticks_msec() * 0.05) * 0.5 

# Suara Geraman Frekuensi Rendah (Noise)
if jarak < 15.0 and growl_timer > 1.5:
sample += randf_range(-0.2, 0.2) # Static noise

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
await get_tree().create_timer(2.0).timeout
get_tree().reload_current_scene()

func _game_over(pesan):
is_game_over = true
ui_objektif.text = "GAME OVER: " + pesan
await get_tree().create_timer(3.0).timeout
get_tree().reload_current_scene()

func _menang():
is_game_over = true
ui_objektif.text = "SELAMAT! Kamu Berhasil Kabur!"
await get_tree().create_timer(4.0).timeout
get_tree().reload_current_scene()

# --- MAP GENERATOR & ASSET ---
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
mesh_lantai.size = Vector2(150, 150)
lantai.mesh = mesh_lantai
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(0.1, 0.1, 0.1)
lantai.material_override = mat
add_child(lantai)

var grid_size = 15
var grid = []
var cell_size = 6
var mat_dinding = null

func _buat_labirin_dfs():
mat_dinding = StandardMaterial3D.new()
mat_dinding.albedo_color = Color(0.2, 0.2, 0.2)
for x in range(grid_size):
grid.append([])
for z in range(grid_size):
grid[x].append(1)
var stack = []
var current = Vector2(1, 1)
grid[1][1] = 0
stack.append(current)
while stack.size() > 0:
current = stack.back()
var neighbours = []
var dirs = [Vector2(0, -2), Vector2(0, 2), Vector2(-2, 0), Vector2(2, 0)]
for d in dirs:
var n = current + d
if n.x > 0 and n.x < grid_size - 1 and n.y > 0 and n.y < grid_size - 1:
if grid[int(n.x)][int(n.y)] == 1:
neighbours.append(n)
if neighbours.size() > 0:
var next = neighbours[randi() % neighbours.size()]
grid[int(next.x)][int(next.y)] = 0
grid[int((current.x + next.x) / 2)][int((current.y + next.y) / 2)] = 0
stack.append(next)
else:
stack.pop_back()
for x in range(grid_size):
for z in range(grid_size):
if grid[x][z] == 1:
_buat_dinding(Vector3((x - grid_size/2) * cell_size, 2, (z - grid_size/2) * cell_size), mat_dinding)

func _buat_dinding(pos, material):
var dinding = StaticBody3D.new()
dinding.position = pos
var col = CollisionShape3D.new()
var shape = BoxShape3D.new()
shape.size = Vector3(cell_size, 4, cell_size)
col.shape = shape
dinding.add_child(col)
var mesh = MeshInstance3D.new()
var box = BoxMesh.new()
box.size = Vector3(cell_size, 4, cell_size)
mesh.mesh = box
mesh.material_override = material
dinding.add_child(mesh)
add_child(dinding)
