extends Node

var current_err: int = 0

signal finished_current_thread

func exec_thread(cmd: String) -> void:
	var thread: Thread = Thread.new()
	thread.start(exec.bind(cmd))

func exec(cmd: String) -> void:
	var base: String = cmd.split(" ")[0]
	var args: PackedStringArray = cmd.split(" ").slice(1)
	current_err = OS.execute(base, args)
	call_deferred("emit_finished_signal")

func emit_finished_signal() -> void:
	finished_current_thread.emit()
