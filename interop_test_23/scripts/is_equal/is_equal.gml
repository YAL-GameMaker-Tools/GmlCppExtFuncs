function is_equal(a, b) {
    if (is_array(a) && is_array(b)) {
        var n = array_length(a);
        if (n != array_length(b)) return false;
        for (var i = 0; i < n; i++) {
            if (!is_equal(a[i], b[i])) return false;
        }
        return true;
    }
    return a == b;
}