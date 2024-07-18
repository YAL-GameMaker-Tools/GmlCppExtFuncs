function scr_test_struct() {
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
    
    if (iq_use_structs) {
        var m1 = {
            num: 3,
            str: "hi!",
            grid: [
                [1, 2, 3],
                [4, 5, 6],
                [7, 8, 9],
            ],
            sub: [
                { a: 1, b: 2 },
                { a: 3, b: 4 },
            ]
        }
        var m2 = iq_mixed(m1);
        assert(m2, m1, "mixed");
    }
}