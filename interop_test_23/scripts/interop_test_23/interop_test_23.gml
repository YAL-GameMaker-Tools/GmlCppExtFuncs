global.__ptrt_iq_thing = ["iq_thing"]
function iq_thing(_ptr) constructor {
	__ptr__ = _ptr;
	static toString = function() /*=>*/ {return "iq_thing(0x" + string(__ptr__) + ")"};
}

global.__ptrt_iq_id = ["iq_id"]
function iq_id(_id) constructor {
	__id__ = _id;
	static toString = function() /*=>*/ {return "iq_id(" + string(__id__) + ")"};
}