#define iq_never
/// iq_never()
// no buffer!
iq_never_raw()

#define iq_get_int
/// iq_get_int()->int
// no buffer!
return iq_get_int_raw();

#define iq_get_int64
/// iq_get_int64()->int
var _buf = itr_test_prepare_buffer(8);
if (iq_get_int64_raw(buffer_get_address(_buf), 8)) {
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_get_string
/// iq_get_string()->string
// no buffer!
return iq_get_string_raw();

#define iq_add_int64
/// iq_add_int64(a:int, b:int = 0)->int
var _buf = itr_test_prepare_buffer(17);
buffer_write(_buf, buffer_u64, argument[0]);
if (argument_count >= 2) {
	buffer_write(_buf, buffer_bool, true);
	buffer_write(_buf, buffer_u64, argument[1]);
} else buffer_write(_buf, buffer_bool, false);
if (iq_add_int64_raw(buffer_get_address(_buf), 17)) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_inc_opt_int
/// iq_inc_opt_int(i:int?)->int?
var _buf = itr_test_prepare_buffer(5);
var _val_0 = argument0;
var _flag_0 = _val_0 != undefined;
buffer_write(_buf, buffer_bool, _flag_0);
if (_flag_0) {
	buffer_write(_buf, buffer_s32, _val_0);
}
if (iq_inc_opt_int_raw(buffer_get_address(_buf), 5)) {
	buffer_seek(_buf, buffer_seek_start, 0);
	var _val_0;
	if (buffer_read(_buf, buffer_bool)) {
		_val_0 = buffer_read(_buf, buffer_s32);
	} else _val_0 = undefined;
	return _val_0;
} else return undefined;

#define iq_def_ret_int
/// iq_def_ret_int()->int
var _buf = itr_test_prepare_buffer(4);
if (iq_def_ret_int_raw(buffer_get_address(_buf), 4)) {
	return buffer_read(_buf, buffer_s32);
} else return -3;

#define iq_def_ret_string
/// iq_def_ret_string()->string
var _buf = itr_test_prepare_buffer(8);
var __size__ = iq_def_ret_string_raw(buffer_get_address(_buf), 8);
if (__size__ == 0) return "DLL is not loaded";
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
// GMS >= 2.3:
buffer_set_used_size(_buf, __size__);
/*/
buffer_poke(_buf, __size__ - 1, buffer_u8, 0);
//*/
iq_def_ret_string_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
return buffer_read(_buf, buffer_string);

#define iq_add_strlens
/// iq_add_strlens(a:string, b:string, c:string, d:string)->int
// no buffer!
return iq_add_strlens_raw(argument0, argument1, argument2, argument3);

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
return iq_get_buffer_sum_raw(buffer_get_address(_buf), 16);

#define iq_id_create
/// iq_id_create()->
var _buf = itr_test_prepare_buffer(8);
if (iq_id_create_raw(buffer_get_address(_buf), 8)) {
	// GMS >= 2.3:
	if (iq_use_structs) {
		var _id_0 = buffer_read(_buf, buffer_u64);
		var _box_0;
		if (_id_0 != 0) {
			_box_0 = new iq_id(_id_0);
		} else _box_0 = undefined;
		return _box_0;
	} else //*/
	{
		var _id_0 = buffer_read(_buf, buffer_u64);
		var _box_0;
		if (_id_0 != 0) {
			_box_0 = array_create(2);
			_box_0[0] = global.__ptrt_iq_id;
			_box_0[1] = _id_0;
		} else _box_0 = undefined;
		return _box_0;
	}
} else return undefined;

#define iq_id_value
/// iq_id_value(id)->int
var _buf = itr_test_prepare_buffer(8);
// GMS >= 2.3:
if (iq_use_structs) {
	if (instanceof(argument0) != "iq_id") { show_error("Expected a iq_id, got " + string(argument0), true); exit }
	if (argument0.__id__ == 0) { show_error("This iq_id is destroyed.", true); exit; }
	buffer_write(_buf, buffer_u64, argument0.__id__);
} else //*/
{
	if (argument0[0] != global.__ptrt_iq_id) { show_error("Expected a iq_id, got " + string(argument0), true); exit }
	if (argument0[1] == 0) { show_error("This iq_id is destroyed.", true); exit; }
	buffer_write(_buf, buffer_u64, argument0[1]);
}
return iq_id_value_raw(buffer_get_address(_buf), 8);

#define iq_id_destroy
/// iq_id_destroy(id)
var _buf = itr_test_prepare_buffer(8);
// GMS >= 2.3:
if (iq_use_structs) {
	var _box_0 = argument0;
	if (instanceof(_box_0) != "iq_id") { show_error("Expected a iq_id, got " + string(_box_0), true); exit }
	var _id_0 = _box_0.__id__
	var _id_0 = _box_0.__id__;
	if (_id_0 == 0) { show_error("This iq_id is destroyed.", true); exit; }
	_box_0.__id__ = 0;
	buffer_write(_buf, buffer_u64, _id_0);
} else //*/
{
	var _box_0 = argument0;
	if (_box_0[0] != global.__ptrt_iq_id) { show_error("Expected a iq_id, got " + string(_box_0), true); exit }
	var _id_0 = _box_0[1]
	var _id_0 = _box_0[1];
	if (_id_0 == 0) { show_error("This iq_id is destroyed.", true); exit; }
	_box_0[@1] = 0;
	buffer_write(_buf, buffer_u64, _id_0);
}
iq_id_destroy_raw(buffer_get_address(_buf), 8)

#define iq_thing_create
/// iq_thing_create(count:int)->
var _buf = itr_test_prepare_buffer(8);
if (iq_thing_create_raw(buffer_get_address(_buf), 8, argument0)) {
	// GMS >= 2.3:
	if (iq_use_structs) {
		var _ptr_0 = buffer_read(_buf, buffer_u64);
		var _box_0;
		if (_ptr_0 != 0) {
			_box_0 = new iq_thing(ptr(_ptr_0));
		} else _box_0 = undefined;
		return _box_0;
	} else //*/
	{
		var _ptr_0 = buffer_read(_buf, buffer_u64);
		var _box_0;
		if (_ptr_0 != 0) {
			_box_0 = array_create(2);
			_box_0[0] = global.__ptrt_iq_thing;
			_box_0[1] = ptr(_ptr_0);
		} else _box_0 = undefined;
		return _box_0;
	}
} else return undefined;

#define iq_thing_destroy
/// iq_thing_destroy(thing)
// no buffer!
// GMS >= 2.3:
if (iq_use_structs) {
	var _box_0 = argument0;
	if (instanceof(_box_0) != "iq_thing") { show_error("Expected a iq_thing, got " + string(_box_0), true); exit }
	var _ptr_0 = _box_0.__ptr__
	var _ptr_0 = _box_0.__ptr__;
	if (_ptr_0 == pointer_null) { show_error("This iq_thing is destroyed.", true); exit; }
	_box_0.__ptr__ = pointer_null;
} else //*/
{
	var _box_0 = argument0;
	if (_box_0[0] != global.__ptrt_iq_thing) { show_error("Expected a iq_thing, got " + string(_box_0), true); exit }
	var _ptr_0 = _box_0[1]
	var _ptr_0 = _box_0[1];
	if (int64(_ptr_0) == 0) { show_error("This iq_thing is destroyed.", true); exit; }
	_box_0[@1] = ptr(0);
}
// GMS >= 2.3:
if (iq_use_structs) {
	iq_thing_destroy_raw(_ptr_0)
} else //*/
{
	iq_thing_destroy_raw(_ptr_0)
}

#define iq_thing_get_count
/// iq_thing_get_count(thing)->int
// no buffer!
// GMS >= 2.3:
if (iq_use_structs) {
	if (instanceof(argument0) != "iq_thing") { show_error("Expected a iq_thing, got " + string(argument0), true); exit }
	if (argument0.__ptr__ == pointer_null) { show_error("This iq_thing is destroyed.", true); exit; }
} else //*/
{
	if (argument0[0] != global.__ptrt_iq_thing) { show_error("Expected a iq_thing, got " + string(argument0), true); exit }
	if (int64(argument0[1]) == 0) { show_error("This iq_thing is destroyed.", true); exit; }
}
// GMS >= 2.3:
if (iq_use_structs) {
	return iq_thing_get_count_raw(argument0.__ptr__);
} else //*/
{
	return iq_thing_get_count_raw(argument0[1]);
}

#define iq_thing_set_count
/// iq_thing_set_count(thing, count:int)
// no buffer!
// GMS >= 2.3:
if (iq_use_structs) {
	if (instanceof(argument0) != "iq_thing") { show_error("Expected a iq_thing, got " + string(argument0), true); exit }
	if (argument0.__ptr__ == pointer_null) { show_error("This iq_thing is destroyed.", true); exit; }
} else //*/
{
	if (argument0[0] != global.__ptrt_iq_thing) { show_error("Expected a iq_thing, got " + string(argument0), true); exit }
	if (int64(argument0[1]) == 0) { show_error("This iq_thing is destroyed.", true); exit; }
}
// GMS >= 2.3:
if (iq_use_structs) {
	iq_thing_set_count_raw(argument0.__ptr__, argument1)
} else //*/
{
	iq_thing_set_count_raw(argument0[1], argument1)
}

#define iq_get_hwnd
/// iq_get_hwnd()->int
var _buf = itr_test_prepare_buffer(8);
buffer_write(_buf, buffer_u64, int64(window_handle()));
if (iq_get_hwnd_raw(buffer_get_address(_buf), 8)) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_test_inout_box
/// iq_test_inout_box(q)
var _buf = itr_test_prepare_buffer(5);
var _box_0 = argument0;
if (array_length_1d(_box_0)) {
	buffer_write(_buf, buffer_bool, true);
	buffer_write(_buf, buffer_s32, _box_0[0]);
} else buffer_write(_buf, buffer_bool, false);
iq_test_inout_box_raw(buffer_get_address(_buf), 5)
buffer_seek(_buf, buffer_seek_start, 0);
var _box_0 = argument0;
var _val_0;
_val_0 = buffer_read(_buf, buffer_s32);
_box_0[@0] = _val_0;

#define iq_test_inout_struct
/// iq_test_inout_struct(q)
var _buf = itr_test_prepare_buffer(41);
// GMS >= 2.3:
if (iq_use_structs) {
	var _struct_0 = argument0;
	if (variable_struct_names_count(_struct_0) != 0) {
		buffer_write(_buf, buffer_bool, true);
		buffer_write(_buf, buffer_s32, _struct_0.a);
		buffer_write(_buf, buffer_s32, _struct_0.b);
		itr_test_write_chars(_buf, _struct_0.text, 32)
	} else buffer_write(_buf, buffer_bool, false);
} else //*/
{
	var _struct_0 = argument0;
	if (array_length_1d(_struct_0) != 0) {
		buffer_write(_buf, buffer_bool, true);
		buffer_write(_buf, buffer_s32, _struct_0[0]); // a
		buffer_write(_buf, buffer_s32, _struct_0[1]); // b
		itr_test_write_chars(_buf, _struct_0[2], 32) // text
	} else buffer_write(_buf, buffer_bool, false);
}
iq_test_inout_struct_raw(buffer_get_address(_buf), 41)
buffer_seek(_buf, buffer_seek_start, 0);
// GMS >= 2.3:
if (iq_use_structs) {
	var _struct_0 = argument0;
	_struct_0.a = buffer_read(_buf, buffer_s32);
	_struct_0.b = buffer_read(_buf, buffer_s32);
	_struct_0.text = itr_test_read_chars(_buf, 32);
} else //*/
{
	var _struct_0 = argument0;
	_struct_0[@0] = buffer_read(_buf, buffer_s32); // a
	_struct_0[@1] = buffer_read(_buf, buffer_s32); // b
	_struct_0[@2] = itr_test_read_chars(_buf, 32); // text
}

#define iq_test_inout_int_vector
/// iq_test_inout_int_vector(v:array<int>)
var _buf = itr_test_prepare_buffer(8);
// GMS >= 2.3:
if (iq_use_structs) {
	var _arr_0 = argument0;
	var _len_0 = array_length_1d(_arr_0);
	buffer_write(_buf, buffer_u32, _len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		buffer_write(_buf, buffer_s32, _arr_0[_ind_0]);
	}
} else //*/
{
	var _arr_0 = argument0;
	var _len_0 = array_length_1d(_arr_0);
	buffer_write(_buf, buffer_u32, _len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		buffer_write(_buf, buffer_s32, _arr_0[_ind_0]);
	}
}
var __size__ = iq_test_inout_int_vector_raw(buffer_get_address(_buf), 8);
if (__size__ == 0) exit
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
// GMS >= 2.3:
buffer_set_used_size(_buf, __size__);
/*/
buffer_poke(_buf, __size__ - 1, buffer_u8, 0);
//*/
iq_test_inout_int_vector_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
// GMS >= 2.3:
if (iq_use_structs) {
	var _arr_0 = argument0;
	var _len_0 = buffer_read(_buf, buffer_u32);
	if (array_length(_arr_0) != _len_0) array_resize(_arr_0, _len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		_arr_0[@_ind_0] = buffer_read(_buf, buffer_s32);
	}
} else //*/
{
	var _arr_0 = argument0;
	var _len_0 = buffer_read(_buf, buffer_u32);
	var _ind_0 = array_length_1d(_arr_0);
	if (_ind_0 >= _len_0) {
		while (--_ind_0 >= _len_0) _arr_0[_ind_0] = undefined;
	} else _arr_0[@_len_0 - 1] = 0;
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		_arr_0[@_ind_0] = buffer_read(_buf, buffer_s32);
	}
}

