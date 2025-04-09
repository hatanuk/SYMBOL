extends Resource
class_name CardDatabase

@export var cards: Array[CardResource] = []
@export var combinations: Array[CombinationResource] = []

func find_combo(unicode1, unicode2):

	var combined1 = [unicode1, unicode2]
	var combined2 = [unicode2, unicode1]
	for combo in combinations:
		if combined1 == combo.inputs or combined2 == combo.inputs:
			return combo.output
			
	return null
	
func find_res(unicode):
	for card_res in cards:
		if unicode == card_res.unicode:
			return card_res

func emoji_to_unicode(emoji):
	for card_res in cards:
		if emoji == card_res.emoji:
			return card_res.unicode
			
func unicode_to_emoji(unicode):
	for card_res in cards:
		if unicode == card_res.unicode:
			return card_res.emoji
