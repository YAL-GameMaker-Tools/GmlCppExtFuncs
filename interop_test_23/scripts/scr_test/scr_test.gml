globalvar iq_use_structs;
function scr_test(_use_structs) {
    iq_use_structs = _use_structs;
    assert(iq_get_int(), 1);
    assert(iq_get_int64(), 0x123456789ABCDEF);
    assert(iq_get_string(), "hi!");
    var a = 0x123456789;
    var b = 0x987654321;
    assert(iq_add_int64(a, b), a + b);
    assert(iq_get_int64_vec_sum([1, 2, 3]), 6);
    assert(iq_get_vec(), [1, 2, 3]);
    if (iq_use_structs) {
        assert(iq_get_struct_vec(), [
            { ind: 1, name: "one" },
            { ind: 2, name: "two-" },
            { ind: 3, name: "tri" },
        ]);
    } else {
        assert(iq_get_struct_vec(), [
            [1, "one"],
            [2, "two-"],
            [3, "tri"],
        ]);
    }
    assert(iq_get_two_int64s(), [1, 2]);
    assert(iq_add_two_int64s([2, 3]), 5);
    
    var buf = buffer_create(16, buffer_fixed, 1);
    buffer_fill(buf, 0, buffer_u8, 0xFF, 16);
    for (var i = 1; i <= 4; i++) buffer_write(buf, buffer_u8, i);
    assert(iq_get_buffer_sum(buf), 10);
    
    assert(iq_get_length_of_strings(["A", "B", "CD"]), 4);
    
    var th = iq_thing_create(3);
    assert(iq_thing_get_count(th), 3);
    iq_thing_set_count(th, 5);
    assert(iq_thing_get_count(th), 5);
    iq_thing_destroy(th);
    
    trace(sfmt("OK! (use_structs=%)",_use_structs));
}