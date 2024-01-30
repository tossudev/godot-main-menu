extends RichTextLabel


func _on_meta_clicked(meta: Variant):
	OS.shell_open(meta)
