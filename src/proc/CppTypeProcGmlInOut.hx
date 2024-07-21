package proc;

import struct.CppStructIO;
import struct.GmlStructIO;
import tools.CppBuf;

class CppTypeProcGmlInOut extends CppTypeProc {
	static function unpack(type:CppType) {
		var t = type.params[0];
		if (t == null) throw "gml_inout requires a type param";
		var sp:CppTypeProcStruct;
		sp = (t.proc is CppTypeProcStruct) ? cast t.proc : null;
		return {
			type: t,
			proc: t.proc,
			sp: sp,
		};
	}
	override function gmlRead(gml:CppBuf, type:CppType, depth:Int):String {
		return unpack(type).type.gmlRead(gml, depth);
	}
	override function gmlWrite(gml:CppBuf, type:CppType, depth:Int, val:String) {
		var p = unpack(type);
		var vp = (p.sp != null ? '_struct_' : '_box_') + depth;
		var isGMK = CppGen.config.isGMK;
		gml.addFormat("%|%vdp = %s;", vp, val);
		gml.addFormat("%|if (");
		if (p.sp == null) {
			if (isGMK) {
				gml.addFormat("!ds_list_empty(%s)", vp);
			} else {
				gml.addFormat("array_length_1d(%s)", vp);
			}
		} else switch (CppGen.config.storageMode) {
			case SmStruct: gml.addFormat('variable_struct_names_count(%s) != 0', vp);
			case SmArray: gml.addFormat('array_length_1d(%s) != 0', vp);
			case SmMap: gml.addFormat('!ds_map_empty(%s)', vp);
			case SmList: gml.addFormat('!ds_list_empty(%s)', vp);
		}
		gml.addFormat(") %{");
		gml.addFormat("%|buffer_write(_buf, buffer_bool, true);");
		if (p.sp == null) {
			var item = isGMK ? 'ds_list_find_value($vp)' : '$vp[0]';
			p.type.gmlWrite(gml, depth, item);
		} else {
			var struct = p.sp.struct;
			GmlStructIO.writeFields(struct, gml, depth, vp);
		}
		gml.addFormat("%-} else buffer_write(_buf, buffer_bool, false);");
	}
	override function cppRead(cpp:CppBuf, type:CppType, vp:String):String {
		var p = unpack(type);
		cpp.addFormat("%|%s %s;", p.type.toCppType_mutable(), vp);
		cpp.addFormat("%|if (_in.read<bool>()) %{");
		if (p.sp != null) {
			CppStructIO.readFields(p.sp.struct, cpp, vp);
		} else {
			cpp.addFormat("%|%s = %s;", vp, p.type.cppRead(cpp, vp + "_val"));
		}
		cpp.addFormat("%-} else %s = {};", vp);
		return vp;
	}
	override function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String) {
		unpack(type).type.cppWrite(cpp, prefix, val);
	}
	override function getSize(type:CppType):Int {
		var p = unpack(type);
		return 1 + p.type.getSize();
	}
	override function cppDynSize(cpp:CppBuf, type:CppType, prefix:String, val:String, result:String):Int {
		var p = unpack(type);
		return 1 + p.proc.cppDynSize(cpp, p.type, prefix, val, result);
	}
	override function gmlReadOut(gml:CppBuf, type:CppType, depth:Int, out:String) {
		var p = unpack(type);
		if (p.sp != null) {
			var vp = "_struct_" + depth;
			gml.addFormat("%|%vdp = %s;", vp, out);
			switch (CppGen.config.storageMode) {
				case SmStruct, SmArray: {}; // OK!
				case SmMap: gml.addFormat("%|ds_map_clear(%s);", vp);
				case SmList: gml.addFormat("%|ds_list_clear(%s);", vp);
			}
			GmlStructIO.readFields(p.sp.struct, gml, depth, vp, true);
		} else {
			var vp = "_box_" + depth;
			var vp_val = "_val_" + depth;
			gml.addFormat("%|%vdp = %s;", vp, out);
			gml.addFormat("%|var %s;", vp_val);
			p.type.gmlReadOut(gml, depth + 1, vp);
			var isGMK = CppGen.config.isGMK;
			if (isGMK) {
				gml.addFormat("%|if (ds_list_empty(%s)) %{", vp);
					gml.addFormat("%|ds_list_add(%s, %s);", vp, vp_val);
				gml.addFormat("%-} else %{");
					gml.addFormat("%|ds_list_replace(%s, 0, %s);", vp, vp_val);
				gml.addFormat("%-}");
			} else {
				gml.addFormat("%|%s[@0] = %s;", vp, vp_val);
			}
		}
	}
	override function isOut():Bool {
		return true;
	}
	override function seekRec(type:CppType, fn:CppType -> Bool):Bool {
		return fn(unpack(type).type);
	}
}