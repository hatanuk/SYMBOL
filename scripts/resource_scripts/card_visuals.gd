extends Resource
class_name CardVisuals

@export var card_res: CardResource

var primary_color: Color:
	get:
		match card_res.group:
			"smileys-and-emotion":
				return Color.YELLOW
			"people-and-body":
				return Color.PEACH_PUFF
			"component":
				return Color.GRAY
			"animals-and-nature":
				return Color.GREEN
			"food-and-drink":
				return Color.ORANGE
			"travel-and-places":
				return Color.DODGER_BLUE
			"activities":
				return Color.MAGENTA
			"objects":
				return Color.PURPLE
			"symbols":
				return Color.DIM_GRAY
			"flags":
				return Color.LIGHT_GRAY
			_:
				return Color.WHITE

var secondary_color: Color:
	get:
		match card_res.group:
			"smileys-and-emotion":
				match card_res.subgroup:
					"face-smiling": return Color.GOLD
					"face-affection": return Color.LIGHT_YELLOW
					"face-tongue": return Color.KHAKI
					"face-hand": return Color.GOLDENROD
					"face-concerned": return Color.DARK_KHAKI
					"face-negative": return Color.OLIVE
					"face-costume": return Color.YELLOW_GREEN
					_:
						return Color.YELLOW

			"people-and-body":
				match card_res.subgroup:
					"hand-fingers-open": return Color.BISQUE
					"hand-fingers-partial": return Color.TAN
					"hand-single-finger": return Color.SANDY_BROWN
					"hand-fingers-closed": return Color.PERU
					"hands": return Color.WHEAT
					"body-parts": return Color.MOCCASIN
					_:
						return Color.PEACH_PUFF

			"animals-and-nature":
				match card_res.subgroup:
					"animal-mammal": return Color.LIME_GREEN
					"animal-bird": return Color.MEDIUM_SEA_GREEN
					"animal-amphibian": return Color.SPRING_GREEN
					"animal-reptile": return Color.FOREST_GREEN
					"animal-marine": return Color.AQUAMARINE
					"animal-bug": return Color.DARK_OLIVE_GREEN
					"plant-flower": return Color.LIGHT_GREEN
					"plant-other": return Color.DARK_GREEN
					_:
						return Color.GREEN

			"food-and-drink":
				match card_res.subgroup:
					"food-fruit": return Color.DARK_ORANGE
					"food-vegetable": return Color.TOMATO
					"food-prepared": return Color.CORAL
					"food-sweet": return Color.SALMON
					"drink": return Color.CHOCOLATE
					_:
						return Color.ORANGE

			"travel-and-places":
				match card_res.subgroup:
					"sky & weather": return Color.ALICE_BLUE
					"place-map": return Color.ROYAL_BLUE
					"place-geographic": return Color.STEEL_BLUE
					"place-building": return Color.SKY_BLUE
					"transport-ground": return Color.NAVY_BLUE
					"transport-water": return Color.TEAL
					"transport-air": return Color.CADET_BLUE
					_:
						return Color.BLUE

			"activities":
				match card_res.subgroup:
					"event": return Color.DEEP_PINK
					"award-medal": return Color.PALE_VIOLET_RED
					"sport": return Color.CRIMSON
					"game": return Color.HOT_PINK
					"arts & crafts": return Color.PLUM
					_:
						return Color.MAGENTA

			"objects":
				match card_res.subgroup:
					"clothing": return Color.DARK_ORCHID
					"music": return Color.BLUE_VIOLET
					"phone": return Color.INDIGO
					"light & video": return Color.THISTLE
					"book-paper": return Color.SLATE_BLUE
					_:
						return Color.PURPLE

			"symbols":
				match card_res.subgroup:
					"warning": return Color.DARK_SLATE_GRAY
					"arrow": return Color.LIGHT_SLATE_GRAY
					"zodiac": return Color.GRAY
					"currency": return Color.LIGHT_GRAY
					_:
						return Color.DIM_GRAY

			"flags":
				match card_res.subgroup:
					"country-flag": return Color.GAINSBORO
					"subdivision-flag": return Color.WHITE_SMOKE
					_:
						return Color.LIGHT_GRAY

			_:
				return Color.WHITE


var texture: Texture:
	get:
		match card_res.group:
			"smileys_emotion":
				return load("res://resources/images/kenny_icons/pattern_38.png")
			"people_body":
				return load("res://resources/images/kenny_icons/pattern_39.png")
			"component":
				return load("res://resources/images/kenny_icons/pattern_40.png")
			"animals_nature":
				return load("res://resources/images/kenny_icons/pattern_41.png")
			"food_drink":
				return load("res://resources/images/kenny_icons/pattern_42.png")
			"travel_places":
				return load("res://resources/images/kenny_icons/pattern_43.png")
			"activities":
				return load("res://resources/images/kenny_icons/pattern_44.png")
			"objects":
				return load("res://resources/images/kenny_icons/pattern_45.png")
			"symbols":
				return load("res://resources/images/kenny_icons/pattern_46.png")
			"flags":
				return load("res://resources/images/kenny_icons/pattern_47.png")
			_:
				return load("res://resources/images/kenny_icons/pattern_48.png")
