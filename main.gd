extends Control

var character_to_pack: String = ""
var character_to_unpack: String = ""
var ctgp7_path: String = ""
var legacy_blacklist: PackedStringArray = ["Face_Raider"]

func _ready() -> void:
	# version
	$window/version.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	
	%out.write_note("A Python installation with PIP added to PATH is required for ChPacker to function")
	%out.write_regular("Performing compatibility check...")
	Executor.exec_thread("pip install sarc")
	await Executor.finished_current_thread
	if not Executor.current_err == 0:
		%out.write_error("PIP is not installed (exit status %s). Please re-install Python from [url]https://www.python.org/downloads/[/url] and make sure you tick 'Add PIP to PATH' when running the installer." % Executor.current_err)
	else:
		%out.write_success("Done")
	%out.write_regular("Checking module availability...")
	Executor.exec_thread("sarc -h") # test if module was installed properly
	await Executor.finished_current_thread
	if not Executor.current_err == 0:
		%out.write_error("Failed to collect dependencies (exit status %s)" % Executor.current_err)
	else:
		%out.write_success("Done")
		$window/options/drive/select.disabled = false
	
	## options
	
	# drive
	var check_sd_validity: Callable = func(dir: String) -> void:
		$window/options/character/select.get_popup().clear()
		if DirAccess.dir_exists_absolute("%s/CTGP-7" % dir):
			ctgp7_path = "%s/CTGP-7" % dir
			%out.write_success("Found valid CTGP-7 installation at %s/CTGP-7" % dir)
			$window/options/character/select.disabled = false
			$window/options/character2/select.disabled = false
			$window/options/character/pack.disabled = true
			$window/options/character2/unpack.disabled = true
			for unpacked in DirAccess.get_directories_at("%s/CTGP-7/MyStuff/Characters/" % dir):
				if not unpacked in legacy_blacklist: $window/options/character/select.get_popup().add_item(unpacked)
			for packed in DirAccess.get_files_at("%s/CTGP-7/MyStuff/Characters/" % dir):
				if packed.to_lower().get_extension() == "chpack": $window/options/character2/select.get_popup().add_item(packed.get_basename())
		else:
			%out.write_error("Unable to find CTGP-7 internals at %s/CTGP-7" % dir)
			$window/options/character/select.disabled = true
			$window/options/character2/select.disabled = true
			$window/options/character/pack.disabled = true
			$window/options/character2/unpack.disabled = true
	$window/options/drive/select.pressed.connect(func() -> void: $window/options/drive/dialog.show())
	$window/options/drive/dialog.dir_selected.connect(check_sd_validity)
	
	# character
	var char_selected: Callable = func(id: int) -> void:
		character_to_pack = $window/options/character/select.get_popup().get_item_text(id)
		$window/options/character/select.text = character_to_pack
		if DirAccess.dir_exists_absolute("%s/MyStuff/Characters/%s" % [ctgp7_path, character_to_pack]):
			if len(DirAccess.get_directories_at("%s/MyStuff/Characters/%s" % [ctgp7_path, character_to_pack])) == 0:
				%out.write_regular("Possible character found at %s" % character_to_pack)
				$window/options/character/pack.disabled = false
			else:
				%out.write_warning("%s does not appear to be a valid character. Please make sure that the directory has no subfolders and that you are following the filesystem guide at [url]https://mk3ds.com/index.php?title=Character_Pack[/url]" % character_to_pack)
				$window/options/character/pack.disabled = true
	var pack: Callable = func() -> void:
		%out.write_regular("Packing %s..." % character_to_pack)
		var path_to_pack: String = "%s/MyStuff/Characters/%s" % [ctgp7_path, character_to_pack]
		path_to_pack = path_to_pack.replace("//", "/")
		path_to_pack = path_to_pack.replace("/", "\\")
		Executor.exec_thread("sarc create %s %s.chpack" % [path_to_pack, path_to_pack])
		await Executor.finished_current_thread
		if not Executor.current_err == 0:
			%out.write_error("Failed to pack %s (exit status %s)" % [character_to_pack, Executor.current_err])
		else:
			%out.write_success("Successfully packed %s to %s.chpack" % [character_to_pack, character_to_pack])
	$window/options/character/select.get_popup().index_pressed.connect(char_selected)
	$window/options/character/pack.pressed.connect(pack)
	
	# character2
	var char2_selected: Callable = func(id: int) -> void:
		character_to_unpack = "%s.chpack" % $window/options/character2/select.get_popup().get_item_text(id)
		$window/options/character2/select.text = character_to_unpack.replace(".chpack", "")
		$window/options/character2/unpack.disabled = false
	var unpack: Callable = func() -> void:
		%out.write_regular("Unpacking %s..." % character_to_unpack)
		var path_to_unpack: String = "%s/MyStuff/Characters/%s" % [ctgp7_path, character_to_unpack]
		path_to_unpack = path_to_unpack.replace("//", "/")
		path_to_unpack = path_to_unpack.replace("/", "\\")
		Executor.exec_thread("sarc extract %s" % path_to_unpack)
		await Executor.finished_current_thread
		if not Executor.current_err == 0:
			%out.write_error("Failed to unpack %s (exit status %s). This is most-likely due to the ChPack lacking file names. If this is your ChPack, please repack it using this GUI to ensure compatibility." % [character_to_unpack, Executor.current_err])
		else:
			%out.write_success("Successfully unpacked %s to %s" % [character_to_unpack, character_to_unpack.replace(".chpack", "")])
	$window/options/character2/select.get_popup().index_pressed.connect(char2_selected)
	$window/options/character2/unpack.pressed.connect(unpack)
