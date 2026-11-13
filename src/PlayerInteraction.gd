	extends RayCast3D
	
	# Script ini dipasang di node RayCast3D yang ada di kamera player
	# Pastikan di project settings, tombol "interact" sudah diatur (misal: E)
	
	func _physics_process(_delta):
	if is_colliding():
	var collider = get_collider()
	
	# Jika yang dilihat adalah objek Interactable
	if collider is Interactable:
	# Tampilkan UI Prompt (misal: "Tekan E untuk buka pintu")
	# print(collider.prompt_message) 
	
	# Jika pemain menekan tombol interaksi
	if Input.is_action_just_pressed("interact"):
	collider.interact(get_parent().get_parent()) # Panggil fungsi interact di objek
