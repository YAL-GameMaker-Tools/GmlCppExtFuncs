package proc;
import tools.CppBuf;

/**
	Converts raw C++ pointers to
	struct: `Struct() { __ptr__: ptr }` (constructor with a pointer)
	non-struct: `[meta, ptr]` (pointer-in-array)
	GM8: `ds_grid() [ meta, ptr ]`
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
	
	public function isDestroy(type:CppType) {
		return type.name == (isID ? "gml_id_destroy" : "gml_ptr_destroy");
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
	function ptrOf(box:String) {
		return switch (CppGen.config.boxMode) {
			case BmStruct: '$box.$ptrVar';
			case BmArray: '$box[1]';
			case BmGrid: 'ds_grid_get($box, 1, 0)';
		}
	}
	function gmlWrite_extractPtr(gml:CppBuf, _ptr, _box, type, _typename) {
		gml.addFormat("%|%vdp = ", _ptr);
		var mode = CppGen.config.boxMode;
		switch (mode) {
			case BmStruct:
				gml.addFormat("%s.%s;", _box, isID ? "__id__" : "__ptr__");
			case BmArray:
				gml.addString(_box);
				gml.addString("[1];");
			case BmGrid:
				gml.addFormat("ds_grid_get(%s, 1, 0);", _box);
		}
	}
	function gmlWrite_checkPtr(gml:CppBuf, _ptr, _box, type, _typename) {
		var mode = CppGen.config.boxMode;
		var check = true;
		switch (mode) {
			case BmStruct:
				gml.addFormat('%|if (%s == %s) ', _ptr, isID ? "0" : "pointer_null");
			case BmArray:
				gml.addFormat('%|if (%s == 0) ', isID ? _ptr : 'int64($_ptr)');
			case BmGrid:
				check = false;
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
	function gmlWrite_value(gml:CppBuf, _ptr) {
		if (CppGen.config.isGMK) {
			gml.addFormat('%|%bw;', 'ptr', _ptr);
		} else if (!isID) {
			gml.addFormat('%|%bw;', 'u64', 'int64($_ptr)');
		} else {
			gml.addFormat('%|%bw;', 'u64', _ptr);
		}
	}
	
	public function gmlWriteSelf(gml:CppBuf, type:CppType, toBuf:Bool) {
		var _typename = type.params[0].name;
		var useLocalVars = isDestroy(type);
		//
		var _ptr:String;
		if (useLocalVars) {
			_ptr = isID ? '_id_self' : '_ptr_self';
			gml.addFormat("%|%vdp = %s", _ptr, ptrOf("self"));
		} else {
			_ptr = ptrOf("self");
		}
		//
		if (toBuf) {
			gmlWrite_checkPtr(gml, _ptr, "self", type, _typename);
			gmlWrite_value(gml, _ptr);
			return _ptr;
		} else {
			gmlWrite_checkPtr(gml, _ptr, "self", type, _typename);
			return _ptr;
		}
	}
	public function gmlWrite_typeCheck(gml:CppBuf, _box, _typename) {
		var mode = CppGen.config.boxMode;
		switch (mode) {
			case BmStruct:
				gml.addFormat('%|if (instanceof(%s) != "%s")', _box, _typename);
			case BmArray:
				gml.addFormat("%|if (");
				//gml.addFormat("!is_array(%s) || ", _box);
				gml.addFormat("%s[0] != global.__ptrt_%s)", _box, _typename);
			case BmGrid:
				gml.addFormat('%|if (ds_grid_get(%s, 0, 0) != "%s")', _box, _typename);
		}
		gml.addFormat(' { show_error("Expected a %s, got " + string(%s), true); exit }', _typename, _box);
	}
	override function gmlUnpack(gml:CppBuf, type:CppType, z:Int, val:String):String {
		var _typename = type.params[0].name;
		var vBox, vPtr;
		var useLocalVars = isDestroy(type);
		if (useLocalVars) {
			vBox = '_box_$z';
			gml.addFormat("%|%vdp = %s;", vBox, val);
		} else vBox = val;
		gmlWrite_typeCheck(gml, vBox, _typename);
		//
		if (useLocalVars) {
			vPtr = isID ? '_id_$z' : '_ptr_$z';
			gml.addFormat("%|%vdp = %s", vPtr, ptrOf(vBox));
			gmlWrite_extractPtr(gml, vPtr, vBox, type, _typename);
		} else vPtr = ptrOf(val);
		gmlWrite_checkPtr(gml, vPtr, vBox, type, _typename);
		//
		return vPtr;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var _ptr = gmlUnpack(gml, type, z, val);
		gmlWrite_value(gml, _ptr);
	}
	//
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