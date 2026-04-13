extends Control


func _process(_delta: float) -> void:
	# ============ NÃO TROCAR O CUSOR ============
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	# ============================================


# ========== VER SE PODE MOVER O ITEM ==========
var data_bk
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		if not is_drag_successful():
			if data_bk:
				data_bk.show()
				data_bk = null
# ==============================================
