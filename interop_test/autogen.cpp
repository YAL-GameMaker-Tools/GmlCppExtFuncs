#include "gml_ext.h"
// Struct forward declarations:
struct _iq_get_struct_vec {
	int ind;
	char name[4];
};
extern int iq_get_int();
dllx double iq_get_int_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	return iq_get_int();
}

extern int64_t iq_get_int64();
dllx double iq_get_int64_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	int64_t __ret__ = iq_get_int64();
	_buf.write<int64_t>(__ret__);
	return 1;
}

extern const char* iq_get_string();
dllx const char* iq_get_string_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	return iq_get_string();
}

extern vector<int64_t> iq_get_vec();
static vector<int64_t> iq_get_vec_raw_vec;
dllx double iq_get_vec_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	iq_get_vec_raw_vec = iq_get_vec();
	return 4 + iq_get_vec_raw_vec.size() * /* sizeof(int64_t) */8;
}
dllx double iq_get_vec_raw_post(void* _ptr) {
	gml_buffer _buf(_ptr);
	_buf.write_vector<int64_t>(iq_get_vec_raw_vec);
	return 1;
}

extern vector<_iq_get_struct_vec> iq_get_struct_vec();
static vector<_iq_get_struct_vec> iq_get_struct_vec_raw_vec;
dllx double iq_get_struct_vec_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	iq_get_struct_vec_raw_vec = iq_get_struct_vec();
	return 4 + iq_get_struct_vec_raw_vec.size() * /* sizeof(_iq_get_struct_vec) */8;
}
dllx double iq_get_struct_vec_raw_post(void* _ptr) {
	gml_buffer _buf(_ptr);
	_buf.write_vector<_iq_get_struct_vec>(iq_get_struct_vec_raw_vec);
	return 1;
}

extern tuple<int64_t, int64_t> iq_get_two_int64s();
dllx double iq_get_two_int64s_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	tuple<int64_t, int64_t> __ret__ = iq_get_two_int64s();
	_buf.write_tuple<int64_t, int64_t>(__ret__);
	return 1;
}

extern int64_t iq_add_int64(int64_t a, int64_t b);
dllx double iq_add_int64_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	int64_t _arg_a;
	_arg_a = _buf.read<int64_t>();
	int64_t _arg_b;
	_arg_b = _buf.read<int64_t>();
	int64_t __ret__ = iq_add_int64(_arg_a, _arg_b);
	_buf.rewind();
	_buf.write<int64_t>(__ret__);
	return 1;
}

extern int64_t iq_add_two_int64s(tuple<int64_t, int64_t> tup);
dllx double iq_add_two_int64s_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	tuple<int64_t, int64_t> _arg_tup;
	_arg_tup = _buf.read_tuple<int64_t, int64_t>();;
	int64_t __ret__ = iq_add_two_int64s(_arg_tup);
	_buf.rewind();
	_buf.write<int64_t>(__ret__);
	return 1;
}

extern int64_t iq_get_int64_vec_sum(vector<int64_t> arr);
dllx double iq_get_int64_vec_sum_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	vector<int64_t> _arg_arr;
	_arg_arr = _buf.read_vector<int64_t>();
	int64_t __ret__ = iq_get_int64_vec_sum(_arg_arr);
	_buf.rewind();
	_buf.write<int64_t>(__ret__);
	return 1;
}

extern int64_t iq_get_int64_arr_sum(gml_vector<int64_t> arr);
dllx double iq_get_int64_arr_sum_raw(void* _ptr) {
	gml_buffer _buf(_ptr);
	gml_vector<int64_t> _arg_arr;
	_arg_arr = _buf.read_gml_vector<int64_t>();
	int64_t __ret__ = iq_get_int64_arr_sum(_arg_arr);
	_buf.rewind();
	_buf.write<int64_t>(__ret__);
	return 1;
}

