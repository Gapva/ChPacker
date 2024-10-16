extends Panel

func write_regular(text: String) -> void:
	print(text)
	$label.append_text("[color=white]%s[/color]\n" % text)

func write_error(text: String) -> void:
	print("[ERROR] %s" % text)
	$label.append_text("[color=salmon][ERROR] %s[/color]\n" % text)

func write_success(text: String) -> void:
	print(text)
	$label.append_text("[color=mediumspringgreen]%s[/color]\n" % text)

func write_warning(text: String) -> void:
	print("[WARNING] %s" % text)
	$label.append_text("[color=khaki][WARNING] %s[/color]\n" % text)

func write_note(text: String) -> void:
	print("[NOTE] %s" % text)
	$label.append_text("[color=lightskyblue][NOTE] %s[/color]\n" % text)
