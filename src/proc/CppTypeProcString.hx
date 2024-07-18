package proc;
import tools.CppBuf;

/**
 * ...
 * @author 
 */
class CppTypeProcString extends CppTypeProcSimple {
	public function new() {
		super("buffer_string", "string", 8);
	}
	override public function getDynSize(type:CppType, val:String):String {
		return '1 + strlen($val)';
	}
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		return '_in.read_string()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String):Void {
		cpp.addFormat('%|_out.write_string(%s);', val);
	}
}