extends Resource
class_name DealerCardResource

@export var card_res: CardResource
@export var card_type: CardType = CardType.REGULAR
@export var card_modifier: CardModifier = CardModifier.NONE

# Used for COMBINED cards
@export var card_res_secondary: CardResource = null

var HolographicColors = {
	CardType.GOLD : Color("ffde4a"),
	CardType.SILVER : Color("abb4cd")
}

enum CardType {
	REGULAR, # Requires 1 input of the exact emoji
	BACKSIDE, # Requires 1 input of emoji with same category
	COMBINED, # Requires 2 inputs corresponding to the two emojis which combine to make the EmojiKitchen combination,
	SILVER,
	GOLD,
}

enum CardModifier {
	NONE
}

var bounty: int:
	get:
		match card_type:
			CardType.REGULAR:
				return 50
			CardType.BACKSIDE:
				return 30
			CardType.COMBINED:
				return 80
			CardType.SILVER:
				return 200
			CardType.GOLD:
				return 300
			_:
				return 0

var required_inputs: int:
	get:
		match card_type:
			CardType.COMBINED:
				return 2
			_:
				return 1


func init(card_res: CardResource, card_type: CardType, card_modifier: CardModifier) -> DealerCardResource:
	self.card_res = card_res
	self.card_type = card_type
	self.card_modifier = card_modifier
	return self

func verify_input(inputs) -> bool:
	
	if inputs.size() < required_inputs:
		return false

	match card_type:
		CardType.REGULAR:
			if inputs[0].card_res.unicode == card_res.unicode:
				return true
		CardType.GOLD:
			if inputs[0].card_res.unicode == card_res.unicode:
				return true
		CardType.SILVER:
			if inputs[0].card_res.unicode == card_res.unicode:
				return true
		CardType.BACKSIDE:
			if inputs[0].card_res.group == card_res.group:
				return true
		CardType.COMBINED:
			if (inputs[0].card_res.unicode == card_res.unicode and inputs[1].card_res.unicode == card_res_secondary.unicode) or (inputs[0].card_res.unicode == card_res_secondary.unicode and inputs[1].card_res.unicode == card_res.unicode):
				return true
	return false
	
	
# This is to assist with RPC calls which cannot transfer objects
func verify_rpc_input(unicodes, groups) -> bool:
	
	match card_type:
		CardType.REGULAR:
			if unicodes[0] == card_res.unicode:
				return true
		CardType.BACKSIDE:
			if groups[0] == card_res.group:
				return true
		CardType.COMBINED:
			if (unicodes[0] == card_res.unicode and unicodes[1] == card_res_secondary.unicode) or (unicodes[0] == card_res_secondary.unicode and unicodes[1] == card_res.unicode):
				return true
				
	return false
		  
				
				
			
