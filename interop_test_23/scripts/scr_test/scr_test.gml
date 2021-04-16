function scr_test() {
    assert(iq_get_int(), 1);
    assert(iq_get_int64(), 0x123456789ABCDEF);
    assert(iq_get_string(), "hi!");
    var a = 0x123456789;
    var b = 0x987654321;
    assert(iq_add_int64(a, b), a + b);
    assert(iq_get_int64_vec_sum([1, 2, 3]), 6);
    assert(iq_get_int64_arr_sum([4, 5, 6]), 15);
    assert(iq_get_vec(), [1, 2, 3]);
    assert(iq_get_struct_vec(), [[1, "one"], [2, "two-"], [3, "tri"]]);
    assert(iq_get_two_int64s(), [1, 2]);
    assert(iq_add_two_int64s([2, 3]), 5);
    
    trace("OK!");
}