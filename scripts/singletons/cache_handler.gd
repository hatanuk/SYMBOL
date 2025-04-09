extends Node

const CACHE_PATH = "res://resources/icon_cache/"
const SVG_STORE_PATH = "res://resources/svg_store/"

@export var default_texture: Resource

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
	return default_texture
	
func load_from_svg_store(unicode, size):
	# Retrieves svg file from svg_store and saves a png version in icon_cache
	# Returns its Resource
	
	var file_path = SVG_STORE_PATH + unicode + ".svg"
	
	if FileAccess.file_exists(file_path):
		var image = Image.new()
		var error = image.load(file_path)
		if error != OK:
			print(error_string(error))
			return
		image.resize(size, size)
		image.save_png(CACHE_PATH + unicode + ".png")
		return retrieve_from_cache(unicode)
	
	
func retrieve_from_cache(unicode):
	# Returns a Resource retrieved from icon_cache if exists
	
	var file_path = CACHE_PATH + unicode + ".png"
	if FileAccess.file_exists(file_path):
		var resource = load(file_path)
		if !resource:
			return null
		return resource

func save_to_svg_store(buffer, unicode):
	var file_path = SVG_STORE_PATH + unicode + ".svg"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_buffer(buffer)
	
func save_to_cache(image : Image, unicode):
	var file_path = CACHE_PATH + unicode + ".png"
	var error = image.save_png(file_path)
	if error != OK:
		print(error_string(error))
	
