extends Node3D

func _ready():
    print("Membangun dunia 3D...")
    
    # 1. Membuat Lantai
    var lantai = MeshInstance3D.new()
    var mesh_lantai = PlaneMesh.new()
    mesh_lantai.size = Vector2(100, 100)
    lantai.mesh = mesh_lantai
    add_child(lantai)

    # 2. Membuat Kotak 3D (Pengganti Monster/Karakter)
    var kotak = MeshInstance3D.new()
    var mesh_kotak = BoxMesh.new()
    mesh_kotak.size = Vector3(2, 3, 2)
    kotak.mesh = mesh_kotak
    kotak.position = Vector3(0, 1.5, -5) 
    
    # Warnai kotak jadi merah
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1, 0.2, 0.2) 
    kotak.material_override = material
    add_child(kotak)

    # 3. Membuat Kamera (Mata Pemain)
    var kamera = Camera3D.new()
    kamera.position = Vector3(0, 2, 5)
    kamera.current = true
    add_child(kamera)

    # 4. Membuat Cahaya (Matahari)
    var cahaya = DirectionalLight3D.new()
    cahaya.rotation_degrees = Vector3(-45, -30, 0)
    add_child(cahaya)
