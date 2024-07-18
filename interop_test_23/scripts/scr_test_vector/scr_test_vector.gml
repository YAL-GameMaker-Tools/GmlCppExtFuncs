function scr_test_vector() {
    assert(iq_get_vec(), [1, 2, 3]);
    
    assert(iq_get_opt_vec(true), [1, 2, 3]);
    assert(iq_get_opt_vec(false), undefined);
    
    assert(iq_get_int64_vec_sum([1, 2, 3]), 6);
    
    assert(iq_get_length_of_strings(["A", "B", "CD"]), 4);
}