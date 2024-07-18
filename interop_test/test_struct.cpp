#include "stdafx.h"

struct _iq_get_struct_vec {
	int ind;
	char name[4];
};
dllg std::vector<_iq_get_struct_vec> iq_get_struct_vec() {
	std::vector<_iq_get_struct_vec> vec;
	vec.push_back({ 1, "one" });
	_iq_get_struct_vec two = { 2, "two" };
	two.name[3] = '-'; // non-NUL-terminated 
	vec.push_back(two);
	vec.push_back({ 3, "tri" });
	return vec;
}

struct mixed_sub {
	int a, b;
};
struct mixed {
	int num;
	const char* str;
	uint8_t grid[3][3];
	mixed_sub sub[2];
};

dllg mixed iq_mixed(mixed q) {
	return q;
}