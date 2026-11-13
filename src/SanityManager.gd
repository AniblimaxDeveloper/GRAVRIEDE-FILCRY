	extends Node
	
	signal sanity_changed(new_value)
	signal hallucination_triggered()
	
	@export var max_sanity: float = 100.0
	@export var current_sanity: float = 100.0
	@export var drain_rate_darkness: float = 2.0
	@export var drain_rate_near_monster: float = 15.0
	
	var is_in_darkness: bool = false
	var is_near_monster: bool = false
	
	func _process(delta):
	if current_sanity > 0:
	var total_drain = 0.0
	
	# Terkena efek gelap
	if is_in_darkness:
	total_drain += drain_rate_darkness
	
	# Terkena efek dekat monster
	if is_near_monster:
	total_drain += drain_rate_near_monster
	
	if total_drain > 0:
	current_sanity -= total_drain * delta
	current_sanity = clamp(current_sanity, 0, max_sanity)
	emit_signal("sanity_changed", current_sanity)
	
	# Jika kewarasan sangat rendah, picu halusinasi
	if current_sanity < 30.0 and randf() < 0.01:
	emit_signal("hallucination_triggered")
	print("HALUSINASI: Kamu mendengar suara aneh...")
	
	# Jika kewarasan habis
	if current_sanity <= 0:
	die_from_insanity()
	
	func die_from_insanity():
	print("Player mati karena kehilangan kewarasan (Gila)!")
	# Nanti di sini bisa ditambahkan logika untuk Game Over
