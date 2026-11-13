extends CharacterBody3D

enum State { PATROL, CHASE, ATTACK }
var current_state: State = State.PATROL

@export var speed: float = 2.0
@export var chase_speed: float = 5.0
@export var detection_range: float = 15.0
@export var attack_range: float = 2.0

@onready var player = null
@onready var nav_agent = $NavigationAgent3D

func _ready():
player = get_tree().get_first_node_in_group("player")
change_state(State.PATROL)

func _physics_process(delta):
match current_state:
State.PATROL:
patrol_behavior()
State.CHASE:
chase_behavior()
State.ATTACK:
attack_behavior()

func patrol_behavior():
if nav_agent.is_navigation_finished():
var random_pos = global_position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
nav_agent.target_position = random_pos

var next_path_pos = nav_agent.get_next_path_position()
var direction = (next_path_pos - global_position).normalized()
velocity = direction * speed
move_and_slide()

if player and global_position.distance_to(player.global_position) < detection_range:
change_state(State.CHASE)
print("Monster melihatmu! LARI!")

func chase_behavior():
if not player:
change_state(State.PATROL)
return

nav_agent.target_position = player.global_position
var next_path_pos = nav_agent.get_next_path_position()
var direction = (next_path_pos - global_position).normalized()
velocity = direction * chase_speed
move_and_slide()

if global_position.distance_to(player.global_position) <= attack_range:
change_state(State.ATTACK)

if global_position.distance_to(player.global_position) > (detection_range + 5):
change_state(State.PATROL)

func attack_behavior():
velocity = Vector3.ZERO
print("Monster Menyerang Player!")
await get_tree().create_timer(1.5).timeout
change_state(State.CHASE)

func change_state(new_state: State):
current_state = new_state
