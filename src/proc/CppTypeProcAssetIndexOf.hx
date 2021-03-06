package proc;
import tools.CppBuf;
import func.CppFuncArg;
import proc.CppTypeProc;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcAssetIndexOf extends CppTypeProc {
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		gml.addFormat("%|buffer_write(_buf, buffer_s32, asset_get_index(\"%s\"));", CppFuncArg.current.name);
	}
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		var ts = type.toCppType();
		return '($ts)_in.read<int32_t>()';
	}
	override public function useGmlArgument():Bool {
		return false;
	}
	override public function getSize(type:CppType):Int {
		return 4;
	}
}