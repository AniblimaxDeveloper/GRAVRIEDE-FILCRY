extends Node

const PORT: int = 7777
const MAX_PLAYERS: int = 4

signal player_connected(id)
signal player_disconnected(id)
signal connection_failed()
signal server_disconnected()

func _ready():
multiplayer.peer_connected.connect(_on_player_connected)
multiplayer.peer_disconnected.connect(_on_player_disconnected)
multiplayer.connected_to_server.connect(_on_connected_to_server)
multiplayer.connection_failed.connect(_on_connection_failed)
multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game():
var peer = ENetMultiplayerPeer.new()
var error = peer.create_server(PORT, MAX_PLAYERS)
if error != OK:
print("Gagal membuat server: ", error)
return

multiplayer.multiplayer_peer = peer
print("Server berhasil dibuat! Menunggu pemain lain di port: ", PORT)
_spawn_player(1)

func join_game(ip_address: String):
var peer = ENetMultiplayerPeer.new()
var error = peer.create_client(ip_address, PORT)
if error != OK:
print("Gagal join game: ", error)
return

multiplayer.multiplayer_peer = peer
print("Mencoba terhubung ke IP: ", ip_address)

func _on_player_connected(id):
print("Pemain terhubung dengan ID: ", id)
if multiplayer.is_server():
_spawn_player(id)
emit_signal("player_connected", id)

func _on_player_disconnected(id):
print("Pemain terputus dengan ID: ", id)
emit_signal("player_disconnected", id)

func _on_connected_to_server():
print("Berhasil terhubung ke Host!")

func _on_connection_failed():
print("Gagal terhubung ke Host. Cek IP/Jaringan.")
emit_signal("connection_failed")

func _on_server_disconnected():
print("Host terputus. Kembali ke menu utama.")
emit_signal("server_disconnected")

func _spawn_player(id: int):
print("Spawning Player dengan ID: ", id)
