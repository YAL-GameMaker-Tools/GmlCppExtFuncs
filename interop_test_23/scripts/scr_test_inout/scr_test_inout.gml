function scr_test_inout() {
    if (iq_use_structs) {
        var one = {
            a: 1, b: 3,
            text: "Hello!"
        }
        iq_test_inout_struct(one);
        assert(one.a, 2);
        assert(one.text, "Yeah!");
    } else {
        var one = [
            1, 3,
            "Hello!"
        ];
        iq_test_inout_struct(one);
        assert(one[0], 2);
        assert(one[2], "Yeah!");
    }
    //
    var arr = [1, 2, 3];
    iq_test_inout_int_vector(arr);
    assert(arr, [2, 3, 4]);
    //
    if (iq_use_structs) {
        var arr = [
            { a: 1, b: 3, text: "A" },
            { a: 2, b: 4, text: "B" },
        ];
        iq_test_inout_struct_vector(arr);
    }
}