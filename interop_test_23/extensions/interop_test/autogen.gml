#define iq_get_int
/// iq_get_int()->int
var _buf = itr_test_prepare_buffer(1);
return iq_get_int_raw(buffer_get_address(_buf));

#define iq_get_int64
/// iq_get_int64()->int
var _buf = itr_test_prepare_buffer(8);
if (iq_get_int64_raw(buffer_get_address(_buf))) {
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_get_string
/// iq_get_string()->int
var _buf = itr_test_prepare_buffer(1);
return iq_get_string_raw(buffer_get_address(_buf));

#define iq_get_vec
/// iq_get_vec()->array<int>
var _buf = itr_test_prepare_buffer(8);
var __size__ = iq_get_vec_raw(buffer_get_address(_buf));
if (__size__ == 0) return undefined;
if (__size__ <= 4) return [];
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
iq_get_vec_raw_post(buffer_get_address(_buf));
buffer_seek(_buf, buffer_seek_start, 0);
var _len_0 = buffer_read(_buf, buffer_u32);
var _arr_0 = array_create(_len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
	_arr_0[_ind_0] = buffer_read(_buf, buffer_u64);
}
return _arr_0;

#define iq_get_struct_vec
/// iq_get_struct_vec()->array<any>
var _buf = itr_test_prepare_buffer(8);
var __size__ = iq_get_struct_vec_raw(buffer_get_address(_buf));
if (__size__ == 0) return undefined;
if (__size__ <= 4) return [];
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
iq_get_struct_vec_raw_post(buffer_get_address(_buf));
buffer_seek(_buf, buffer_seek_start, 0);
var _len_0 = buffer_read(_buf, buffer_u32);
var _arr_0 = array_create(_len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
	var _struct_1 = /* _iq_get_struct_vec */array_create(2);
	_struct_1[0/* ind */] = buffer_read(_buf, buffer_s32);
	_struct_1[1/* name */] = itr_test_read_chars(_buf, 4);
	_arr_0[_ind_0] = _struct_1;
}
return _arr_0;

#define iq_get_two_int64s
/// iq_get_two_int64s()->
var _buf = itr_test_prepare_buffer(8);
if (iq_get_two_int64s_raw(buffer_get_address(_buf))) {
	var _tup_0 = array_create(2);
	_tup_0[0] = buffer_read(_buf, buffer_u64);
	_tup_0[1] = buffer_read(_buf, buffer_u64);
	return _tup_0;
} else return undefined;

#define iq_add_int64
/// iq_add_int64(a:int, b:int)->int
var _buf = itr_test_prepare_buffer(16);
buffer_write(_buf, buffer_u64, argument0);
buffer_write(_buf, buffer_u64, argument1);
if (iq_add_int64_raw(buffer_get_address(_buf))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_add_two_int64s
/// iq_add_two_int64s(tup)->int
var _buf = itr_test_prepare_buffer(8);
var _tup_0 = argument0;
buffer_write(_buf, buffer_u64, _tup_0[0]);
buffer_write(_buf, buffer_u64, _tup_0[1]);
if (iq_add_two_int64s_raw(buffer_get_address(_buf))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_get_int64_vec_sum
/// iq_get_int64_vec_sum(arr:array<int>)->int
var _buf = itr_test_prepare_buffer(8);
var _arr_0 = argument0;
var _len_0 = array_length(_arr_0);
buffer_write(_buf, buffer_u32, _len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
	buffer_write(_buf, buffer_u64, _arr_0[_ind_0]);
}
if (iq_get_int64_vec_sum_raw(buffer_get_address(_buf))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_get_int64_arr_sum
/// iq_get_int64_arr_sum(arr:array<int>)->int
var _buf = itr_test_prepare_buffer(8);
var _arr_0 = argument0;
var _len_0 = array_length(_arr_0);
buffer_write(_buf, buffer_u32, _len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0++) {
	buffer_write(_buf, buffer_u64, _arr_0[_ind_0]);
}
if (iq_get_int64_arr_sum_raw(buffer_get_address(_buf))) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