#define iq_test_inout_struct_vector
/// iq_test_inout_struct_vector(v:array<any>)
var _buf = itr_test_prepare_buffer(8);
// GMS >= 2.3:
if (iq_use_structs) {
	var _arr_0 = argument0;
	var _len_0 = array_length_1d(_arr_0);
	buffer_write(_buf, buffer_u32, _len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		var _val_0 = _arr_0[_ind_0];
		if (_val_0 != undefined && variable_struct_names_count(_val_0) != 0) {
			buffer_write(_buf, buffer_bool, true);
			buffer_write(_buf, buffer_s32, _val_0.a);
			buffer_write(_buf, buffer_s32, _val_0.b);
			itr_test_write_chars(_buf, _val_0.text, 32)
		} else buffer_write(_buf, buffer_bool, false);
	}
} else //*/
{
	var _arr_0 = argument0;
	var _len_0 = array_length_1d(_arr_0);
	buffer_write(_buf, buffer_u32, _len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		var _val_0 = _arr_0[_ind_0];
		if (_val_0 != undefined && array_length_1d(_val_0) != 0) {
			buffer_write(_buf, buffer_bool, true);
			buffer_write(_buf, buffer_s32, _val_0[0]); // a
			buffer_write(_buf, buffer_s32, _val_0[1]); // b
			itr_test_write_chars(_buf, _val_0[2], 32) // text
		} else buffer_write(_buf, buffer_bool, false);
	}
}
var __size__ = iq_test_inout_struct_vector_raw(buffer_get_address(_buf), 8);
if (__size__ == 0) exit
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
// GMS >= 2.3:
buffer_set_used_size(_buf, __size__);
/*/
buffer_poke(_buf, __size__ - 1, buffer_u8, 0);
//*/
iq_test_inout_struct_vector_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
// GMS >= 2.3:
if (iq_use_structs) {
	var _arr_0 = argument0;
	var _len_0 = buffer_read(_buf, buffer_u32);
	if (array_length(_arr_0) != _len_0) array_resize(_arr_0, _len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		var _val_0 = _arr_0[_ind_0];
		if (_val_0 == undefined) {
			_val_0 = {};
			_arr_0[@_ind_0] = _val_0;
		}
		_val_0.a = buffer_read(_buf, buffer_s32);
		_val_0.b = buffer_read(_buf, buffer_s32);
		_val_0.text = itr_test_read_chars(_buf, 32);
	}
} else //*/
{
	var _arr_0 = argument0;
	var _len_0 = buffer_read(_buf, buffer_u32);
	var _ind_0 = array_length_1d(_arr_0);
	if (_ind_0 >= _len_0) {
		while (--_ind_0 >= _len_0) _arr_0[_ind_0] = undefined;
	} else _arr_0[@_len_0 - 1] = 0;
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		var _val_0 = _arr_0[_ind_0];
		if (_val_0 == undefined) {
			_val_0 = [];
			_arr_0[@_ind_0] = _val_0;
		}
		_val_0[@0] = buffer_read(_buf, buffer_s32); // a
		_val_0[@1] = buffer_read(_buf, buffer_s32); // b
		_val_0[@2] = itr_test_read_chars(_buf, 32); // text
	}
}

