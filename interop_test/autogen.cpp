#include "gml_ext.h"
// Struct forward declarations:
// from interop_test.cpp:22:
struct _iq_get_struct_vec {
	int ind;
	char name[4];
};
extern int iq_get_int();
dllx double iq_get_int_raw(void* _ptr) {
	gml_istream _in(_ptr);
	return iq_get_int();
}

extern int64_t iq_get_int64();
dllx double iq_get_int64_raw(void* _ptr) {
	gml_istream _in(_ptr);
	int64_t _ret = iq_get_int64();
	gml_ostream _out(_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern const char* iq_get_string();
dllx const char* iq_get_string_raw(void* _ptr) {
	gml_istream _in(_ptr);
	return iq_get_string();
}

extern vector<int64_t> iq_get_vec();
static vector<int64_t> iq_get_vec_raw_vec;
dllx double iq_get_vec_raw(void* _ptr) {
	gml_istream _in(_ptr);
	iq_get_vec_raw_vec = iq_get_vec();
	return (double)(4 + iq_get_vec_raw_vec.size() * sizeof(int64_t));
}
dllx double iq_get_vec_raw_post(void* _ptr) {
	gml_ostream _out(_ptr);
	_out.write_vector<int64_t>(iq_get_vec_raw_vec);
	return 1;
}

extern vector<_iq_get_struct_vec> iq_get_struct_vec();
static vector<_iq_get_struct_vec> iq_get_struct_vec_raw_vec;
dllx double iq_get_struct_vec_raw(void* _ptr) {
	gml_istream _in(_ptr);
	iq_get_struct_vec_raw_vec = iq_get_struct_vec();
	return (double)(4 + iq_get_struct_vec_raw_vec.size() * sizeof(_iq_get_struct_vec));
}
dllx double iq_get_struct_vec_raw_post(void* _ptr) {
	gml_ostream _out(_ptr);
	_out.write_vector<_iq_get_struct_vec>(iq_get_struct_vec_raw_vec);
	return 1;
}

extern tuple<int64_t, int64_t> iq_get_two_int64s();
dllx double iq_get_two_int64s_raw(void* _ptr) {
	gml_istream _in(_ptr);
	tuple<int64_t, int64_t> _ret = iq_get_two_int64s();
	gml_ostream _out(_ptr);
	_out.write_tuple<int64_t, int64_t>(_ret);
	return 1;
}

extern int64_t iq_add_int64(int64_t a, int64_t b);
dllx double iq_add_int64_raw(void* _ptr) {
	gml_istream _in(_ptr);
	int64_t _arg_a;
	_arg_a = _in.read<int64_t>();
	int64_t _arg_b;
	_arg_b = _in.read<int64_t>();
	int64_t _ret = iq_add_int64(_arg_a, _arg_b);
	gml_ostream _out(_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern int64_t iq_add_two_int64s(tuple<int64_t, int64_t> tup);
dllx double iq_add_two_int64s_raw(void* _ptr) {
	gml_istream _in(_ptr);
	tuple<int64_t, int64_t> _arg_tup;
	_arg_tup = _in.read_tuple<int64_t, int64_t>();;
	int64_t _ret = iq_add_two_int64s(_arg_tup);
	gml_ostream _out(_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern int64_t iq_get_int64_vec_sum(vector<int64_t> arr);
dllx double iq_get_int64_vec_sum_raw(void* _ptr) {
	gml_istream _in(_ptr);
	vector<int64_t> _arg_arr;
	_arg_arr = _in.read_vector<int64_t>();
	int64_t _ret = iq_get_int64_vec_sum(_arg_arr);
	gml_ostream _out(_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern int iq_get_length_of_strings(vector<const char*> strings);
dllx double iq_get_length_of_strings_raw(void* _ptr) {
	gml_istream _in(_ptr);
	vector<const char*> _arg_strings;
	_arg_strings = _in.read_string_vector();
	return iq_get_length_of_strings(_arg_strings);
}

extern int iq_get_buffer_sum(gml_buffer buf);
dllx double iq_get_buffer_sum_raw(void* _ptr) {
	gml_istream _in(_ptr);
	gml_buffer _arg_buf;
	_arg_buf = _in.read_gml_buffer();
	return iq_get_buffer_sum(_arg_buf);
}

