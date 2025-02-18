package proc;
import tools.CppBuf;

/**
	Converts raw C++ pointers to
	struct: `Struct() { __ptr__: ptr }` (constructor with a pointer)
	non-struct: `[meta, ptr]` (pointer-in-array)
	GM8: `ds_list() [ meta, ptr ]`
	@author YellowAfterlife
**/
class CppTypeProcGmlPointer extends CppTypeProc {
	public var isID:Bool;
	public var ptrVar(get, never):String;
	inline function get_ptrVar() {
		return isID ? "__id__" : "__ptr__";
	}
	
	public function new(isID:Bool) {
		super();
		this.isID = isID;
	}
	override public function getSize(type:CppType):Int {
		return 8;
	}
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		var t = type.toCppType();
		return '($t)_in.read<int64_t>()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String):Void {
		var t = type.toCppType();
		cpp.addFormat("%|_out.write<int64_t>((%s)%s);", isID ? "int64_t" : "intptr_t", val);
	}
	function gmlWritePtrCheck(gml:CppBuf, _ptr, _box, type, _typename) {
		gml.addFormat("%|%vdp = ", _ptr);
		var check = true;
		var mode = CppGen.config.boxMode;
		switch (mode) {
			case BmStruct:
				gml.addFormat("%s.%s;", _box, isID ? "__id__" : "__ptr__");
				gml.addFormat('%|if (%s == %s) ', _ptr, isID ? "0" : "pointer_null");
			case BmArray:
				gml.addString(_box);
				gml.addString("[1];");
				gml.addFormat('%|if (%s == 0) ', isID ? _ptr : 'int64($_ptr)');
			case BmGrid:
				gml.addFormat("ds_grid_get(%s, 1, 0);", _box);
				check = false;
				//gml.addFormat('%|if (%s == 0) ', _ptr);
		}
		if (check) gml.addFormat('{ show_error("This %s is destroyed.", true); exit; }', _typename);
		
		// destroy if asked:
		if (type.name == (isID ? "gml_id_destroy" : "gml_ptr_destroy")) {
			switch (mode) {
				case BmStruct:
					gml.addFormat("%|%s", _box);
					gml.addString(isID ? ".__id__" : ".__ptr__");
					gml.addFormat(" = %s;", isID ? "0" : "pointer_null");
				case BmArray:
					gml.addFormat("%|%s[@1]", _box);
					gml.addFormat(" = %s;", isID ? "0" : "ptr(0)");
				case BmGrid:
					gml.addFormat("%|ds_grid_destroy(%s);", _box);
			}
		}
	}
	function gmlWriteValue(gml:CppBuf, _ptr) {
		if (CppGen.config.isGMK) {
			gml.addFormat('%|%bw;', 'ptr', _ptr);
		} else if (!isID) {
			gml.addFormat('%|%bw;', 'u64', 'int64($_ptr)');
		} else {
			gml.addFormat('%|%bw;', 'u64', _ptr);
		}
	}
	public function gmlWriteSelf(gml:CppBuf, type:CppType) {
		var _ptr = isID ? '_id_self' : '_ptr_self';
		var _typename = type.params[0].name;
		gmlWritePtrCheck(gml, _ptr, "self", type, _typename);
		gmlWriteValue(gml, _ptr);
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var _box = '_box_$z';
		var _ptr = isID ? '_id_$z' : '_ptr_$z';
		var _typename = type.params[0].name;
		gml.addFormat("%|%vdp = %s;", _box, val);
		
		// make sure it's the right thing:
		var mode = CppGen.config.boxMode;
		switch (mode) {
			case BmStruct:
				gml.addFormat('%|if (instanceof(%s) != "%s")', _box, _typename);
			case BmArray:
				gml.addFormat("%|if (!is_array(%s)", _box);
				gml.addFormat(" || %s[0] != global.__ptrt_%s)", _box, _typename);
			case BmGrid:
				gml.addFormat('%|if (ds_grid_get(%s, 0, 0) != "%s")', _box, _typename);
		}
		gml.addFormat(' { show_error("Expected a %s, got " + string(%s), true); exit }', _typename, _box);
		
		// make sure it's not destroyed:
		gmlWritePtrCheck(gml, _ptr, _box, type, _typename);
		
		//
		gmlWriteValue(gml, _ptr);
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var boxMode = CppGen.config.boxMode;
		var _ptr = isID ? '_id_$z' : '_ptr_$z';
		var _box = '_box_$z';
		var _typename = type.params[0].name;
		gml.addFormat("%|%vdp = buffer_read(_buf, buffer_u64);", _ptr);
		gml.addFormat("%|var %s;", _box);
		gml.addFormat("%|if (%s != %s) %{", _ptr,  "0");
			var _ptrv = isID ? _ptr : 'ptr($_ptr)';
			//
			gml.addFormat("%|%s = ", _box);
			switch (boxMode) {
				case BmStruct:
					gml.addFormat("new %s(%s);", _typename, _ptrv);
				case BmArray:
					gml.addFormat("array_create(2);");
					gml.addFormat("%|%s[0] = global.__ptrt_%s;", _box, _typename);
					gml.addFormat("%|%s[1] = %s;", _box, _ptrv);
				case BmGrid:
					gml.addString("ds_grid_create(2, 1);");
					gml.addFormat('%|ds_grid_set(%s, 0, 0, "%s");', _box, _typename);
					gml.addFormat('%|ds_grid_set(%s, 1, 0, %s);', _box, _ptr);
			}
		gml.addFormat("%-} else %s = %s;", _box, boxMode == BmGrid ? '-1' : 'undefined');
		return _box;
	}
	override public function usesStructs(type:CppType):Bool {
		return true;
	}
	override public function usesGmkSpec(type:CppType):Bool {
		return true;
	}
}