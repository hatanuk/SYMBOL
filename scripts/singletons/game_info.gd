extends Node

signal game_rank_changed(new_rank)

var game_type: GameTypes
enum GameTypes {
	SINGLEPLAYER,
	MULTIPLAYER
}


var max_cards = 10 # Maximum number of card instances allowed per player

var game_rank: int = 1:
	set(value):
		game_rank = value
		game_rank_changed.emit(game_rank)
	
### RANKS
var rank_colors = {
	10 : Color.DODGER_BLUE,
	20: Color.MEDIUM_SLATE_BLUE,
	30: Color.DARK_RED,
	40: Color.DARK_ORANGE,
	50: Color.YELLOW,
	60: Color.LIME_GREEN,
	70: Color.PERU,
	80: Color.LIGHT_GRAY,
	90: Color.BLACK,
	99: Color.GOLDENROD
}

# Ranks beyond this point will have a shine effect applied
var elite_rank_threshold = 99
###

var game_score: int = 0
