package proc;
import tools.CppBuf;

/**
 * Converts raw C++ pointers to [
 * @author YellowAfterlife
 */
class CppTypeProcGmlPointer extends CppTypeProc {
	override public function getSize(type:CppType):Int {
		return 8;
	}
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		var t = type.toCppType();
		return '($t)_in.read<int64_t>();';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		var t = type.toCppType();
		cpp.addFormat("%|_out.write<int64_t>((intptr_t)%s);", val);
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var _box = '_box_$z';
		var _ptr = '_ptr_$z';
		var _typename = type.params[0].name;
		gml.addFormat("%|var %s = %s;", _box, val);
		var useStructs = CppGen.config.useStructs;
		if (useStructs) {
			gml.addFormat('%|if (instanceof(%s) != "%s")', _box, _typename);
		} else {
			gml.addFormat("%|if (!is_array(%s)", _box);
			gml.addFormat(" || %s[0] != global.__ptrt_%s)", _box, _typename);
		}
		gml.addFormat(' { show_error("Expected a %s, got " + string(%s), true); exit }', _typename, _box);
		gml.addFormat("%|var %s = %s", _ptr, _box);
		if (useStructs) {
			gml.addString(".__ptr__;");
		} else gml.addString("[1];");
		gml.addFormat('%|if (%s == 0) { show_error(', _ptr);
		gml.addFormat('"This %s is destroyed.", true); exit; }', _typename);
		if (type.name == "gml_ptr_destroy") {
			gml.addFormat("%|%s", _box);
			if (useStructs) {
				gml.addString(".__ptr__");
			} else gml.addString("[@1]");
			gml.addString(" = ptr(0);");
		}
		gml.addFormat("%|buffer_write(_buf, buffer_u64, int64(%s));", _ptr);
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var _ptr = '_ptr_$z';
		var _box = '_box_$z';
		var _typename = type.params[0].name;
		gml.addFormat("%|var %s = buffer_read(_buf, buffer_u64);", _ptr);
		gml.addFormat("%|var %s;", _box);
		gml.addFormat("%|if (%s != 0) %{", _ptr);
			gml.addFormat("%|%s = ", _box);
			if (CppGen.config.useStructs) {
				gml.addFormat("new %s(ptr(%s));", _typename, _ptr);
			} else {
				gml.addFormat("array_create(2);");
				gml.addFormat("%|%s[0] = global.__ptrt_%s;", _box, _typename);
				gml.addFormat("%|%s[1] = ptr(%s);", _box, _ptr);
			}
		gml.addFormat("%-} else %s = undefined;", _box);
		return _box;
	}
	override public function usesStructs(type:CppType):Bool {
		return true;
	}
}