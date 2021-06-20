package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcGameHwnd extends CppTypeProc {
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		gml.addFormat("%|buffer_write(_buf, buffer_u64, int64(window_handle()));");
	}
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		var ts = type.toCppType();
		return '($ts)_in.read<uint64_t>()';
	}
	override public function useGmlArgument():Bool {
		return false;
	}
	override public function getSize(type:CppType):Int {
		return 8;
	}
}