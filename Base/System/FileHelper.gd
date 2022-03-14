extends Node
class_name FileHelper

static func save_file(var file_name: String, var contents: Dictionary):
	var file = File.new()
	file.open(file_name, File.WRITE)
	file.store_line(to_json(contents))
	file.close()

static func load_file(var file_name: String, var contents_holder: Dictionary):
	var file = File.new()
	if file.open(file_name, File.READ) == OK:
		var new_contents = parse_json(file.get_line())
		if not new_contents:
			print("File ", file_name, " not ok")
			file.close()
			return false

		# is file ok?
		for c in contents_holder:
			if not new_contents.keys().has(c):
				print("Contents of ", file_name, " not ok")
				file.close()
				return false

			contents_holder[c] = new_contents[c]

		file.close()
		return true
	else:
		return false
