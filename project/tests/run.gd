extends SceneTree

func _init():
	var args := Array(OS.get_cmdline_args())
	args.pop_front()
	args.pop_front()

	var specific_test = null
	if !args.empty():
		specific_test = args.front()

	var exit_code = yield(run_tests(specific_test), "completed")
	if exit_code == null:
		exit_code = 1
	quit(exit_code)

func run_tests(specific_test):
	yield(self, "idle_frame")

	var tests = discover_tests(specific_test)

	print("running tests")
	print(tests)
	print(specific_test)

	var exit_code = 0

	for test in tests:
		for method in test.methods:
			print("test %s::%s => " % [test.path, method])

			var time_start = OS.get_ticks_msec()
			var res = test.object.call(method)

			if res is GDScriptFunctionState:
				res = yield(res, "completed")

			var elapsed = OS.get_ticks_msec() - time_start

			print(res, " ~ (Took %dms)" % elapsed if elapsed > 0 else "")

			if res != null && res.is_err():
				exit_code = 1

			print()

	print("Done.")

	return exit_code

class Test:
	var path
	var object
	var methods

	func _init(path, obj, methods):
		self.path = path
		self.object = obj
		self.methods = methods

func discover_tests(specific_test) -> Array:
	var scripts = list_files("res://tests")

	var ret := []
	for path in scripts:
		if !ResourceLoader.exists(path, "GDScript"):
			continue

		var script: GDScript = load(path)

		if script == null || script == get_script():
			continue

		var instance: Object = script.new()

		var methods = instance.get_method_list()

		var tests := []

		for method in methods:
			if method["name"].begins_with("test_") && (specific_test == method["name"] || specific_test == null):
				tests.push_back(method["name"])

		if !tests.empty():
			ret.push_back(Test.new(path, instance, tests))

	return ret

static func list_files(path: String, omit_base: bool = false, include_files: bool = true, include_dirs: bool = true) -> Array:
	var ret := []
	var dir = Directory.new()
	if dir.open(path) != OK:
		return ret
	dir.list_dir_begin(true)
	var file_name = dir.get_next()
	while file_name != "":
		if dir.file_exists(file_name):
			if include_files:
				ret.push_back(path.plus_file(file_name) if !omit_base else file_name)
		elif include_dirs:
				ret.push_back(path.plus_file(file_name) if !omit_base else file_name)
		file_name = dir.get_next()
	return ret