#define iq_get_struct_vec
/// iq_get_struct_vec()->array<any>
var _buf = itr_test_prepare_buffer(8);
var __size__ = iq_get_struct_vec_raw(buffer_get_address(_buf), 8);
if (__size__ == 0) return undefined;
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
// GMS >= 2.3:
buffer_set_used_size(_buf, __size__);
/*/
buffer_poke(_buf, __size__ - 1, buffer_u8, 0);
//*/
iq_get_struct_vec_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
// GMS >= 2.3:
if (iq_use_structs) {
	var _len_0 = buffer_read(_buf, buffer_u32);
	var _arr_0 = array_create(_len_0);
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
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
	for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
		var _struct_1 = array_create(2); // _iq_get_struct_vec
		_struct_1[0] = buffer_read(_buf, buffer_s32); // ind
		_struct_1[1] = itr_test_read_chars(_buf, 4); // name
		_arr_0[_ind_0] = _struct_1;
	}
	
	return _arr_0;
}

#define iq_mixed
/// iq_mixed(q)->
var _buf = itr_test_prepare_buffer(37);
// GMS >= 2.3:
if (iq_use_structs) {
	var _struct_0 = argument0;
	buffer_write(_buf, buffer_s32, _struct_0.num);
	buffer_write(_buf, buffer_string, _struct_0.str);
	var _arr_1 = _struct_0.grid;
	for (var _ind_1 = 0; _ind_1 < 3; _ind_1 += 1) {
		var _arr_2 = _arr_1[_ind_1];
		for (var _ind_2 = 0; _ind_2 < 3; _ind_2 += 1) {
			buffer_write(_buf, buffer_u8, _arr_2[_ind_2]);
		}
	}
	var _arr_1 = _struct_0.sub;
	for (var _ind_1 = 0; _ind_1 < 2; _ind_1 += 1) {
		var _struct_3 = _arr_1[_ind_1];
		buffer_write(_buf, buffer_s32, _struct_3.a);
		buffer_write(_buf, buffer_s32, _struct_3.b);
	}
} else //*/
{
	var _struct_0 = argument0;
	buffer_write(_buf, buffer_s32, _struct_0[0]); // num
	buffer_write(_buf, buffer_string, _struct_0[1]); // str
	var _arr_1 = _struct_0[2];
	for (var _ind_1 = 0; _ind_1 < 3; _ind_1 += 1) {
		var _arr_2 = _arr_1[_ind_1];
		for (var _ind_2 = 0; _ind_2 < 3; _ind_2 += 1) {
			buffer_write(_buf, buffer_u8, _arr_2[_ind_2]);
		}
	} // grid
	var _arr_1 = _struct_0[3];
	for (var _ind_1 = 0; _ind_1 < 2; _ind_1 += 1) {
		var _struct_3 = _arr_1[_ind_1];
		buffer_write(_buf, buffer_s32, _struct_3[0]); // a
		buffer_write(_buf, buffer_s32, _struct_3[1]); // b
	} // sub
}
var __size__ = iq_mixed_raw(buffer_get_address(_buf), 37);
if (__size__ == 0) return undefined;
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
// GMS >= 2.3:
buffer_set_used_size(_buf, __size__);
/*/
buffer_poke(_buf, __size__ - 1, buffer_u8, 0);
//*/
iq_mixed_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
// GMS >= 2.3:
if (iq_use_structs) {
	var _struct_0 = {}; // mixed
	_struct_0.num = buffer_read(_buf, buffer_s32);
	_struct_0.str = buffer_read(_buf, buffer_string);
	var _arr_1 = array_create(3);
	for (var _ind_1 = 0; _ind_1 < 3; _ind_1 += 1) {
		var _arr_2 = array_create(3);
		for (var _ind_2 = 0; _ind_2 < 3; _ind_2 += 1) {
			_arr_2[_ind_2] = buffer_read(_buf, buffer_u8);
		}
		_arr_1[_ind_1] = _arr_2;
	}
	_struct_0.grid = _arr_1;
	var _arr_1 = array_create(2);
	for (var _ind_1 = 0; _ind_1 < 2; _ind_1 += 1) {
		var _struct_3 = {}; // mixed_sub
		_struct_3.a = buffer_read(_buf, buffer_s32);
		_struct_3.b = buffer_read(_buf, buffer_s32);
		_arr_1[_ind_1] = _struct_3;
	}
	_struct_0.sub = _arr_1;
	return _struct_0;
} else //*/
{
	var _struct_0 = array_create(4); // mixed
	_struct_0[0] = buffer_read(_buf, buffer_s32); // num
	_struct_0[1] = buffer_read(_buf, buffer_string); // str
	var _arr_1 = array_create(3);
	for (var _ind_1 = 0; _ind_1 < 3; _ind_1 += 1) {
		var _arr_2 = array_create(3);
		for (var _ind_2 = 0; _ind_2 < 3; _ind_2 += 1) {
			_arr_2[_ind_2] = buffer_read(_buf, buffer_u8);
		}
		_arr_1[_ind_1] = _arr_2;
	}
	_struct_0[2] = _arr_1; // grid
	var _arr_1 = array_create(2);
	for (var _ind_1 = 0; _ind_1 < 2; _ind_1 += 1) {
		var _struct_3 = array_create(2); // mixed_sub
		_struct_3[0] = buffer_read(_buf, buffer_s32); // a
		_struct_3[1] = buffer_read(_buf, buffer_s32); // b
		_arr_1[_ind_1] = _struct_3;
	}
	_struct_0[3] = _arr_1; // sub
	return _struct_0;
}

