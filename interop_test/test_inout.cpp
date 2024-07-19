#include "stdafx.h"

struct iq_inoutish {
	int a, b;
	char text[32];
};
dllg void iq_test_inout_struct(gml_inout<iq_inoutish> q) {
	q.a += 1;
	strncpy(q.text, "Yeah!", std::size(q.text));
}
dllg void iq_test_inout_int_vector(gml_inout_vector<int> v) {
	for (auto i = 0u; i < v.size(); i++) {
		v[i] += 1;
	}
}
dllg void iq_test_inout_struct_vector(gml_inout_vector<iq_inoutish> v) {
	for (auto i = 0u; i < v.size(); i++) {
		v[i].a += 1;
	}
}