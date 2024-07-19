package proc;

import struct.CppStructIO;
import struct.GmlStructIO;
import tools.CppBuf;

class CppTypeProcGmlInOut extends CppTypeProc {
	static function unpack(type:CppType) {
		var t = type.params[0];
		if (t == null) throw "gml_inout requires a type param";
		var tp = t.proc;
		if (tp is CppTypeProcStruct) {
			return { type: t, proc: (cast t.proc:CppTypeProcStruct) };
		} else throw "gml_inout can only be used with structs.";
	}
	override function gmlRead(gml:CppBuf, type:CppType, depth:Int):String {
		return unpack(type).type.gmlRead(gml, depth);
	}
	override function gmlWrite(gml:CppBuf, type:CppType, depth:Int, val:String) {
		var p = unpack(type);
		var vp = '_struct_' + depth;
		gml.addFormat("%|%vdp = %s;", vp, val);
		gml.addFormat("%|if (");
		switch (CppGen.config.storageMode) {
			case SmStruct: gml.addFormat('variable_struct_names_count(%s) != 0', vp);
			case SmArray: gml.addFormat('array_length(%s) != 0', vp);
			case SmMap: gml.addFormat('!ds_map_empty(%s)', vp);
			case SmList: gml.addFormat('!ds_list_empty(%s)', vp);
		}
		gml.addFormat(") %{");
			gml.addFormat("%|buffer_write(_buf, buffer_bool, true);");
			var struct = p.proc.struct;
			GmlStructIO.writeFields(struct, gml, depth, vp);
		gml.addFormat("%-} else buffer_write(_buf, buffer_bool, false);");
	}
	override function cppRead(cpp:CppBuf, type:CppType, vp:String):String {
		var p = unpack(type);
		cpp.addFormat("%|%s %s;", p.type.toCppType(), vp);
		cpp.addFormat("%|if (_in.read<bool>()) %{");
			CppStructIO.readFields(p.proc.struct, cpp, vp);
		cpp.addFormat("%-} else %s = {};", vp);
		return vp;
	}
	override function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String) {
		unpack(type).type.cppWrite(cpp, prefix, val);
	}
	override function cppDynSize(cpp:CppBuf, type:CppType, prefix:String, val:String, result:String):Int {
		var p = unpack(type);
		return 1 + p.proc.cppDynSize(cpp, p.type, prefix, val, result);
	}
	override function gmlReadOut(gml:CppBuf, type:CppType, depth:Int, out:String) {
		var p = unpack(type);
		var structVar = '_struct_$depth';
		gml.addFormat("%|%vdp = %s;", structVar, out);
		GmlStructIO.readFields(p.proc.struct, gml, depth, structVar, true);
	}
	override function isOut():Bool {
		return true;
	}
	override function seekRec(type:CppType, fn:CppType -> Bool):Bool {
		return fn(unpack(type).type);
	}
}