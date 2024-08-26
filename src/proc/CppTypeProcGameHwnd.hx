package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcGameHwnd extends CppTypeProc {
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var x = CppGen.config.gmlWindowHandle;
		if (CppGen.config.isGMK) {
			gml.addFormat('%|%bw;', 'ptr', x);
		} else {
			gml.addFormat('%|%bw;', 'u64', 'int64($x)');
		}
	}
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
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