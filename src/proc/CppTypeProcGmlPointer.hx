package proc;
import tools.CppBuf;

/**
 * Converts raw C++ pointers to [ptr] / Struct() { __ptr__: ptr }
 * @author YellowAfterlife
 */
class CppTypeProcGmlPointer extends CppTypeProc {
	public var isID:Bool;
	public function new(isID:Bool) {
		super();
		this.isID = isID;
	}
	override public function getSize(type:CppType):Int {
		return 8;
	}
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		var t = type.toCppType();
		return '($t)_in.read<int64_t>();';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		var t = type.toCppType();
		cpp.addFormat("%|_out.write<int64_t>((%s)%s);", isID ? "int64" : "intptr_t", val);
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var _box = '_box_$z';
		var _ptr = isID ? '_id_$z' : '_ptr_$z';
		var _typename = type.params[0].name;
		gml.addFormat("%|var %s = %s;", _box, val);
		
		// make sure it's the right thing:
		var useStructs = CppGen.config.useStructs;
		if (useStructs) {
			gml.addFormat('%|if (instanceof(%s) != "%s")', _box, _typename);
		} else {
			gml.addFormat("%|if (!is_array(%s)", _box);
			gml.addFormat(" || %s[0] != global.__ptrt_%s)", _box, _typename);
		}
		gml.addFormat(' { show_error("Expected a %s, got " + string(%s), true); exit }', _typename, _box);
		
		// make sure it's not destroyed:
		gml.addFormat("%|var %s = %s", _ptr, _box);
		if (useStructs) {
			gml.addString(isID ? ".__id__" : ".__ptr__;");
			gml.addFormat('%|if (%s == %s) ', _ptr, isID ? "0" : "pointer_null");
		} else {
			gml.addString("[1];");
			gml.addFormat('%|if (%s == 0) ', isID ? _ptr : 'int64($_ptr)');
		}
		gml.addFormat('{ show_error("This %s is destroyed.", true); exit; }', _typename);
		
		// destroy if asked:
		if (type.name == (isID ? "gml_id_destroy" : "gml_ptr_destroy")) {
			gml.addFormat("%|%s", _box);
			if (useStructs) {
				gml.addString(isID ? ".__id__" : ".__ptr__");
			} else gml.addString("[@1]");
			gml.addFormat(" = %s;", isID ? "0" : (useStructs ? "pointer_null" : "ptr(0)"));
		}
		gml.addFormat("%|buffer_write(_buf, buffer_u64, int64(%s));", _ptr);
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var _ptr = isID ? '_id_$z' : '_ptr_$z';
		var _box = '_box_$z';
		var _typename = type.params[0].name;
		gml.addFormat("%|var %s = buffer_read(_buf, buffer_u64);", _ptr);
		gml.addFormat("%|var %s;", _box);
		gml.addFormat("%|if (%s != %s) %{", _ptr, isID ? "-1" : "0");
			gml.addFormat("%|%s = ", _box);
			var _ptrv = isID ? _ptr : 'ptr($_ptr)';
			if (CppGen.config.useStructs) {
				gml.addFormat("new %s(%s);", _typename, _ptrv);
			} else {
				gml.addFormat("array_create(2);");
				gml.addFormat("%|%s[0] = global.__ptrt_%s;", _box, _typename);
				gml.addFormat("%|%s[1] = %s;", _box, _ptrv);
			}
		gml.addFormat("%-} else %s = undefined;", _box);
		return _box;
	}
	override public function usesStructs(type:CppType):Bool {
		return true;
	}
}