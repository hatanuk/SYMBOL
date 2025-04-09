@tool
extends EditorScript

const PNG_SIZE = 128
#
## Called when the node enters the scene tree for the first time.
func _run() -> void:
	
	var card_db = ResourceLoader.load("res://resources/database/card_database.tres")
	for card in card_db.cards:
		var code : String = card.unicode
		var svg_fp = "res://resources/svg_store/" + code + ".svg"
		var png_fp = 	"res://resources/icon_cache/" + code + ".png"
		if FileAccess.file_exists(svg_fp):
			var image = Image.new()
			var error = image.load(svg_fp)
			if error != OK:
				print(error_string(error))
			image.resize(PNG_SIZE, PNG_SIZE)
			if FileAccess.file_exists(png_fp):
				DirAccess.remove_absolute(png_fp)
			image.save_png(png_fp)
	print("Finished generating pngs")
		
		
	
			
