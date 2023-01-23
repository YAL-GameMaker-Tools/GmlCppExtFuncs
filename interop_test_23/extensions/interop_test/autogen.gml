#define iq_never
/// iq_never()
var _buf = itr_test_prepare_buffer(1);
iq_never_raw(buffer_get_address(_buf), ptr(1));

#define iq_get_int
/// iq_get_int()->int
var _buf = itr_test_prepare_buffer(1);
return iq_get_int_raw(buffer_get_address(_buf), ptr(1));

#define iq_get_int64
/// iq_get_int64()->int
var _buf = itr_test_prepare_buffer(8);
if (iq_get_int64_raw(buffer_get_address(_buf), ptr(8))) {
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_get_string
/// iq_get_string()->string
var _buf = itr_test_prepare_buffer(1);
return iq_get_string_raw(buffer_get_address(_buf), ptr(1));

#define iq_get_vec
/// iq_get_vec()->array<int>
var _buf = itr_test_prepare_buffer(8);
var __size__ = iq_get_vec_raw(buffer_get_address(_buf), ptr(8));
if (__size__ == 0) return undefined;
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
iq_get_vec_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
var _len_0 = buffer_read(_buf, buffer_u32);
var _arr_0 = array_create(_len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
	_arr_0[_ind_0] = buffer_read(_buf, buffer_u64);
}
return _arr_0;

#define iq_get_opt_vec
/// iq_get_opt_vec(ret:bool)->array<int>?
var _buf = itr_test_prepare_buffer(9);
buffer_write(_buf, buffer_bool, argument0);
var __size__ = iq_get_opt_vec_raw(buffer_get_address(_buf), ptr(9));
if (__size__ == 0) return undefined;
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
iq_get_opt_vec_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);

var _val_0;
if (buffer_read(_buf, buffer_bool)) {
	var _len_1 = buffer_read(_buf, buffer_u32);
	var _arr_1 = array_create(_len_1);
	for (var _ind_1 = 0; _ind_1 < _len_1; _ind_1++) {
		_arr_1[_ind_1] = buffer_read(_buf, buffer_u64);
	}_val_0 = _arr_1;
} else _val_0 = undefined;
return _val_0;

#define iq_get_struct_vec
/// iq_get_struct_vec()->array<any>
var _buf = itr_test_prepare_buffer(8);
var __size__ = iq_get_struct_vec_raw(buffer_get_address(_buf), ptr(8));
if (__size__ == 0) return undefined;
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
iq_get_struct_vec_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
// GMS >= 2.3:
if (iq_use_structs) {
	var _len_0 = buffer_read(_buf, buffer_u32);
	var _arr_0 = array_create(_len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
		var _struct_1 = {}; // _iq_get_struct_vec
		_struct_1.ind = buffer_read(_buf, buffer_s32);
		_struct_1.name = itr_test_read_chars(_buf, 4);
		_arr_0[_ind_0] = _struct_1;
	}
	return _arr_0;
} else //*/
{
	var _len_0 = buffer_read(_buf, buffer_u32);
	var _arr_0 = array_create(_len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
		var _struct_1 = array_create(2); // _iq_get_struct_vec
		_struct_1[0] = buffer_read(_buf, buffer_s32); // ind
		_struct_1[1] = itr_test_read_chars(_buf, 4); // name
		_arr_0[_ind_0] = _struct_1;
	}
	return _arr_0;
}

#define iq_get_two_int64s
/// iq_get_two_int64s()->
var _buf = itr_test_prepare_buffer(8);
if (iq_get_two_int64s_raw(buffer_get_address(_buf), ptr(8))) {var _tup_0 = array_create(2);
	_tup_0[0] = buffer_read(_buf, buffer_u64);
	_tup_0[1] = buffer_read(_buf, buffer_u64);
	
	return _tup_0;
} else return undefined;

