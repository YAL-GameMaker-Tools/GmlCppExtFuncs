#include "gml_ext.h"
#include "gml_extm.h"
#include "interop_test.h"
// Struct forward declarations:
// from interop_test.cpp:32:
struct _iq_get_struct_vec {
	int ind;
	char name[4];
};
// from interop_test.cpp:82:
struct iq_thing;
#if 0

extern void iq_never();
dllx double iq_never_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	iq_never();
	return 1;
}

#endif // 0

extern int iq_get_int();
dllx double iq_get_int_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	return iq_get_int();
}

extern int64_t iq_get_int64();
dllx double iq_get_int64_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int64_t _ret = iq_get_int64();
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern const char* iq_get_string();
dllx const char* iq_get_string_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	return iq_get_string();
}

extern vector<int64_t> iq_get_vec();
static vector<int64_t> iq_get_vec_raw_vec;
dllx double iq_get_vec_raw(void* _in_ptr, void* _in_ptr_size) {
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
dllx double iq_get_opt_vec_raw(void* _in_ptr, void* _in_ptr_size) {
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
dllx double iq_get_struct_vec_raw(void* _in_ptr, void* _in_ptr_size) {
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
dllx double iq_get_two_int64s_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	tuple<int64_t, int64_t> _ret = iq_get_two_int64s();
	gml_ostream _out(_inout_ptr);
	_out.write_tuple<int64_t, int64_t>(_ret);
	return 1;
}

extern int64_t iq_add_int64(int64_t a, int64_t b);
dllx double iq_add_int64_raw(void* _inout_ptr, void* _inout_ptr_size) {
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
dllx double iq_add_two_int64s_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	tuple<int64_t, int64_t> _arg_tup;
	_arg_tup = _in.read_tuple<int64_t, int64_t>();;
	int64_t _ret = iq_add_two_int64s(_arg_tup);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern int64_t iq_get_int64_vec_sum(vector<int64_t> arr);
dllx double iq_get_int64_vec_sum_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	vector<int64_t> _arg_arr;
	_arg_arr = _in.read_vector<int64_t>();
	int64_t _ret = iq_get_int64_vec_sum(_arg_arr);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_ret);
	return 1;
}

extern int iq_get_length_of_strings(vector<const char*> strings);
dllx double iq_get_length_of_strings_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	vector<const char*> _arg_strings;
	_arg_strings = _in.read_string_vector();
	return iq_get_length_of_strings(_arg_strings);
}

extern int iq_get_buffer_sum(gml_buffer buf);
dllx double iq_get_buffer_sum_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_buffer _arg_buf;
	_arg_buf = _in.read_gml_buffer();
	return iq_get_buffer_sum(_arg_buf);
}

extern gml_ptr<iq_thing> iq_thing_create(int count);
dllx double iq_thing_create_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _arg_count;
	_arg_count = _in.read<int>();
	gml_ptr<iq_thing> _ret = iq_thing_create(_arg_count);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((intptr_t)_ret);
	return 1;
}

extern void iq_thing_destroy(gml_ptr_destroy<iq_thing> thing);
dllx double iq_thing_destroy_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr_destroy<iq_thing> _arg_thing;
	_arg_thing = (gml_ptr_destroy<iq_thing>)_in.read<int64_t>();;
	iq_thing_destroy(_arg_thing);
	return 1;
}

extern int iq_thing_get_count(gml_ptr<iq_thing> thing);
dllx double iq_thing_get_count_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr<iq_thing> _arg_thing;
	_arg_thing = (gml_ptr<iq_thing>)_in.read<int64_t>();;
	return iq_thing_get_count(_arg_thing);
}

extern void iq_thing_set_count(gml_ptr<iq_thing> thing, int count);
dllx double iq_thing_set_count_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr<iq_thing> _arg_thing;
	_arg_thing = (gml_ptr<iq_thing>)_in.read<int64_t>();;
	int _arg_count;
	_arg_count = _in.read<int>();
	iq_thing_set_count(_arg_thing, _arg_count);
	return 1;
}

extern gml_id<iq_id> iq_id_create();
dllx double iq_id_create_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_id<iq_id> _ret = iq_id_create();
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64)_ret);
	return 1;
}

extern int iq_id_value(gml_id<iq_id> id);
dllx double iq_id_value_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id<iq_id> _arg_id;
	_arg_id = (gml_id<iq_id>)_in.read<int64_t>();;
	return iq_id_value(_arg_id);
}

