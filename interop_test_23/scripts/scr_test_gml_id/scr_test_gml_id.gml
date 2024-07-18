function scr_test_gml_id() {
    var _id = iq_id_create();
    assert(_id != undefined, true);
    assert(iq_id_value(_id) != 0, true);
    iq_id_destroy(_id);
}