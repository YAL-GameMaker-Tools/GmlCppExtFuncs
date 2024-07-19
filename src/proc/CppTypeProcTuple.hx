package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcTuple extends CppTypeProc {
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var _tup = '_tup_$z';
		gml.addFormat("var %s = array_create(%d);%|", _tup, type.params.length);
		for (i => tupType in type.params) {
			var val = tupType.proc.gmlRead(gml, tupType, z + 1);
			gml.addFormat("%s[%d] = %s;%|", _tup, i, val);
		}
		return _tup;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var _tup = '_tup_$z';
		gml.addFormat("%|var %s = %s;", _tup, val);
		for (i => tupType in type.params) {
			var val = _tup + "[" + i + "]";
			tupType.proc.gmlWrite(gml, tupType, z + 1, val);
		}
	}
	
	static inline function getPrefix(prefix:String, ind:Int) {
		return prefix + "_t" + ind;
	}
	
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		cpp.addFormat("%|%s %s; %{", type.toCppType(), prefix);
		var vb = new CppBuf();
		for (i => tupType in type.params) {
			var tupVar = prefix + "_t" + i;
			cpp.addFormat("%|%s %s = %s;",
				tupType.toCppType(),
				tupVar,
				tupType.proc.cppRead(cpp, tupType, getPrefix(prefix, i))
			);
			if (i > 0) vb.add(", ");
			vb.add(tupVar);
		}
		cpp.addFormat("%|%s = { %b };", prefix, vb);
		cpp.addFormat("%-}");
		return prefix;
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String):Void {
		var v = prefix;
		//cpp.addFormat('%|%{');
		cpp.addFormat('%|auto& %s = %s;', v, val);
		for (i => t in type.params) {
			t.proc.cppWrite(cpp, t, getPrefix(prefix, i), 'std::get<$i>($v)');
		}
		//cpp.addFormat('%-}');
	}
	
	override function getSize(type:CppType):Int {
		var n = 0;
		for (t in type.params) n += t.getSize();
		return n;
	}
	override function hasDynSize(type:CppType):Bool {
		for (t in type.params) {
			if (t.hasDynSize()) return true;
		}
		return false;
	}
	override function cppDynSize(cpp:CppBuf, type:CppType, vp:String, val:String, result:String):Int {
		var n = 0;
		cpp.addFormat("%|auto& %s = %s;", vp, val);
		for (i => t in type.params) {
			n += t.cppDynSize(cpp, getPrefix(vp, i), 'std::get<$i>($vp)', result);
		}
		return n;
	}
	
	override function seekRec(type:CppType, fn:(CppType) -> Bool):Bool {
		for (t in type.params) if (fn(t)) return true;
		return false;
	}
	
	override public function usesStructs(type:CppType):Bool {
		for (t in type.params) if (t.proc.usesStructs(t)) return true;
		return false;
	}
	override public function usesGmkSpec(type:CppType):Bool {
		for (t in type.params) if (t.proc.usesGmkSpec(t)) return true;
		return false;
	}
}