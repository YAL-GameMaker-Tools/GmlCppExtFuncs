function scr_test_yyri() {
    assert(im_get_int(), 1);
    assert(im_get_string(), "wow");
    assert(im_get_result(), "result");
    assert(im_add_ints(1, 4), 5);
    assert(im_add_rest(1, 2, 3), 6);
    assert(im_string_length("hello"), 5);
    assert(im_typeof(""), "string");
    
    trace(sfmt("Mangled test OK!"));
}