
var time_elapsed = 0
var keys_typed = []
var quit = false
var expected_ref_props = ['Reference', 'script', 'Script Variables']
var custom_ref_props = ['profile_name', 'environment', 'slots']
var dirA = "res://tests/files/dirA"
var dirB = "res://tests/files/dirB"
var dirD = "res://tests/files/dirD"
var json1 = "res://tests/files/dirA/json1"
var json2 = "res://tests/files/dirA/json2"
var json3 = "res://tests/files/dirA/json3"

func _initialize():
	print("Initialized:")
	print("  Starting time: %s" % str(time_elapsed))


func _finalize():
	print("Finalized:")
	print("End time: %s" % str(time_elapsed))
	print("Keys typed: %s" % var2str(keys_typed))

func test_copy_dir():
#validate that the directory copy is successful
	var is_copied = Util.copy_dir(dirA, dirB)
	assert(is_copied == true)


func test_read_json_file():
#validate that the json read is successful
	var json_file = Util.read_json_file(json1)
	print(json_file)
	var p = JSON.parse(json_file)
	assert(p.result == TYPE_ARRAY)


# test name starts with same name e.g. test_b vs test_b2
func test_err():
	var error = Util.err("This is an error. Duh!")
	print(error)
	assert(error is Reference)


func test_mkdir():
	# test for a non-existent directory
	var mkdir_is_successful = Util.mkdir(dirB)
	assert(mkdir_is_successful == true)
	# test for an existent directory
	var mkdir_is_not_successful = Util.mkdir(dirD)
	assert(mkdir_is_not_successful == true)
	var does_file_exist = Directory.new().dir_exists(dirD)
	assert(does_file_exist)

func test_ls():
	var ls = Util.ls("res://test/files")
	assert(typeof(ls) == TYPE_ARRAY)
	assert(ls.len() == 4)


func test_inflate_ref():
	var profiles = []
	var profile3 = ProfileConfig.new()
	var json_file3 = Util.read_json_file(json3)
	Util.inflate_ref(profile3, json_file3)
	profiles.push_back(profile3)

	var profile2 = ProfileConfig.new()
	var json_file2 = Util.read_json_file(json2)
	Util.inflate_ref(profile2, json_file2)
	profiles.push_back(profile2)

	print("added profile: %s" % profile2.profile_name)
	print("added profile: %s" % profile3.profile_name)
	assert(profiles.size() == 2)



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
	var json_file = Util.read_json_file(json3)
	Util.inflate_ref(profile, json_file)
	var dict = Util.dictify(profile)
	print("Dictify %s" % dict)
	print("Dictify %s" % json_file)
	assert(String(json_file) == String(dict))

func test_cond_yield():
	var profile = ProfileConfig.new()
	var json_file = Util.read_json_file(json3)
	Util.inflate_ref(profile, json_file)
	var yield_val = Util.cond_yield(profile)
	var old_profile = yield_val.resume()
	assert(is_equal(old_profile, profile))


func test_duplicate_ref():
	var profile = ProfileConfig.new()
	var json_file = Util.read_json_file(json3)
	Util.inflate_ref(profile, json_file)
	var duplicated = Util.duplicate_ref(profile)
	print(duplicated.get_script())
	assert(duplicated is Reference)
	assert(profile != duplicated)
	assert(is_equal(profile, duplicated))

func test_merge_dict():
	var dic1 = {"Some key name": "value1",
				"Another key name": "value2",}
	var dic2 = {
	"Third key name": "value3", }
	var dic3 = Util.merge_dict(dic1, dic2)
	print(dic3)
	var dic4 = {"Another key name": "value2",
				"Some key name": "value1",
				"Third key name": "value3",}
	assert(String(dic3) == String(dic4))

func is_equal(a, b):
	if (a != null && a.get_script()!=null && b != null && b.get_script()!=null):
		if (a.get_script().resource_path == b.get_script().resource_path):
			return true

	return false

