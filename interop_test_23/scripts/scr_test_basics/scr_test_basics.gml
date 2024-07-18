function scr_test_basics() {
    assert(iq_get_int(), 1);
    
    assert(iq_get_int64(), 0x123456789ABCDEF);
    
    assert(iq_get_string(), "hi!");
    
    var a = 0x123456789;
    var b = 0x987654321;
    assert(iq_add_int64(a, b), a + b);
    
    assert(iq_inc_opt_int(3), 4);
    assert(iq_inc_opt_int(undefined), undefined);
    
    assert(iq_def_ret_int(), 3);
    
    assert(iq_def_ret_string(), "OK!");
    
    assert(iq_add_strlens("a", "bb", "ccc", "dddd"), 10);
}