#include "gml_ext.h"
// Struct forward declarations:
// from interop_test.cpp:28:
struct _iq_get_struct_vec {
	int ind;
	char name[4];
};
// from interop_test.cpp:78:
struct iq_thing;
extern int iq_get_int();
dllx double iq_get_int_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	return iq_get_int();
}

extern int64_t iq_get_int64();
dllx double iq_get_int64_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int64_t _ret = iq_get_int64();
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern const char* iq_get_string();
dllx const char* iq_get_string_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	return iq_get_string();
}

extern vector<int64_t> iq_get_vec();
static vector<int64_t> iq_get_vec_raw_vec;
dllx double iq_get_vec_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	iq_get_vec_raw_vec = iq_get_vec();
	return (double)(4 + iq_get_vec_raw_vec.size() * sizeof(int64_t));
}
dllx double iq_get_vec_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	_out.write_vector<int64_t>(iq_get_vec_raw_vec);
	return 1;
}

extern std::optional<vector<int64_t>> iq_get_opt_vec(bool ret);
static std::optional<vector<int64_t>> iq_get_opt_vec_raw_vec;
dllx double iq_get_opt_vec_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	bool _arg_ret;
	_arg_ret = _in.read<bool>();
	iq_get_opt_vec_raw_vec = iq_get_opt_vec(_arg_ret);
	return (double)(iq_get_opt_vec_raw_vec.has_value() ? 1 + (4 + iq_get_opt_vec_raw_vec.value().size() * sizeof(int64_t)) : 1);
}
dllx double iq_get_opt_vec_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	{
		auto& _opt = iq_get_opt_vec_raw_vec;
		if (_opt.has_value()) {
			_out.write<bool>(true);
			_out.write_vector<int64_t>(_opt.value());
			
		} else _out.write<bool>(false);
		
	}
	return 1;
}

extern vector<_iq_get_struct_vec> iq_get_struct_vec();
static vector<_iq_get_struct_vec> iq_get_struct_vec_raw_vec;
dllx double iq_get_struct_vec_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	iq_get_struct_vec_raw_vec = iq_get_struct_vec();
	return (double)(4 + iq_get_struct_vec_raw_vec.size() * sizeof(_iq_get_struct_vec));
}
dllx double iq_get_struct_vec_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	_out.write_vector<_iq_get_struct_vec>(iq_get_struct_vec_raw_vec);
	return 1;
}

extern tuple<int64_t, int64_t> iq_get_two_int64s();
dllx double iq_get_two_int64s_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	tuple<int64_t, int64_t> _ret = iq_get_two_int64s();
	gml_ostream _out(_inout_ptr);
	_out.write_tuple<int64_t, int64_t>(_ret);
	return 1;
}

extern int64_t iq_add_int64(int64_t a, int64_t b);
dllx double iq_add_int64_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int64_t _arg_a;
	_arg_a = _in.read<int64_t>();
	int64_t _arg_b;
	_arg_b = _in.read<int64_t>();
	int64_t _ret = iq_add_int64(_arg_a, _arg_b);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern int64_t iq_add_two_int64s(tuple<int64_t, int64_t> tup);
dllx double iq_add_two_int64s_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	tuple<int64_t, int64_t> _arg_tup;
	_arg_tup = _in.read_tuple<int64_t, int64_t>();;
	int64_t _ret = iq_add_two_int64s(_arg_tup);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern int64_t iq_get_int64_vec_sum(vector<int64_t> arr);
dllx double iq_get_int64_vec_sum_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	vector<int64_t> _arg_arr;
	_arg_arr = _in.read_vector<int64_t>();
	int64_t _ret = iq_get_int64_vec_sum(_arg_arr);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern int iq_get_length_of_strings(vector<const char*> strings);
dllx double iq_get_length_of_strings_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	vector<const char*> _arg_strings;
	_arg_strings = _in.read_string_vector();
	return iq_get_length_of_strings(_arg_strings);
}

extern int iq_get_buffer_sum(gml_buffer buf);
dllx double iq_get_buffer_sum_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_buffer _arg_buf;
	_arg_buf = _in.read_gml_buffer();
	return iq_get_buffer_sum(_arg_buf);
}

extern gml_ptr<iq_thing> iq_thing_create(int count);
dllx double iq_thing_create_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _arg_count;
	_arg_count = _in.read<int>();
	gml_ptr<iq_thing> _ret = iq_thing_create(_arg_count);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((intptr_t)_ret);
	return 1;
}

extern void iq_thing_destroy(gml_ptr_destroy<iq_thing> thing);
dllx double iq_thing_destroy_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr_destroy<iq_thing> _arg_thing;
	_arg_thing = (gml_ptr_destroy<iq_thing>)_in.read<int64_t>();;
	iq_thing_destroy(_arg_thing);
	return 1;
}

extern int iq_thing_get_count(gml_ptr<iq_thing> thing);
dllx double iq_thing_get_count_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr<iq_thing> _arg_thing;
	_arg_thing = (gml_ptr<iq_thing>)_in.read<int64_t>();;
	return iq_thing_get_count(_arg_thing);
}

extern void iq_thing_set_count(gml_ptr<iq_thing> thing, int count);
dllx double iq_thing_set_count_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr<iq_thing> _arg_thing;
	_arg_thing = (gml_ptr<iq_thing>)_in.read<int64_t>();;
	int _arg_count;
	_arg_count = _in.read<int>();
	iq_thing_set_count(_arg_thing, _arg_count);
	return 1;
}

extern int iq_def_ret_int();
dllx double iq_def_ret_int_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _ret = iq_def_ret_int();
	gml_ostream _out(_inout_ptr);
	_out.write<int>(_ret);
	return 1;
}

extern const char* iq_def_ret_string();
static const char* iq_def_ret_string_raw_vec;
dllx double iq_def_ret_string_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	iq_def_ret_string_raw_vec = iq_def_ret_string();
	return (double)(1 + strlen(iq_def_ret_string_raw_vec));
}
dllx double iq_def_ret_string_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	_out.write<const char*>(iq_def_ret_string_raw_vec);
	return 1;
}

extern int iq_add_strlens(const char* a, const char* b, const char* c, const char* d);
dllx double iq_add_strlens_raw(void* _in_ptr, double _in_ptr_size, const char* _arg_a, const char* _arg_b, const char* _arg_c, const char* _arg_d) {
	gml_istream _in(_in_ptr);
	return iq_add_strlens(_arg_a, _arg_b, _arg_c, _arg_d);
}

