global.__ptrt_iq_thing = ["iq_thing"]
function iq_thing(_ptr) constructor {
	__ptr__ = _ptr;
	static toString = function() /*=>*/ {return "iq_thing(0x" + string(__ptr__) + ")"};
}