#define iq_add_int64
/// iq_add_int64(a:int, b:int)->int
var _buf = itr_test_prepare_buffer(16);
buffer_write(_buf, buffer_u64, argument0);
buffer_write(_buf, buffer_u64, argument1);
if (iq_add_int64_raw(buffer_get_address(_buf), ptr(16))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_add_two_int64s
/// iq_add_two_int64s(tup)->int
var _buf = itr_test_prepare_buffer(8);
var _tup_0 = argument0;
buffer_write(_buf, buffer_u64, _tup_0[0]);
buffer_write(_buf, buffer_u64, _tup_0[1]);
if (iq_add_two_int64s_raw(buffer_get_address(_buf), ptr(8))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_get_int64_vec_sum
/// iq_get_int64_vec_sum(arr:array<int>)->int
var _buf = itr_test_prepare_buffer(8);
var _arr_0 = argument0;
var _len_0 = array_length_1d(_arr_0);
buffer_write(_buf, buffer_u32, _len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
	buffer_write(_buf, buffer_u64, _arr_0[_ind_0]);
}
if (iq_get_int64_vec_sum_raw(buffer_get_address(_buf), ptr(8))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_get_length_of_strings
/// iq_get_length_of_strings(strings:array<string>)->int
var _buf = itr_test_prepare_buffer(8);
var _arr_0 = argument0;
var _len_0 = array_length_1d(_arr_0);
buffer_write(_buf, buffer_u32, _len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
	buffer_write(_buf, buffer_string, _arr_0[_ind_0]);
}
return iq_get_length_of_strings_raw(buffer_get_address(_buf), ptr(8));

#define iq_get_buffer_sum
/// iq_get_buffer_sum(buf:buffer)->int
var _buf = itr_test_prepare_buffer(16);
var _val_0 = argument0;
if (buffer_exists(_val_0)) {
	buffer_write(_buf, buffer_u64, int64(buffer_get_address(_val_0)));
	buffer_write(_buf, buffer_s32, buffer_get_size(_val_0));
	buffer_write(_buf, buffer_s32, buffer_tell(_val_0));
} else {
	buffer_write(_buf, buffer_u64, 0);
	buffer_write(_buf, buffer_s32, 0);
	buffer_write(_buf, buffer_s32, 0);
}
return iq_get_buffer_sum_raw(buffer_get_address(_buf), ptr(16));

#define iq_thing_create
/// iq_thing_create(count:int)->
var _buf = itr_test_prepare_buffer(8);
buffer_write(_buf, buffer_s32, argument0);
if (iq_thing_create_raw(buffer_get_address(_buf), ptr(8))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	// GMS >= 2.3:
	if (iq_use_structs) {
		var _box_0 = new iq_thing(ptr(buffer_read(_buf, buffer_u64)));
		return _box_0;
	} else //*/
	{
		var _box_0 = array_create(2);
		_box_0[0] = global.__ptrt_iq_thing;
		_box_0[1] = ptr(buffer_read(_buf, buffer_u64));
		return _box_0;
	}
} else return undefined;

#define iq_thing_destroy
/// iq_thing_destroy(thing)
var _buf = itr_test_prepare_buffer(8);
// GMS >= 2.3:
if (iq_use_structs) {
	var _box_0 = argument0;
	if (instanceof(_box_0) != "iq_thing") { show_error("Expected a iq_thing, got " + string(_box_0), true); exit }
	var _ptr_0 = _box_0.__ptr__;
	if (_ptr_0 == 0) { show_error("This iq_thing is destroyed.", true); exit; }
	_box_0.__ptr__ = ptr(0);
	buffer_write(_buf, buffer_u64, int64(_ptr_0));
} else //*/
{
	var _box_0 = argument0;
	if (!is_array(_box_0) || _box_0[0] != global.__ptrt_iq_thing) { show_error("Expected a iq_thing, got " + string(_box_0), true); exit }
	var _ptr_0 = _box_0[1];
	if (_ptr_0 == 0) { show_error("This iq_thing is destroyed.", true); exit; }
	_box_0[@1] = ptr(0);
	buffer_write(_buf, buffer_u64, int64(_ptr_0));
}
iq_thing_destroy_raw(buffer_get_address(_buf), ptr(8));

#define iq_thing_get_count
/// iq_thing_get_count(thing)->int
var _buf = itr_test_prepare_buffer(8);
// GMS >= 2.3:
if (iq_use_structs) {
	var _box_0 = argument0;
	if (instanceof(_box_0) != "iq_thing") { show_error("Expected a iq_thing, got " + string(_box_0), true); exit }
	var _ptr_0 = _box_0.__ptr__;
	if (_ptr_0 == 0) { show_error("This iq_thing is destroyed.", true); exit; }
	buffer_write(_buf, buffer_u64, int64(_ptr_0));
} else //*/
{
	var _box_0 = argument0;
	if (!is_array(_box_0) || _box_0[0] != global.__ptrt_iq_thing) { show_error("Expected a iq_thing, got " + string(_box_0), true); exit }
	var _ptr_0 = _box_0[1];
	if (_ptr_0 == 0) { show_error("This iq_thing is destroyed.", true); exit; }
	buffer_write(_buf, buffer_u64, int64(_ptr_0));
}
return iq_thing_get_count_raw(buffer_get_address(_buf), ptr(8));

#define iq_thing_set_count
/// iq_thing_set_count(thing, count:int)
var _buf = itr_test_prepare_buffer(12);
// GMS >= 2.3:
if (iq_use_structs) {
	var _box_0 = argument0;
	if (instanceof(_box_0) != "iq_thing") { show_error("Expected a iq_thing, got " + string(_box_0), true); exit }
	var _ptr_0 = _box_0.__ptr__;
	if (_ptr_0 == 0) { show_error("This iq_thing is destroyed.", true); exit; }
	buffer_write(_buf, buffer_u64, int64(_ptr_0));
	buffer_write(_buf, buffer_s32, argument1);
} else //*/
{
	var _box_0 = argument0;
	if (!is_array(_box_0) || _box_0[0] != global.__ptrt_iq_thing) { show_error("Expected a iq_thing, got " + string(_box_0), true); exit }
	var _ptr_0 = _box_0[1];
	if (_ptr_0 == 0) { show_error("This iq_thing is destroyed.", true); exit; }
	buffer_write(_buf, buffer_u64, int64(_ptr_0));
	buffer_write(_buf, buffer_s32, argument1);
}
iq_thing_set_count_raw(buffer_get_address(_buf), ptr(12));

#define iq_def_ret_int
/// iq_def_ret_int()->int
var _buf = itr_test_prepare_buffer(4);
if (iq_def_ret_int_raw(buffer_get_address(_buf), ptr(4))) {
	return buffer_read(_buf, buffer_s32);
} else return -3;

#define iq_def_ret_string
/// iq_def_ret_string()->string
var _buf = itr_test_prepare_buffer(8);
var __size__ = iq_def_ret_string_raw(buffer_get_address(_buf), ptr(8));
if (__size__ == 0) return "DLL is not loaded";
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
iq_def_ret_string_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);

return buffer_read(_buf, buffer_string);

#define iq_add_strlens
/// iq_add_strlens(a:string, b:string, c:string, d:string)->int
var _buf = itr_test_prepare_buffer(32);
buffer_write(_buf, buffer_string, argument2);
buffer_write(_buf, buffer_string, argument3);
return iq_add_strlens_raw(buffer_get_address(_buf), ptr(32), argument0, argument1);

