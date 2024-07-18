package proc;
import proc.CppTypeProc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcError extends CppTypeProc {
	private var name:String;
	public function new(name:String) {
		super();
		this.name = name;
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		return 'show_error("Unsupported type $name", true)';
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		gml.addFormat('%|show_error("Unsupported type %s", true)', name);
	}
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		return 'void/* Unsupported type $name */';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String):Void {
		cpp.addFormat("%|#error Unsupported type %s", name);
	}
}