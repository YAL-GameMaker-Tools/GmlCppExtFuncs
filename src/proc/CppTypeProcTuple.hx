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
	override public function cppRead(cpp:CppBuf, type:CppType, depth:Int):String {
		var b = new CppBuf();
		b.add("_in.read_tuple<");
		for (i => t in type.params) {
			if (i > 0) b.add(", ");
			b.add(t.toCppType());
		}
		b.add(">();");
		return b.toString();
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, depth:Int, val:String):Void {
		cpp.addFormat("%|_out.write_tuple<");
		for (i => t in type.params) {
			if (i > 0) cpp.add(", ");
			cpp.add(t.toCppType());
		}
		cpp.addFormat(">(%s);", val);
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