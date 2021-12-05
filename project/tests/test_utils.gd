
var time_elapsed = 0
var keys_typed = []
var quit = false
var expected_ref_props = ['Reference', 'script', 'Script Variables']
var custom_ref_props = ['profile_name', 'environment', 'slots']


func _initialize():
	print("Initialized:")
	print("  Starting time: %s" % str(time_elapsed))


func _finalize():
	print("Finalized:")
	print("End time: %s" % str(time_elapsed))
	print("Keys typed: %s" % var2str(keys_typed))

func test_copy_dir():
#validate that the directory copy is successful
	var is_copied = Util.copy_dir("res://src/files/dirA", "res://src/files/dirB")
	assert(is_copied == true)


func test_read_json_file():
#validate that the json read is successful
	var json_file = Util.read_json_file("res://src/files/dirA/json1")
	print(json_file)
	var p = JSON.parse(json_file)
	assert(p.result == TYPE_ARRAY)


# test name starts with same name e.g. test_b vs test_b2
func test_err():
	var error = Util.err("This is an error. Duh!")
	assert(typeof(error) == TYPE_OBJECT)


func test_mkdir():
	# test for a non-existent directory
	var mkdir_is_successful = Util.mkdir("res://src/files/dirD")
	assert(mkdir_is_successful == true)
	# test for an existent directory
	var mkdir_is_not_successful = Util.mkdir("res://src/files/dirB")
	assert(mkdir_is_not_successful == true)

func test_ls():
	var ls = Util.ls("res://src/files")
	assert(typeof(ls) == TYPE_ARRAY)
	assert(ls.len() == 4)


func test_inflate_ref():
	var profile_path = Global.usr_dir_plus("config/profiles")
	var profiles = []
	var saved_profiles = {}
	var length = 0
	for profile_file in Util.ls(profile_path):
		var path: String = profile_path.plus_file(profile_file)
		var file = File.new()
		if file.open(path, File.READ) != OK:
			printerr("failed to read: %s" % path)
			continue
		var json = file.get_as_text()
		var parse_res := JSON.parse(json)

		if ! parse_res.result is Dictionary:
			printerr("%s: not a dictionairy" % path)
		var profile = ProfileConfig.new()
		Util.inflate_ref(profile, parse_res.result)
		profiles.push_back(profile)
		saved_profiles[profile] = path
		print("existing profile: %s" % profile.profile_name)
	
	var profile = ProfileConfig.new()
	var json_file = Util.read_json_file("res://src/files/dirA/json3")
	length = profiles.size()
	Util.inflate_ref(profile, json_file)
	profiles.push_back(profile)
	print("added profile: %s" % profile.profile_name)
	assert(profiles.size() == (length+1))



func test_ref_props():
	var ref_props = Util.get_ref_props()
	print(Util.get_ref_props())
	assert(ref_props == expected_ref_props)

func test_custom_props():
	var profile = ProfileConfig.new()
	var ref_props = Util.get_custom_pops(profile)
	print(Util.get_custom_pops(profile))
	assert(ref_props == custom_ref_props)

func test_dictify():
	var profile = ProfileConfig.new()
	var json_file = Util.read_json_file("res://src/files/dirA/json3")
	Util.inflate_ref(profile, json_file)
	var dict = Util.dictify(profile)
	print("Dictify %s" % dict)
	print("Dictify %s" % Util.read_json_file("res://src/files/dirA/json3"))
	assert(String(Util.read_json_file("res://src/files/dirA/json3")) == String(dict))

func test_cond_yield():
	var profile = ProfileConfig.new()
	var json_file = Util.read_json_file("res://src/files/dirA/json3")
	Util.inflate_ref(profile, json_file)
	var yield_val = Util.cond_yield(profile)
	print(yield_val)
	assert(yield_val is GDScriptFunctionState)

func test_duplicate_ref():
	var profile = ProfileConfig.new()
	var json_file = Util.read_json_file("res://src/files/dirA/json3")
	Util.inflate_ref(profile, json_file)
	var origin = Util.duplicate_ref(profile)
	print(origin)
	assert(origin is Reference)


func test_merge_dict():
	var dic1 = {"Some key name": "value1",
	 "Another key name": "value2", }
	var dic2 = {
	"Third key name": "value3", }
	var dic3 = Util.merge_dict(dic1, dic2)
	print(dic3)
	var dic4 = { "Another key name": "value2",
	            "Some key name": "value1",
				"Third key name": "value3",}
	assert(String(dic3) == String(dic4))

