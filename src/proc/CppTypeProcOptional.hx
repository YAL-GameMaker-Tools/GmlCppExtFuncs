package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcOptional extends CppTypeProc {
	static inline function unpack(type:CppType):CppType {
		return type.params[0];
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var v = '_val_$z';
		gml.addFormat("%|var %s;", v);
		gml.addFormat("%|if (buffer_read(_buf, buffer_bool)) {%+");
		var t = unpack(type);
		var val = t.proc.gmlRead(gml, t, z + 1);
		gml.addFormat("%s = %s;", v, val);
		gml.addFormat("%-} else %s = undefined;", v);
		return v;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var v = '_val_$z';
		gml.addFormat("%|var %s = %s;", v, val);
		gml.addFormat("%|buffer_write(_buf, buffer_bool, %s != undefined);", v);
		gml.addFormat("%|if (%s != undefined) %{", v);
		var t = unpack(type);
		t.proc.gmlWrite(gml, t, z + 1, v);
		gml.addFormat("%-}");
	}
	override public function cppRead(cpp:CppBuf, type:CppType):String {
		var ts = unpack(type).toCppType();
		return '_in.read_optional<$ts>()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		cpp.addFormat('%|%{');
		cpp.addFormat('%|auto& _opt = %s;', val);
		cpp.addFormat('%|if (_opt.has_value()) %{');
		cpp.addFormat('%|_out.write<bool>(true);');
		var t = unpack(type);
		t.proc.cppWrite(cpp, t, '_opt.value()');
		cpp.addFormat('%|%-} else _out.write<bool>(false);');
		cpp.addFormat('%|%-}');
	}
	override public function getGmlDocType(type:CppType):String {
		var t = unpack(type);
		var s = t.proc.getGmlDocTypeEx(t);
		return s != null ? s + "?" : null;
	}
	override public function getSize(type:CppType):Int {
		return unpack(type).getSize() + 1;
	}
	override public function getDynSize(type:CppType, val:String):String {
		var parType = unpack(type);
		if (parType == null) return null;
		var parProc = parType.proc;
		if (parProc == null) return null;
		var parDynSize = parProc.getDynSize(parType, val + ".value()");
		return parDynSize != null ? '$val.has_value() ? 1 + ($parDynSize) : 1' : null;
	}
}