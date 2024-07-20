package proc;

import tools.CppBuf;

class CppTypeProcEnum extends CppTypeProcSimple {
	public var ename:String;
	public var baseType = "int";
	public function new(ename:String) {
		this.ename = ename;
		super("buffer_s32", baseType, 4);
	}
	override function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		return '($ename)_in.read<$baseType>()';
	}
	override function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String) {
		cpp.addFormat('%|_out.write<%s>(%s);', baseType, '($baseType)' + val);
	}
}