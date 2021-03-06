package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProc {
	public function new() {
		
	}
	public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		throw "todo";
	}
	public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		throw "todo";
	}
	public function gmlCleanup(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		
	}
	public function cppRead(cpp:CppBuf, type:CppType):String {
		var ts = type.toCppType();
		return '_in.read<$ts>()';
	}
	public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		cpp.addFormat('%|_out.write<%s>(%s);', type.toCppType(), val);
	}
	public function getSize(type:CppType):Int {
		return 8;
	}
	public function getAlignment(type:CppType):Int {
		return getSize(type);
	}
	public function getGmlDocType(type:CppType):String {
		return null;
	}
	public function getGmlDocTypeEx(type:CppType):String {
		var t = CppType.docNames[type.docKey];
		return t != null ? t : getGmlDocType(type);
	}
	public function usesStructs(type:CppType):Bool {
		return false;
	}
	public function useGmlArgument():Bool {
		return true;
	}
}