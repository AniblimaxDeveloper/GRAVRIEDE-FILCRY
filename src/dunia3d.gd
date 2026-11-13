extends Node3D

var rotation_x = 0.0
var rotation_y = 0.0
var player_node = null
var camera = null
var senter = null
var monster = null
var is_walking = false
var tap_count = 0

func _ready():
    # 1. Lantai
    var lantai = MeshInstance3D.new()
    var mesh_lantai = PlaneMesh.new()
    mesh_lantai.size = Vector2(100, 100)
    lantai.mesh = mesh_lantai
    add_child(lantai)

    # 2. Monster (Kotak Merah)
    monster = MeshInstance3D.new()
    var mesh_monster = BoxMesh.new()
    mesh_monster.size = Vector3(1, 2, 1)
    monster.mesh = mesh_monster
    monster.position = Vector3(0, 1, -15) 
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.8, 0, 0) # Merah Darah
    monster.material_override = material
    add_child(monster)

    # 3. Player Node (Kamera)
    player_node = Node3D.new()
    player_node.position = Vector3(0, 1.5, 5)
    add_child(player_node)

    # 4. Kamera
    camera = Camera3D.new()
    camera.current = true
    player_node.add_child(camera)

    # 5. Senter (Flashlight)
    senter = SpotLight3D.new()
    senter.light_color = Color(1, 1, 0.8) # Warna agak kekuningan
    senter.light_energy = 2.0
    senter.spot_range = 20.0
    senter.visible = false # Awalnya mati
    camera.add_child(senter)

    # 6. Cahaya Lingkungan (Sangat redup)
    var cahaya = DirectionalLight3D.new()
    cahaya.rotation_degrees = Vector3(-45, -30, 0)
    cahaya.light_energy = 0.1 # Dibuat gelap biar seram
    add_child(cahaya)

# Kontrol Sentuh
func _input(event):
    # Geser layar (Lihat sekeliling)
    if event is InputEventScreenDrag:
        rotation_y -= event.relative.x * 0.005
        rotation_x -= event.relative.y * 0.005
        rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
        player_node.rotation = Vector3(0, rotation_y, 0)
        camera.rotation = Vector3(rotation_x, 0, 0)
        
    # Tap Layar (Jalan & Senter)
    elif event is InputEventScreenTouch:
        if event.pressed:
            is_walking = true
            tap_count += 1
            # Jika tap 2 kali dalam waktu singkat
            if tap_count == 2:
                senter.visible = not senter.visible
                tap_count = 0
        else:
            is_walking = false

func _process(delta):
    # Reset hitungan tap jika layar tidak disentuh
    if tap_count > 0 and not is_walking:
        tap_count = 0

    # Player Jalan Maju
    if is_walking:
        var speed = 4.0
        var arah_maju = player_node.transform.basis.z 
        player_node.position -= arah_maju * speed * delta

    # AI Monster Sederhana (Selalu mengejar player)
    if monster and player_node:
        var arah_ke_player = (player_node.position - monster.position).normalized()
        # Kecepatan monster (lebih lambat dari player)
        monster.position += arah_ke_player * 2.5 * delta
        
        # Hadapkan monster ke arah player (opsional)
        monster.look_at(Vector3(player_node.position.x, monster.position.y, player_node.position.z), Vector3.UP)

        # Deteksi tabrakan (Jarak kurang dari 1.5 meter)
        if monster.position.distance_to(player_node.position) < 1.5:
            print("TERTANGKAP MONSTER!")
            # Restart game secara paksa
            get_tree().reload_current_scene()
