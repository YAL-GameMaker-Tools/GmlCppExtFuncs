package proc;
import proc.CppTypeProcTuple;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcOptional extends CppTypeProc {
	public static inline function unpack(type:CppType):CppType {
		return type.params[0];
	}
	
	public static inline var zeroString = "(0)";
	static function getDefValue_1(type:CppType, gmk:Bool){
		var tp = type.proc;
		var ds = CppGen.config.preferDS;
		if (tp is CppTypeProcOptional) {
			return getDefValue_1(unpack(type), gmk);
		}
		if ((tp is CppTypeProcStruct) || (tp is CppTypeProcVector)) {
			return gmk || ds ? "-1" : null;
		}
		if (tp is CppTypeProcGmlPointer) return gmk ? "-1" : null;
		if (tp is CppTypeProcString) return gmk ? zeroString : null;
		if (tp is CppTypeProcSimple) return gmk ? '""' : null;
		return gmk ? "chr(0)" : null;
	}
	public static function getDefValue(type:CppType, ?struct:Bool, ?gmk:Bool) {
		if (struct == null) struct = CppGen.config.boxMode == BmStruct;
		
		if (gmk == null) gmk = CppGen.config.isGMK;
		if (struct) return "undefined";
		
		var v = getDefValue_1(type, gmk);
		if (v == null) v = "undefined";
		
		return v;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var v = '_val_$z';
		var f = '_flag_$z';
		var t = unpack(type);
		var u = getDefValue(t);
		gml.addFormat("%|%vdp = %s;", v, val);
		gml.addFormat("%|%vdp = ", f);
		if (u == '""') {
			gml.addFormat("is_real(%s);", v);
		} else if (u == "0") {
			gml.addFormat("is_string(%s);", v);
		} else {
			gml.addFormat("%s != %s;", v, u);
		}
		gml.addFormat('%|%bw;', 'bool', f);
		gml.addFormat("%|if (%s) %{", f);
			t.proc.gmlWrite(gml, t, z + 1, v);
		gml.addFormat("%-}");
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var v = '_val_$z';
		gml.addFormat("%|var %s;", v);
		gml.addFormat("%|if (buffer_read(_buf, buffer_bool)) %{");
			var t = unpack(type);
			var val = t.proc.gmlRead(gml, t, z + 1);
			gml.addFormat("%|%s = %s;", v, val);
		var u = getDefValue(type);
		gml.addFormat("%-} else %s = %s;", v, u);
		return v;
	}
	
	override public function cppRead(cpp:CppBuf, type:CppType, vp:String):String {
		cpp.addFormat("%|%s %s;", type.toCppType(), vp);
		cpp.addFormat("if (_in.read<bool>()) %{");
			var ot = unpack(type);
			var val = ot.proc.cppRead(cpp, ot, vp + '_v');
			cpp.addFormat("%|%s = %s;", vp, val);
		cpp.addFormat("%-} else %s = {};", vp);
		return vp;
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, vp:String, val:String):Void {
		cpp.addFormat('%|auto& %s = %s;', vp, val);
		cpp.addFormat('%|if (%s.has_value()) %{', vp);
			cpp.addFormat('%|_out.write<bool>(true);');
			var t = unpack(type);
			t.proc.cppWrite(cpp, t, vp + '_v', vp + '.value()');
		cpp.addFormat('%-} else _out.write<bool>(false);');
	}
	
	override public function getGmlDocType(type:CppType):String {
		var t = unpack(type);
		var s = t.proc.getGmlDocTypeEx(t);
		return s != null ? s + "?" : null;
	}
	
	override public function getSize(type:CppType):Int {
		return unpack(type).getSize() + 1;
	}
	override function cppDynSize(cpp:CppBuf, type:CppType, vp:String, val:String, out:String):Int {
		cpp.addFormat("%|auto& %s = %s;", vp, val);
		cpp.addFormat("%|if (%s.has_value()) %{", vp);
			var fixed = unpack(type).cppDynSize(cpp, vp + "_v", val + ".value()", out);
			if (fixed > 0) cpp.addFormat("%|%s += %d;", out, fixed);
		cpp.addFormat("%-}");
		return 1;
	}
	override function seekRec(type:CppType, fn:CppType -> Bool):Bool {
		var t = unpack(type);
		return t != null && fn(t);
	}
	override function usesGmkSpec(type:CppType):Bool {
		return true;
	}
}
class CppTypeProcTinyOptional extends CppTypeProcOptional {
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		var ts = CppTypeProcOptional.unpack(type).toCppType();
		return '_in.read_tiny_optional<$ts>()';
	}
}