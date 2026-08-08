function scr_test_buffer() {
    var buf = buffer_create(16, buffer_fixed, 1);
    buffer_fill(buf, 0, buffer_u8, 0xFF, 16);
    for (var i = 1; i <= 4; i++) buffer_write(buf, buffer_u8, i);
    assert(iq_get_buffer_sum(buf), 10);
    //
    buffer_seek(buf, buffer_seek_start, 4);
    assert(iq_get_buffer_rest(buf), 12);
    assert(iq_get_buffer_rest(buf, 8), 8);
}