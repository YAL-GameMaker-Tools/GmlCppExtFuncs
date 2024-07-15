package proc;
import tools.CppBuf;

/**
 * todo: implement inline vector and struct readers/writers instead
 * @author YellowAfterlife
 */
class CppTypeProcStringVector extends CppTypeProc {
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var _arr = '_arr_$z';
		var _ind = '_ind_$z';
		var _len = '_len_$z';
		gml.addFormat("var %s = buffer_read(_buf, buffer_u32);", _len);
		gml.addFormat("%|var %s = array_create(%s);", _arr, _len);
		gml.addFormat("%|for (var %s = 0; %s < %s; %s++) {%+", _ind, _ind, _len, _ind);
		gml.addFormat("%s[%s] = buffer_read(_buf, buffer_string);", _arr, _ind);
		gml.addFormat("%-}%|");
		return _arr;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var _arr = '_arr_$z';
		var _ind = '_ind_$z';
		var _len = '_len_$z';
		gml.addFormat("%|var %s = %s;", _arr, val);
		gml.addFormat("%|var %s = array_length_1d(%s);", _len, _arr);
		gml.addFormat('%|%bw;', 'u32', _len);
		gml.addFormat("%|for (var %s = 0; %s < %s; %s++) %{", _ind, _ind, _len, _ind);
			gml.addFormat('%|%bw;', 'string', '$_arr[$_ind]');
		gml.addFormat("%-}");
	}
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		return '_in.read_string_vector()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		cpp.addFormat('%|_out.write_string_vector($val);');
	}
	override public function getGmlDocType(type:CppType):String {
		return "array<string>";
	}
	override public function usesStructs(type:CppType):Bool {
		return false;
	}
	// todo: dynsize
}