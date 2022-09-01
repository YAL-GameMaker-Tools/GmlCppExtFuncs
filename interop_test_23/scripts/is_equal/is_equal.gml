function is_equal(a, b, _depth = 0) {
    _depth += 1;
    if (is_array(a) && is_array(b)) {
        var n = array_length(a);
        if (n != array_length(b)) return false;
        for (var i = 0; i < n; i++) {
            if (!is_equal(a[i], b[i], _depth)) return false;
        }
        return true;
    }
    if (is_struct(a) && is_struct(b)) {
        var keys = variable_struct_get_names(a);
        var n = array_length(keys);
        if (n != array_length(variable_struct_get_names(b))) return false;
        for (var i = 0; i < n; i++) {
            var key = keys[i];
            if (!variable_struct_exists(b, key)) return false;
            if (!is_equal(a[$ key], b[$ key], _depth)) return false;
        }
        return true;
    }
    return a == b;
}