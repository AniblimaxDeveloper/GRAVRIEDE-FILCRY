extends RayCast3D

func _physics_process(_delta):
if is_colliding():
var collider = get_collider()
if collider is Interactable:
if Input.is_action_just_pressed("interact"):
collider.interact(get_parent().get_parent())
