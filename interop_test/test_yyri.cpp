#include "stdafx.h"
#include "gml_ext.h"
#include "gml_extm.h"

static YYRunnerInterface g_YYRunnerInterface{};
YYRunnerInterface* g_pYYRunnerInterface;
dllm void YYExtensionInitialise(const struct YYRunnerInterface* _struct, size_t _size) {
	if (_size < sizeof(YYRunnerInterface)) {
		memcpy(&g_YYRunnerInterface, _struct, _size);
	} else {
		memcpy(&g_YYRunnerInterface, _struct, sizeof(YYRunnerInterface));
	}
	g_pYYRunnerInterface = &g_YYRunnerInterface;
}

dllgm int im_get_int() {
	return 1;
}
dllgm const char* im_get_string() {
	return "wow";
}
dllgm void im_get_result(YYResult& result) {
	YYCreateString(&result, "result");
}

dllgm int im_add_ints(int a, int b) {
	return a + b;
}
dllgm int im_add_rest(YYRest values) {
	auto result = 0;
	for (int i = 0; i < values.length; i++) {
		int v; if (values[i].tryGetInt(v)) result += v;
	}
	return result;
}

dllgm int64_t im_ptr_to_int64(void* ptr) {
	return (int64_t)ptr;
}

dllgm int im_string_length(const char* str) {
	return (int)strlen(str);
}

dllgm const char* im_typeof(RValue* val) {
	return KIND_NAME_RValue(val);
}