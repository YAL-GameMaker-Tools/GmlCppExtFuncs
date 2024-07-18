function scr_test_gml_ptr() {
    var th = iq_thing_create(3);
    assert(iq_thing_get_count(th), 3);
    iq_thing_set_count(th, 5);
    assert(iq_thing_get_count(th), 5);
    iq_thing_destroy(th);
}