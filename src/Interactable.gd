	extends StaticBody3D
	class_name Interactable
	
	@export var prompt_message: String = "Tekan [E] untuk berinteraksi"
	
	# Fungsi ini akan dipanggil oleh Player saat menekan tombol
	func interact(player):
	print("Berinteraksi dengan: ", name)
	# Di sini nanti kamu bisa tambahkan logika:
	# - queue_free() jika ini adalah item yang diambil
	# - animasi pintu terbuka
	# - memicu jumpscare
