package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcGmlBuffer extends CppTypeProc {
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		return '_in.read_gml_buffer()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		cpp.addFormat('%|_out.write_gml_buffer($val);');
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var v = '_val_$z';
		gml.addFormat("%|var %s = %s;", v, val);
		gml.addFormat("%|if (buffer_exists(%s)) %{", v);
		gml.addFormat("%|buffer_write(_buf, buffer_u64, int64(buffer_get_address(%s)));", v);
		gml.addFormat("%|buffer_write(_buf, buffer_s32, buffer_get_size(%s));", v);
		gml.addFormat("%|buffer_write(_buf, buffer_s32, buffer_tell(%s));", v);
		gml.addFormat("%-} else %{");
		gml.addFormat("%|buffer_write(_buf, buffer_u64, 0);");
		gml.addFormat("%|buffer_write(_buf, buffer_s32, 0);");
		gml.addFormat("%|buffer_write(_buf, buffer_s32, 0);");
		gml.addFormat("%-}");
	}
	override public function getGmlDocType(type:CppType):String {
		return "buffer";
	}
}