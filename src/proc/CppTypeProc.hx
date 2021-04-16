package proc;

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
	public function cppRead(cpp:CppBuf, type:CppType):String {
		var ts = type.toCppType();
		return '_buf.read<$ts>()';
	}
	public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		cpp.addFormat('%|_buf.write<%s>(%s);', type.toCppType(), val);
	}
	public function getSize():Int {
		return 8;
	}
	public function getAlignment():Int {
		return getSize();
	}
	public function getGmlDocType(type:CppType):String {
		return null;
	}
}