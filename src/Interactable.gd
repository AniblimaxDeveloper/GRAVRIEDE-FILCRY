extends StaticBody3D
class_name Interactable

@export var prompt_message: String = "Tekan [E] untuk berinteraksi"

func interact(player):
print("Berinteraksi dengan: ", name)