#define iq_get_int64_pair
/// iq_get_int64_pair()->
var _buf = itr_test_prepare_buffer(16);
if (iq_get_int64_pair_raw(buffer_get_address(_buf), 16)) {var _tup_0 = array_create(2);
	_tup_0[0] = buffer_read(_buf, buffer_u64);
	_tup_0[1] = buffer_read(_buf, buffer_u64);
	
	return _tup_0;
} else return undefined;

#define iq_int64_pair_sum
/// iq_int64_pair_sum(pair)->int
var _buf = itr_test_prepare_buffer(16);
var _tup_0 = argument0;
buffer_write(_buf, buffer_u64, _tup_0[0]);
buffer_write(_buf, buffer_u64, _tup_0[1]);
if (iq_int64_pair_sum_raw(buffer_get_address(_buf), 16)) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_int64_pair_swap
/// iq_int64_pair_swap(pair)->
var _buf = itr_test_prepare_buffer(16);
var _tup_0 = argument0;
buffer_write(_buf, buffer_u64, _tup_0[0]);
buffer_write(_buf, buffer_u64, _tup_0[1]);
if (iq_int64_pair_swap_raw(buffer_get_address(_buf), 16)) {
	buffer_seek(_buf, buffer_seek_start, 0);var _tup_0 = array_create(2);
	_tup_0[0] = buffer_read(_buf, buffer_u64);
	_tup_0[1] = buffer_read(_buf, buffer_u64);
	
	return _tup_0;
} else return undefined;

