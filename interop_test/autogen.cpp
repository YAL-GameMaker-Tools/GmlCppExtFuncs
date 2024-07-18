#include "gml_ext.h"
#include "gml_extm.h"
#include "interop_test.h"
// Struct forward declarations:
// from test_gml_ptr.cpp:3:
struct iq_thing;
// from test_struct.cpp:3:
struct _iq_get_struct_vec {
	int ind;
	char name[4];
};
// from test_struct.cpp:17:
struct mixed_sub {
	int a, b;
};
// from test_struct.cpp:20:
struct mixed {
	int num;
	const char* str;
	uint8_t grid[3][3];
	mixed_sub sub[2];
};
#if 0

extern void iq_never();
dllx double iq_never_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	iq_never();
	return 1;
}

#endif // 0

extern int iq_get_int();
dllx double iq_get_int_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	return iq_get_int();
}

extern int64_t iq_get_int64();
dllx double iq_get_int64_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int64_t _result = iq_get_int64();
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_result);
	return 1;
}

extern const char* iq_get_string();
dllx const char* iq_get_string_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	return iq_get_string();
}

extern int64_t iq_add_int64(int64_t a, int64_t b);
dllx double iq_add_int64_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int64_t _arg_a = _in.read<int64_t>();
	int64_t _arg_b;
	if (_in.read<bool>()) {
		_arg_b = _in.read<int64_t>();
	} else _arg_b = 0;
	int64_t _result = iq_add_int64(_arg_a, _arg_b);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_result);
	return 1;
}

extern std::optional<int> iq_inc_opt_int(std::optional<int> i);
dllx double iq_inc_opt_int_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	std::optional<int> _a_i;if (_in.read<bool>()) {
		_a_i = _in.read<int>();
	} else _a_i = {};
	std::optional<int> _arg_i = _a_i;
	std::optional<int> _result = iq_inc_opt_int(_arg_i);
	gml_ostream _out(_inout_ptr);
	auto& _r = _result;
	if (_r.has_value()) {
		_out.write<bool>(true);
		_out.write<int>(_r.value());
		
	} else _out.write<bool>(false);
	return 1;
}

extern int iq_def_ret_int();
dllx double iq_def_ret_int_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _result = iq_def_ret_int();
	gml_ostream _out(_inout_ptr);
	_out.write<int>(_result);
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
	_out.write_string(iq_def_ret_string_raw_vec);
	return 1;
}

extern int iq_add_strlens(const char* a, const char* b, const char* c, const char* d);
dllx double iq_add_strlens_raw(void* _in_ptr, double _in_ptr_size, const char* _arg_a, const char* _arg_b) {
	gml_istream _in(_in_ptr);
	const char* _arg_c = _in.read_string();
	const char* _arg_d = _in.read_string();
	return iq_add_strlens(_arg_a, _arg_b, _arg_c, _arg_d);
}

extern int iq_get_buffer_sum(gml_buffer buf);
dllx double iq_get_buffer_sum_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_buffer _arg_buf = _in.read_gml_buffer();
	return iq_get_buffer_sum(_arg_buf);
}

extern gml_id<iq_id> iq_id_create();
dllx double iq_id_create_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	gml_id<iq_id> _result = iq_id_create();
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((int64_t)_result);
	return 1;
}

extern int iq_id_value(gml_id<iq_id> id);
dllx double iq_id_value_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id<iq_id> _arg_id = (gml_id<iq_id>)_in.read<int64_t>();;
	return iq_id_value(_arg_id);
}

extern void iq_id_destroy(gml_id_destroy<iq_id> id);
dllx double iq_id_destroy_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_id_destroy<iq_id> _arg_id = (gml_id_destroy<iq_id>)_in.read<int64_t>();;
	iq_id_destroy(_arg_id);
	return 1;
}

extern gml_ptr<iq_thing> iq_thing_create(int count);
dllx double iq_thing_create_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	int _arg_count = _in.read<int>();
	gml_ptr<iq_thing> _result = iq_thing_create(_arg_count);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>((intptr_t)_result);
	return 1;
}

extern void iq_thing_destroy(gml_ptr_destroy<iq_thing> thing);
dllx double iq_thing_destroy_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr_destroy<iq_thing> _arg_thing = (gml_ptr_destroy<iq_thing>)_in.read<int64_t>();;
	iq_thing_destroy(_arg_thing);
	return 1;
}

extern int iq_thing_get_count(gml_ptr<iq_thing> thing);
dllx double iq_thing_get_count_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr<iq_thing> _arg_thing = (gml_ptr<iq_thing>)_in.read<int64_t>();;
	return iq_thing_get_count(_arg_thing);
}

