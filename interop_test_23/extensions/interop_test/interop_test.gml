#define itr_test_init
global.__iq_use_structs = false;
global.__ptrt_iq_thing = ["iq_thing"];

#define itr_test_prepare_buffer
/// (size:int)->buffer~
var _size = argument0;
gml_pragma("global", "global.__itr_test_buffer = undefined");
var _buf = global.__itr_test_buffer;
if (_buf == undefined) {
    _buf = buffer_create(_size, buffer_grow, 1);
    global.__itr_test_buffer = _buf;
} else if (buffer_get_size(_buf) < _size) {
    buffer_resize(_buf, _size);
}
buffer_seek(_buf, buffer_seek_start, 0);
return _buf;

#define itr_test_read_chars
/// (buffer:buffer, len:int)->string~
var _buf = argument0, _len = argument1;
gml_pragma("global", "global.__itr_test_string_buffer = undefined");
var _tmp = global.__itr_test_string_buffer;
if (_tmp == undefined) {
    _tmp = buffer_create(_len + 1, buffer_grow, 1);
    global.__itr_test_string_buffer = _tmp;
} else if (buffer_get_size(_tmp) <= _len) {
    buffer_resize(_tmp, _len + 1);
}
buffer_copy(_buf, buffer_tell(_buf), _len, _tmp, 0);
buffer_seek(_buf, buffer_seek_relative, _len);
buffer_poke(_tmp, _len, buffer_u8, 0);
buffer_seek(_tmp, buffer_seek_start, 0);
return buffer_read(_tmp, buffer_string);

#define itr_test_write_chars
/// (buffer:buffer, str:string, len:int)~
var _buf = argument0, _str = argument1, _len = argument2;
var _tmp = global.__itr_test_string_buffer;
if (_tmp == undefined) {
    _tmp = buffer_create(_len + 1, buffer_grow, 1);
    global.__itr_test_string_buffer = _tmp;
}
buffer_seek(_tmp, buffer_seek_start, 0);
buffer_write(_tmp, buffer_text, _str);
var _pos = buffer_tell(_tmp);
if (_pos < _len) buffer_fill(_tmp, _pos, buffer_u8, 0, _len - _pos);
buffer_copy(_tmp, 0, _len, _buf, buffer_tell(_buf));
buffer_seek(_buf, buffer_seek_relative, _len);