package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcGameHwnd extends CppTypeProc {
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		if (CppGen.config.isGMK) {
			gml.addFormat('%|%bw;', 'ptr', 'window_handle()');
		} else {
			gml.addFormat('%|%bw;', 'u64', 'int64(window_handle())');
		}
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
	override public function usesGmkSpec(type:CppType):Bool {
		return true;
	}
}