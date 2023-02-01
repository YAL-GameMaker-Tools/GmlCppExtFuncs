/// @param value
/// @param want
/// @param ?label
function assert(_val, _want, _label) {
    if (_label == undefined) _label = "unnamed";
    if (!is_equal(_val, _want)) show_error(sfmt("Wanted %, got % for %",_want,_val,_label), 1);
}