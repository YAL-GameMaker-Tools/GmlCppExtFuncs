/// @param value
/// @param want
/// @param ?label
function assert(_val, _want, _label) {
    if (_label == undefined) _label = "unnamed";
    if (!is_equal(_val, _want)) {
        show_error(
            "Want " + string(_want) + "\n" +
            "Have " + string(_val) + "\n" +
            "for " + string(_label)
        , 1)
    }
}