extends Node3D

func _ready():
# 1. MEMBUAT CAHAYA (Matahari)
var cahaya = DirectionalLight3D.new()
cahaya.rotation_degrees = Vector3(-45, -30, 0)
add_child(cahaya)

# 2. MEMBUAT LANTAI
var lantai = MeshInstance3D.new()
var mesh_lantai = PlaneMesh.new()
mesh_lantai.size = Vector2(50, 50)
lantai.mesh = mesh_lantai
add_child(lantai)

# 3. MEMBUAT MONSTER (Kotak Merah)
var monster = MeshInstance3D.new()
var mesh_monster = BoxMesh.new()
mesh_monster.size = Vector3(1, 2, 1)
monster.mesh = mesh_monster
monster.position = Vector3(0, 1, -5) # Posisi agak ke depan

# Warnai monster jadi merah
var material = StandardMaterial3D.new()
material.albedo_color = Color(1, 0, 0) # Merah
monster.material_override = material
add_child(monster)

# 4. MEMBUAT PLAYER & KAMERA
var player = CharacterBody3D.new()
player.position = Vector3(0, 1, 0) # Posisi awal di tengah

var kamera = Camera3D.new()
player.add_child(kamera) # Taruh kamera di dalam player
add_child(player)

# 5. MEMBUAT SCRIPT Pergerakan Kamera & Player (FPS)
var script_player = GDScript.new()
script_player.source_code = """
extends CharacterBody3D
var speed = 5.0
var mouse_sensitivity = 0.003
var rotation_x = 0.0
var rotation_y = 0.0

func _ready():
Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
if event is InputEventMouseMotion:
rotation_y -= event.relative.x * mouse_sensitivity
rotation_x -= event.relative.y * mouse_sensitivity
rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
transform.basis = Basis.from_euler(Vector3(0, rotation_y, 0))
$Camera3D.transform.basis = Basis.from_euler(Vector3(rotation_x, 0, 0))

func _physics_process(delta):
var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
if direction:
velocity.x = direction.x * speed
velocity.z = direction.z * speed
else:
velocity.x = move_toward(velocity.x, 0, speed)
velocity.z = move_toward(velocity.z, 0, speed)
move_and_slide()
"""
script_player.reload()
player.set_script(script_player)

# Animasi monster berputar (opsional)
var tween = create_tween().set_loops()
tween.tween_property(monster, "rotation:y", PI, 2.0)
