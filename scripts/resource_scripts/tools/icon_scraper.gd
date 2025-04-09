extends Node

#https://emojik.vercel.app/s/<emoji1>_<emoji2>?size=<size>
#https://emojiapi.dev/api/v1/<emoji1>/<size>.png

@onready var http_request = $IconFetcher

func _ready() -> void: 
	pass
	
func load_emoji_single(unicode, size):
	
	var image
	# Check if exists in cache
	image = CacheHandler.retrieve_from_cache(unicode)
	if image:
		return image
		
	# If not, retrieve it from svg_store
	image = CacheHandler.load_from_svg_store(unicode, size)
	if image:
		return image
	
	# If not present in svg_store either, query the API
	image = await request_svg_api(unicode, size)
	if image:
		return image
	else:
		return CacheHandler.default_texture
		
	
func load_emoji_combo(size, emoji1, emoji2):
	pass
	

func request_svg_api(unicode, size):
	var api_url = "https://raw.githubusercontent.com/googlefonts/noto-emoji/refs/heads/main/svg/emoji_u%s.svg" % unicode
	var buffer = await fetch_body_from_api(api_url)
	var image = Image.new()
	var error: Error = image.load_svg_from_buffer(buffer)
	if error != OK:
		print(error_string(error))
		return 
	# Save svg to svg_store
	CacheHandler.save_to_svg_store(buffer, unicode)
	# Resize and add to cache
	image.resize(size, size)
	CacheHandler.save_to_cache(image, unicode)
	return CacheHandler.retrieve_from_cache(unicode)
	
func fetch_body_from_api(url):
	var error = http_request.request(url)

	if error != OK:
		print(error_string(error))
		return null
		
	var response = await http_request.request_completed
	
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		print(error_string(error))
		return null
	
	return response[3]
		

	
	
