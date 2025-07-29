function scr_test_hwnd() {
	assert(iq_get_hwnd(), int64(window_handle()));
}