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
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		cpp.addFormat("%|%s %s; %{", type.toCppType(), prefix);
		var vb = new CppBuf();
		for (i => tupType in type.params) {
			var tupVar = prefix + "_t" + i;
			cpp.addFormat("%|%s %s = %s;",
				tupType.toCppType(),
				tupVar,
				tupType.proc.cppRead(cpp, tupType, prefix + "_" + i)
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
			t.proc.cppWrite(cpp, t, prefix + "_t" + i, 'std::get<$i>($v)');
		}
		//cpp.addFormat('%-}');
	}
	override function getDynSize(type:CppType, val:String):String {
		var parts = [];
		var hasDynSize = false;
		for (i => t in type.params) {
			var d = t.proc.getDynSize(t, 'std::get<$i>($val)');
			parts.push(d);
			if (d != null) hasDynSize = true;
		}
		if (!hasDynSize) return null;
		for (i => sz in parts) if (sz == null) {
			var t = type.params[i];
			parts[i] = "" + t.proc.getSize(t);
		}
		return '(' + parts.join(' + ') + ')';
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