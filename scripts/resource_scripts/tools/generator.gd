@tool
extends EditorScript




func load_json(fp):
	var file = FileAccess.open(fp, FileAccess.READ)
	if not file:
		push_error("Failed to open file: " + fp)
		return null
	var content = file.get_as_text()
	return content

func _run():
	# Load emoji database
	var json_string = load_json("res://resources/database/emojis.json")
	if json_string == null:
		return
	
	var json_parser = JSON.new()
	if json_parser.parse(json_string) != OK:
		push_error("Failed to parse emojis.json")
		return
	var emoji_data = json_parser.data
	
	# Load emoji group database
	var str = load_json("res://resources/database/emoji_groups_full.json")
	if str == null:
		return
	
	var group_parser = JSON.new()
	if group_parser.parse(str) != OK:
		push_error("Failed to parse emoji_groups_full.json")
		return
	var groups_data = group_parser.data
	
	json_string = load_json("res://resources/database/combos.json")
	var combo_parser = JSON.new()
	if combo_parser.parse(json_string) != OK:
		push_error("Failed to parse combos.json")
		return
	var combo_data = combo_parser.data
	
	# Convert groups into a dictionary for fast lookup
	var group_lookup = {}
	for group in groups_data.keys():
		for subgroup in groups_data[group]:
			for val in groups_data[group][subgroup]:
				group_lookup[val] = { "group": group, "subgroup": subgroup }
	
	# Process emojis
	var card_db = CardDatabase.new()
	for emoji in emoji_data.keys():
		var unicode = emoji_data[emoji]
		var group_info = group_lookup.get(emoji, { "group": "unknown", "subgroup": "unknown" })
		if group_info["group"] == "unknown":
			print(emoji)
			print(emoji_data[emoji])
		var card_resource = CardResource.new()
		card_resource.emoji = emoji
		card_resource.unicode = unicode
		card_resource.group = group_info["group"]
		card_resource.subgroup = group_info["subgroup"]
		
		card_db.cards.append(card_resource)
	
	# Save the resource
	if ResourceSaver.save(card_db, "res://resources/database/card_database.tres") == OK:
	else:
		push_error("Failed to save card_database.tres")
