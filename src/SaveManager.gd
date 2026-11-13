extends Node

const SAVE_PATH = "user://savegame.json"

func save_game(player_node, inventory_node, sanity_node):
    var save_data = {
        "player_position": [
            player_node.global_position.x,
            player_node.global_position.y,
            player_node.global_position.z
        ],
        "inventory": inventory_node.items,
        "sanity": sanity_node.current_sanity
    }
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
        print("Game berhasil disimpan!")
    else:
        print("Gagal menyimpan game.")

func load_game(player_node, inventory_node, sanity_node):
    if not FileAccess.file_exists(SAVE_PATH):
        print("File save tidak ditemukan.")
        return false
        
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var json_string = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var error = json.parse(json_string)
    
    if error == OK:
        var save_data = json.data
        var pos = save_data["player_position"]
        player_node.global_position = Vector3(pos[0], pos[1], pos[2])
        inventory_node.items = save_data["inventory"]
        sanity_node.current_sanity = save_data["sanity"]
        print("Game berhasil dimuat!")
        return true
    else:
        print("Gagal membaca file save.")
        return false
