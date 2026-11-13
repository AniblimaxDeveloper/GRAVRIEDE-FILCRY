extends Node

signal item_added(item_name, amount)
signal item_removed(item_name, amount)
signal item_used(item_name)

# Kapasitas maksimal slot
@export var max_slots: int = 8

# Menyimpan item: {"Flashlight": 1, "Battery": 3}
var items: Dictionary = {}

func add_item(item_name: String, amount: int = 1) -> bool:
if items.size() >= max_slots and not items.has(item_name):
print("Inventory penuh!")
return false

if items.has(item_name):
items[item_name] += amount
else:
items[item_name] = amount

emit_signal("item_added", item_name, amount)
print("Ditambahkan: ", item_name, " (", amount, ")")
return true

func remove_item(item_name: String, amount: int = 1):
if items.has(item_name):
items[item_name] -= amount
if items[item_name] <= 0:
items.erase(item_name)
emit_signal("item_removed", item_name, amount)
print("Dibuang: ", item_name)

func use_item(item_name: String):
if items.has(item_name) and items[item_name] > 0:
# Logika penggunaan item (misal: Senter menyala, Medkit menambah darah)
print("Menggunakan item: ", item_name)
emit_signal("item_used", item_name)

# Kurangi stok setelah dipakai (misal: baterai berkurang)
remove_item(item_name, 1)
else:
print("Item tidak ditemukan: ", item_name)

func get_item_count(item_name: String) -> int:
return items.get(item_name, 0)