extern void iq_id_destroy(gml_id_destroy<iq_id> id);
dllx double iq_id_destroy_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id_destroy<iq_id> _arg_id;
	_arg_id = (gml_id_destroy<iq_id>)_in.read<int64_t>();;
	iq_id_destroy(_arg_id);
	return 1;
}

extern int iq_def_ret_int();
dllx double iq_def_ret_int_raw(void* _inout_ptr, void* _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _ret = iq_def_ret_int();
	gml_ostream _out(_inout_ptr);
	_out.write<int>(_ret);
	return 1;
}

extern const char* iq_def_ret_string();
static const char* iq_def_ret_string_raw_vec;
dllx double iq_def_ret_string_raw(void* _in_ptr, void* _in_ptr_size) {
	gml_istream _in(_in_ptr);
	iq_def_ret_string_raw_vec = iq_def_ret_string();
	return (double)(1 + strlen(iq_def_ret_string_raw_vec));
}
dllx double iq_def_ret_string_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	_out.write_string(iq_def_ret_string_raw_vec);
	return 1;
}

extern int iq_add_strlens(const char* a, const char* b, const char* c, const char* d);
dllx double iq_add_strlens_raw(void* _in_ptr, void* _in_ptr_size, const char* _arg_a, const char* _arg_b) {
	gml_istream _in(_in_ptr);
	const char* _arg_c;
	_arg_c = _in.read_string();
	const char* _arg_d;
	_arg_d = _in.read_string();
	return iq_add_strlens(_arg_a, _arg_b, _arg_c, _arg_d);
}

extern int im_get_int();
/// im_get_int()->
dllm void im_get_int_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "im_get_int"
	__YYArgCheck(0);
	int _result = im_get_int();
	__YYResult_int(_result);
	#undef __YYFUNCNAME__
}

extern const char* im_get_string();
/// im_get_string()->
dllm void im_get_string_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "im_get_string"
	__YYArgCheck(0);
	const char* _result = im_get_string();
	__YYResult_const_char_ptr(_result);
	#undef __YYFUNCNAME__
}

extern void im_get_result(YYResult& result);
/// im_get_result()->
dllm void im_get_result_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "im_get_result"
	__YYArgCheck(0);
	im_get_result(result);
	#undef __YYFUNCNAME__
}

extern int im_add_ints(int a, int b);
/// im_add_ints(a, b)->
dllm void im_add_ints_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "im_add_ints"
	__YYArgCheck(2);
	int _arg_a; __YYArg_int("a", _arg_a, 0);
	int _arg_b; __YYArg_int("b", _arg_b, 1);
	int _result = im_add_ints(_arg_a, _arg_b);
	__YYResult_int(_result);
	#undef __YYFUNCNAME__
}

extern int im_add_rest(YYRest values);
/// im_add_rest(...values)->
dllm void im_add_rest_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "im_add_rest"
	__YYArgCheck_any;
	YYRest _arg_values; __YYArg_YYRest("values", _arg_values, 0);
	int _result = im_add_rest(_arg_values);
	__YYResult_int(_result);
	#undef __YYFUNCNAME__
}

extern int64_t im_ptr_to_int64(void* ptr);
/// im_ptr_to_int64(ptr)->
dllm void im_ptr_to_int64_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "im_ptr_to_int64"
	__YYArgCheck(1);
	void* _arg_ptr; __YYArg_void_ptr("ptr", _arg_ptr, 0);
	int64_t _result = im_ptr_to_int64(_arg_ptr);
	__YYResult_int64_t(_result);
	#undef __YYFUNCNAME__
}

extern int im_string_length(const char* str);
/// im_string_length(str)->
dllm void im_string_length_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "im_string_length"
	__YYArgCheck(1);
	const char* _arg_str; __YYArg_const_char_ptr("str", _arg_str, 0);
	int _result = im_string_length(_arg_str);
	__YYResult_int(_result);
	#undef __YYFUNCNAME__
}

extern const char* im_typeof(RValue* val);
/// im_typeof(val)->
dllm void im_typeof_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "im_typeof"
	__YYArgCheck(1);
	RValue* _arg_val; __YYArg_RValue_ptr("val", _arg_val, 0);
	const char* _result = im_typeof(_arg_val);
	__YYResult_const_char_ptr(_result);
	#undef __YYFUNCNAME__
}