extern void iq_thing_set_count(gml_ptr<iq_thing> thing, int count);
dllx double iq_thing_set_count_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	gml_ptr<iq_thing> _arg_thing = (gml_ptr<iq_thing>)_in.read<int64_t>();;
	int _arg_count = _in.read<int>();
	iq_thing_set_count(_arg_thing, _arg_count);
	return 1;
}

extern std::vector<_iq_get_struct_vec> iq_get_struct_vec();
static std::vector<_iq_get_struct_vec> iq_get_struct_vec_raw_vec;
dllx double iq_get_struct_vec_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	iq_get_struct_vec_raw_vec = iq_get_struct_vec();
	return (double)(4 + iq_get_struct_vec_raw_vec.size() * sizeof(_iq_get_struct_vec));
}
dllx double iq_get_struct_vec_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	auto& _r = iq_get_struct_vec_raw_vec;
	auto _r_n = _r.size();
	_out.write<uint32_t>((uint32_t)_r_n);
	for (auto _r_i = 0u; _r_i < _r_n; _r_i++) {
		auto& _r_v = _r[_r_i];
		_out.write<int>(_r_v.ind);
		for (auto _r_v_i0 = 0u; _r_v_i0 < 4; _r_v_i0++) {
			_out.write<char>(_r_v.name[_r_v_i0]);
		}
	}
	return 1;
}

extern mixed iq_mixed(mixed q);
static mixed iq_mixed_raw_vec;
dllx double iq_mixed_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	mixed _a_q;
	_a_q.num = _in.read<int>();
	_a_q.str = _in.read_string();
	for (auto _a_q_i0 = 0u; _a_q_i0 < 3; _a_q_i0++) {
		for (auto _a_q_i1 = 0u; _a_q_i1 < 3; _a_q_i1++) {
			_a_q.grid[_a_q_i0][_a_q_i1] = _in.read<uint8_t>();
		}
	}
	for (auto _a_q_i0 = 0u; _a_q_i0 < 2; _a_q_i0++) {
		mixed_sub _a_q_f_sub;
		_a_q_f_sub.a = _in.read<int>();
		_a_q_f_sub.b = _in.read<int>();
		_a_q.sub[_a_q_i0] = _a_q_f_sub;
	}
	mixed _arg_q = _a_q;
	iq_mixed_raw_vec = iq_mixed(_arg_q);
	return (double)((4 + 1 + strlen(iq_mixed_raw_vec.str) + 9 + 16));
}
dllx double iq_mixed_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	auto& _r = iq_mixed_raw_vec;
	_out.write<int>(_r.num);
	_out.write_string(_r.str);
	for (auto _r_i0 = 0u; _r_i0 < 3; _r_i0++) {
		for (auto _r_i1 = 0u; _r_i1 < 3; _r_i1++) {
			_out.write<uint8_t>(_r.grid[_r_i0][_r_i1]);
		}
	}
	for (auto _r_i0 = 0u; _r_i0 < 2; _r_i0++) {
		auto& _r_f_sub = _r.sub[_r_i0];
		_out.write<int>(_r_f_sub.a);
		_out.write<int>(_r_f_sub.b);
	}
	return 1;
}

extern std::tuple<int64_t, int64_t> iq_get_int64_pair();
dllx double iq_get_int64_pair_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	std::tuple<int64_t, int64_t> _result = iq_get_int64_pair();
	gml_ostream _out(_inout_ptr);
	auto& _r = _result;
	_out.write<int64_t>(std::get<0>(_r));
	_out.write<int64_t>(std::get<1>(_r));
	return 1;
}

extern int64_t iq_int64_pair_sum(std::tuple<int64_t, int64_t> pair);
dllx double iq_int64_pair_sum_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	std::tuple<int64_t, int64_t> _a_pair; {
		int64_t _a_pair_t0 = _in.read<int64_t>();
		int64_t _a_pair_t1 = _in.read<int64_t>();
		_a_pair = { _a_pair_t0, _a_pair_t1 };
	}
	std::tuple<int64_t, int64_t> _arg_pair = _a_pair;
	int64_t _result = iq_int64_pair_sum(_arg_pair);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_result);
	return 1;
}

extern std::tuple<int64_t, int64_t> iq_int64_pair_swap(std::tuple<int64_t, int64_t> pair);
dllx double iq_int64_pair_swap_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	std::tuple<int64_t, int64_t> _a_pair; {
		int64_t _a_pair_t0 = _in.read<int64_t>();
		int64_t _a_pair_t1 = _in.read<int64_t>();
		_a_pair = { _a_pair_t0, _a_pair_t1 };
	}
	std::tuple<int64_t, int64_t> _arg_pair = _a_pair;
	std::tuple<int64_t, int64_t> _result = iq_int64_pair_swap(_arg_pair);
	gml_ostream _out(_inout_ptr);
	auto& _r = _result;
	_out.write<int64_t>(std::get<0>(_r));
	_out.write<int64_t>(std::get<1>(_r));
	return 1;
}

