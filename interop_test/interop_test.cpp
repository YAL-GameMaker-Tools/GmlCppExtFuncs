/// @author YellowAfterlife

#include "stdafx.h"
#include "gml_ext.h"

#define trace(...) { printf("[interop_test:%d] ", __LINE__); printf(__VA_ARGS__); printf("\n"); fflush(stdout); }

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
dllg int64_t iq_get_int64_arr_sum(gml_vector<int64_t> arr) {
	int64_t sum = 0;
	for each (auto val in arr) {
		sum += val;
	}
	return sum;
}
