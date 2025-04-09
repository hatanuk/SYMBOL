extends Node

const DATA_JSON_PATH = "user://player_data.json"

const HEART_COLORS = {
	'REGULAR': Color.DEEP_PINK,
	'BLUE':  Color.SKY_BLUE,
	'YELLOW': Color.GOLDENROD,
	'WHITE': Color.GHOST_WHITE,
	'BLACK': Color.BLACK
}

var unlocked_heart_colors = ['REGULAR']
var chosen_heart_color = 'REGULAR'
var player_name = ""

func unlock_new_heart_color(color: String):
	if color in HEART_COLORS.keys():
		unlocked_heart_colors.append(color)
		save_player_data()
		
func switch_heart_color(color: String) -> bool:
	if color in unlocked_heart_colors:
		chosen_heart_color = color
		return true
	else:
		return false

	
func save_player_data():
	var data = {
		"name": player_name,
		"unlocked_heart_colors": unlocked_heart_colors,
		"chosen_heart_color": chosen_heart_color
	}
	var file = FileAccess.open(DATA_JSON_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
func load_player_data():
	
	if FileAccess.file_exists(DATA_JSON_PATH):
		var json = JSON.new()
		var file = FileAccess.open(DATA_JSON_PATH, FileAccess.READ)
		var data = json.parse_json(file.get_as_text())
		file.close()
		PlayerInfo.player_name = data["name"]
		PlayerInfo.unlocked_heart_colors = data["unlocked_heart_colors"]
		PlayerInfo.chosen_heart_color = data["chosen_heart_color"]
