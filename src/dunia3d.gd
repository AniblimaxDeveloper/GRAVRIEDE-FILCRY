extends Node3D

var rotation_x = 0.0
var rotation_y = 0.0
var player_node = null
var camera = null
var is_walking = false

func _ready():
    # 1. Lantai
    var lantai = MeshInstance3D.new()
    var mesh_lantai = PlaneMesh.new()
    mesh_lantai.size = Vector2(100, 100)
    lantai.mesh = mesh_lantai
    add_child(lantai)

    # 2. Kotak Merah (Monster)
    var kotak = MeshInstance3D.new()
    var mesh_kotak = BoxMesh.new()
    mesh_kotak.size = Vector3(2, 3, 2)
    kotak.mesh = mesh_kotak
    kotak.position = Vector3(0, 1.5, -15) 
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1, 0.2, 0.2)
    kotak.material_override = material
    add_child(kotak)

    # 3. Player Node (Untuk Kamera)
    player_node = Node3D.new()
    player_node.position = Vector3(0, 2, 0)
    add_child(player_node)

    # 4. Kamera
    camera = Camera3D.new()
    camera.current = true
    player_node.add_child(camera)

    # 5. Cahaya
    var cahaya = DirectionalLight3D.new()
    cahaya.rotation_degrees = Vector3(-45, -30, 0)
    add_child(cahaya)

# Fungsi mendeteksi sentuhan di layar HP
func _input(event):
    # Jika layar digeser (Lihat sekeliling)
    if event is InputEventScreenDrag:
        rotation_y -= event.relative.x * 0.005
        rotation_x -= event.relative.y * 0.005
        rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
        
        player_node.rotation = Vector3(0, rotation_y, 0)
        camera.rotation = Vector3(rotation_x, 0, 0)
        
    # Jika layar ditahan (Jalan maju)
    elif event is InputEventScreenTouch:
        if event.pressed:
            is_walking = true
        else:
            is_walking = false

# Fungsi gerak
func _process(delta):
    if is_walking:
        var speed = 4.0
        var arah_maju = player_node.transform.basis.z 
        player_node.position -= arah_maju * speed * delta
