globalvar iq_use_structs;
function scr_test(_use_structs) {
    iq_use_structs = _use_structs;
    scr_test_basics();
    scr_test_vector();
    scr_test_tuple();
    scr_test_buffer();
    scr_test_gml_ptr();
    scr_test_gml_id();
    scr_test_struct();
    scr_test_inout();
    scr_test_hwnd();
    
    trace(sfmt("Test OK! (use_structs=%)",_use_structs));
}