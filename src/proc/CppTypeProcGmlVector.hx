package proc;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcGmlVector extends CppTypeProcVector {
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		var ts = type.unpackGmlVector().toCppType();
		return '_buf.read_gml_vector<$ts>()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		var ts = type.unpackGmlVector().toCppType();
		cpp.addFormat('%|_buf.write_gml_vector<$ts>($val);');
	}
}