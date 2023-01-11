/// @author YellowAfterlife

#include "stdafx.h"
#include "gml_ext.h"

#define trace(...) { printf("[interop_test:%d] ", __LINE__); printf(__VA_ARGS__); printf("\n"); fflush(stdout); }

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
dllg vector<int64_t> iq_get_vec() {
	vector<int64_t> vec;
	for (int i = 1; i <= 3; i++) vec.push_back(i);
	return vec;
}
dllg std::optional<vector<int64_t>> iq_get_opt_vec(bool ret) {
	vector<int64_t> vec;
	for (int i = 1; i <= 3; i++) vec.push_back(i);
	if (!ret) return {};
	return vec;
}
struct _iq_get_struct_vec {
	int ind;
	char name[4];
};
dllg vector<_iq_get_struct_vec> iq_get_struct_vec() {
	vector<_iq_get_struct_vec> vec;
	vec.push_back({ 1, "one"});
	_iq_get_struct_vec two = { 2, "two" };
	two.name[3] = '-'; // non-NUL-terminated 
	vec.push_back(two);
	vec.push_back({ 3, "tri" });
	return vec;
}
dllg tuple<int64_t, int64_t> iq_get_two_int64s() {
	return tuple(1i64, 2i64);
}

dllg int64_t iq_add_int64(int64_t a, int64_t b) {
	return a + b;
}
dllg int64_t iq_add_two_int64s(tuple<int64_t, int64_t> tup) {
	return std::get<0>(tup) + std::get<1>(tup);
}

dllg int64_t iq_get_int64_vec_sum(vector<int64_t> arr) {
	int64_t sum = 0;
	for each (auto val in arr) {
		sum += val;
	}
	return sum;
}

dllg int iq_get_length_of_strings(vector<const char*> strings) {
	int sum = 0;
	for each (auto str in strings) {
		sum += strlen(str);
	}
	return sum;
}

dllg int iq_get_buffer_sum(gml_buffer buf) {
	int sum = 0;
	int till = buf.tell();
	auto data = buf.data();
	for (int i = 0; i < till; i++) {
		sum += data[i];
	}
	return sum;
}

struct iq_thing {
	int count;
};
dllg gml_ptr<iq_thing> iq_thing_create(int count) {
	auto thing = new iq_thing();
	thing->count = count;
	return thing;
}
dllg void iq_thing_destroy(gml_ptr_destroy<iq_thing> thing) {
	delete thing;
}
dllg int iq_thing_get_count(gml_ptr<iq_thing> thing) {
	return thing->count;
}
dllg void iq_thing_set_count(gml_ptr<iq_thing> thing, int count) {
	thing->count = count;
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