extern std::tuple<int64_t, int64_t> iq_get_int64_pair_vec_sum(std::vector<std::tuple<int64_t, int64_t>> arr);
dllx double iq_get_int64_pair_vec_sum_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	auto _a_arr_n = _in.read<uint32_t>();
	std::vector<std::tuple<int64_t, int64_t>> _a_arr(_a_arr_n);
	for (auto _a_arr_i = 0u; _a_arr_i < _a_arr_n; _a_arr_i++) {
		std::tuple<int64_t, int64_t> _a_arr_v; {
			int64_t _a_arr_v_t0 = _in.read<int64_t>();
			int64_t _a_arr_v_t1 = _in.read<int64_t>();
			_a_arr_v = { _a_arr_v_t0, _a_arr_v_t1 };
		}
		_a_arr[_a_arr_i] = _a_arr_v;
	}
	std::vector<std::tuple<int64_t, int64_t>> _arg_arr = _a_arr;
	std::tuple<int64_t, int64_t> _result = iq_get_int64_pair_vec_sum(_arg_arr);
	gml_ostream _out(_inout_ptr);
	auto& _r = _result;
	_out.write<int64_t>(std::get<0>(_r));
	_out.write<int64_t>(std::get<1>(_r));
	return 1;
}

extern std::vector<int64_t> iq_get_vec();
static std::vector<int64_t> iq_get_vec_raw_vec;
dllx double iq_get_vec_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	iq_get_vec_raw_vec = iq_get_vec();
	return (double)(4 + iq_get_vec_raw_vec.size() * sizeof(int64_t));
}
dllx double iq_get_vec_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	auto& _r = iq_get_vec_raw_vec;
	auto _r_n = _r.size();
	_out.write<uint32_t>((uint32_t)_r_n);
	for (auto _r_i = 0u; _r_i < _r_n; _r_i++) {
		_out.write<int64_t>(_r[_r_i]);
	}
	return 1;
}

extern std::optional<std::vector<int64_t>> iq_get_opt_vec(bool ret);
static std::optional<std::vector<int64_t>> iq_get_opt_vec_raw_vec;
dllx double iq_get_opt_vec_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	bool _arg_ret = _in.read<bool>();
	iq_get_opt_vec_raw_vec = iq_get_opt_vec(_arg_ret);
	return (double)(iq_get_opt_vec_raw_vec.has_value() ? 1 + (4 + iq_get_opt_vec_raw_vec.value().size() * sizeof(int64_t)) : 1);
}
dllx double iq_get_opt_vec_raw_post(void* _out_ptr, double _out_ptr_size) {
	gml_ostream _out(_out_ptr);
	auto& _r = iq_get_opt_vec_raw_vec;
	if (_r.has_value()) {
		_out.write<bool>(true);
		auto& _r_v = _r.value();
		auto _r_v_n = _r_v.size();
		_out.write<uint32_t>((uint32_t)_r_v_n);
		for (auto _r_v_i = 0u; _r_v_i < _r_v_n; _r_v_i++) {
			_out.write<int64_t>(_r_v[_r_v_i]);
		}
		
	} else _out.write<bool>(false);
	return 1;
}

extern int64_t iq_get_int64_vec_sum(std::vector<int64_t> arr);
dllx double iq_get_int64_vec_sum_raw(void* _inout_ptr, double _inout_ptr_size) {
	gml_istream _in(_inout_ptr);
	auto _a_arr_n = _in.read<uint32_t>();
	std::vector<int64_t> _a_arr(_a_arr_n);
	for (auto _a_arr_i = 0u; _a_arr_i < _a_arr_n; _a_arr_i++) {
		_a_arr[_a_arr_i] = _in.read<int64_t>();
	}
	std::vector<int64_t> _arg_arr = _a_arr;
	int64_t _result = iq_get_int64_vec_sum(_arg_arr);
	gml_ostream _out(_inout_ptr);
	_out.write<int64_t>(_result);
	return 1;
}

extern int iq_get_length_of_strings(std::vector<const char*> strings);
dllx double iq_get_length_of_strings_raw(void* _in_ptr, double _in_ptr_size) {
	gml_istream _in(_in_ptr);
	auto _a_strings_n = _in.read<uint32_t>();
	std::vector<const char*> _a_strings(_a_strings_n);
	for (auto _a_strings_i = 0u; _a_strings_i < _a_strings_n; _a_strings_i++) {
		_a_strings[_a_strings_i] = _in.read_string();
	}
	std::vector<const char*> _arg_strings = _a_strings;
	return iq_get_length_of_strings(_arg_strings);
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