#define iq_get_int64_pair_vec_sum
/// iq_get_int64_pair_vec_sum(arr:array<any>)->
var _buf = itr_test_prepare_buffer(16);
var _arr_0 = argument0;
var _len_0 = array_length_1d(_arr_0);
buffer_write(_buf, buffer_u32, _len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
	var _tup_1 = _arr_0[_ind_0];
	buffer_write(_buf, buffer_u64, _tup_1[0]);
	buffer_write(_buf, buffer_u64, _tup_1[1]);
}
if (iq_get_int64_pair_vec_sum_raw(buffer_get_address(_buf), 16)) {
	buffer_seek(_buf, buffer_seek_start, 0);var _tup_0 = array_create(2);
	_tup_0[0] = buffer_read(_buf, buffer_u64);
	_tup_0[1] = buffer_read(_buf, buffer_u64);
	
	return _tup_0;
} else return undefined;

#define iq_get_vec
/// iq_get_vec()->array<int>
var _buf = itr_test_prepare_buffer(8);
var __size__ = iq_get_vec_raw(buffer_get_address(_buf), 8);
if (__size__ == 0) return undefined;
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
// GMS >= 2.3:
buffer_set_used_size(_buf, __size__);
/*/
buffer_poke(_buf, __size__ - 1, buffer_u8, 0);
//*/
iq_get_vec_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
var _len_0 = buffer_read(_buf, buffer_u32);
var _arr_0 = array_create(_len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
	_arr_0[_ind_0] = buffer_read(_buf, buffer_u64);
}

