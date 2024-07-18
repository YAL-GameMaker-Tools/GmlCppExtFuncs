function scr_test_tuple() {
    assert(iq_get_int64_pair(), [1, 2]);
    
    assert(iq_int64_pair_sum([2, 3]), 5);
    
    assert(iq_int64_pair_swap([3, 4]), [4, 3]);
    
    assert(iq_get_int64_pair_vec_sum([
        [1, 2],
        [3, 4],
    ]), [4, 6]);
}