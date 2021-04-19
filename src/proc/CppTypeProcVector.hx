package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcVector extends CppTypeProc {
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var _arr = '_arr_$z';
		var _ind = '_ind_$z';
		var _len = '_len_$z';
		gml.addFormat("var %s = buffer_read(_buf, buffer_u32);", _len);
		gml.addFormat("%|var %s = array_create(%s);", _arr, _len);
		gml.addFormat("%|for (var %s = 0; %s < %s; %s++) {%+", _ind, _ind, _len, _ind);
		var vect = type.params[0];
		var val = vect.proc.gmlRead(gml, vect, z +1);
		gml.addFormat("%s[%s] = %s;", _arr, _ind, val);
		gml.addFormat("%-}%|");
		return _arr;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var _arr = '_arr_$z';
		var _ind = '_ind_$z';
		var _len = '_len_$z';
		gml.addFormat("%|var %s = %s;", _arr, val);
		gml.addFormat("%|var %s = array_length_1d(%s);", _len, _arr);
		gml.addFormat("%|buffer_write(_buf, buffer_u32, %s);", _len);
		gml.addFormat("%|for (var %s = 0; %s < %s; %s++) %{", _ind, _ind, _len, _ind);
		var vect = type.params[0];
		vect.proc.gmlWrite(gml, vect, z + 1, '$_arr[$_ind]');
		gml.addFormat("%-}");
	}
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		var ts = type.unpackVector().toCppType();
		return '_buf.read_vector<$ts>()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		var ts = type.unpackVector().toCppType();
		cpp.addFormat('%|_buf.write_vector<$ts>($val);');
	}
	override public function getGmlDocType(type:CppType):String {
		var t = type.params[0];
		var inner = t.proc.getGmlDocTypeEx(t);
		if (inner == null) inner = "any";
		return "array<" + inner + ">";
	}
	override public function usesStructs(type:CppType):Bool {
		var t = type.params[0];
		return t.proc.usesStructs(t);
	}
}