return _arr_0;

#define iq_get_opt_vec
/// iq_get_opt_vec(ret:bool)->array<int>?
var _buf = itr_test_prepare_buffer(9);
var __size__ = iq_get_opt_vec_raw(buffer_get_address(_buf), 9, argument0);
if (__size__ == 0) return undefined;
if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);
// GMS >= 2.3:
buffer_set_used_size(_buf, __size__);
/*/
buffer_poke(_buf, __size__ - 1, buffer_u8, 0);
//*/
iq_get_opt_vec_raw_post(buffer_get_address(_buf), __size__);
buffer_seek(_buf, buffer_seek_start, 0);
var _val_0;
if (buffer_read(_buf, buffer_bool)) {
	var _len_1 = buffer_read(_buf, buffer_u32);
	var _arr_1 = array_create(_len_1);
	for (var _ind_1 = 0; _ind_1 < _len_1; _ind_1 += 1) {
		_arr_1[_ind_1] = buffer_read(_buf, buffer_u64);
	}
	
	_val_0 = _arr_1;
} else _val_0 = undefined;
return _val_0;

#define iq_get_int64_vec_sum
/// iq_get_int64_vec_sum(arr:array<int>)->int
var _buf = itr_test_prepare_buffer(8);
var _arr_0 = argument0;
var _len_0 = array_length_1d(_arr_0);
buffer_write(_buf, buffer_u32, _len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
	buffer_write(_buf, buffer_u64, _arr_0[_ind_0]);
}
if (iq_get_int64_vec_sum_raw(buffer_get_address(_buf), 8)) {
	buffer_seek(_buf, buffer_seek_start, 0);
	return buffer_read(_buf, buffer_u64);
} else return undefined;

#define iq_get_length_of_strings
/// iq_get_length_of_strings(strings:array<string>)->int
var _buf = itr_test_prepare_buffer(8);
var _arr_0 = argument0;
var _len_0 = array_length_1d(_arr_0);
buffer_write(_buf, buffer_u32, _len_0);
for (var _ind_0 = 0; _ind_0 < _len_0; _ind_0 += 1) {
	buffer_write(_buf, buffer_string, _arr_0[_ind_0]);
}
return iq_get_length_of_strings_raw(buffer_get_address(_buf), 8);

