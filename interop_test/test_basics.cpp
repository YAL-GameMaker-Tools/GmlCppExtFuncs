/// @author YellowAfterlife

#include "stdafx.h"

// @dllg:cond 0
dllg void iq_never() {}
// @dllg:cond

dllg int iq_get_int() {
	return 1;
}
dllg int64_t iq_get_int64() {
	return 0x123456789ABCDEFi64;
}
dllg const char* iq_get_string() {
	return "hi!";
}

dllg int64_t iq_add_int64(int64_t a, int64_t b = 0) {
	return a + b;
}

dllg std::optional<int> iq_inc_opt_int(std::optional<int> i) {
	if (i.has_value()) {
		return i.value() + 1;
	} else return {};
}

// @dllg:defValue -3
dllg int iq_def_ret_int() {
	return 3;
}

// @dllg:defValue "DLL is not loaded"
dllg const char* iq_def_ret_string() {
	return "OK!";
}

dllg int iq_add_strlens(const char* a, const char* b, const char* c, const char* d) {
	return strlen(a) + strlen(b) + strlen(c) + strlen(d);
}

