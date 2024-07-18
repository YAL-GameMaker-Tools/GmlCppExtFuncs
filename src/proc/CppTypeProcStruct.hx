package proc;
import haxe.ds.Vector;
import proc.CppTypeProc;
import struct.CppStruct;
import struct.CppStructField;
import struct.*;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcStruct extends CppTypeProc {
	public var struct:CppStruct;
	public function new(struct:CppStruct) {
		super();
		this.struct = struct;
	}
	//
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var structVar = "_struct_" + z;
		gml.addFormat("%|%vdp = ", structVar);
		GmlStructIO.createTail(struct, gml);
		GmlStructIO.readFields(struct, gml, z, structVar);
		return structVar;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var structVar = "_struct_" + z;
		gml.addFormat("%|%vdp = %s", structVar, val);
		GmlStructIO.writeFields(struct, gml, z, structVar);
	}
	//
	override function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		cpp.addFormat('%|%s %s;', type.toCppType(), prefix);
		CppStructIO.readFields(struct, cpp, prefix);
		return prefix;
	}
	override function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String) {
		cpp.addFormat('%|auto& %s = %s;', prefix, val);
		CppStructIO.writeFields(struct, cpp, prefix);
	}
	//
	override public function getSize(type:CppType):Int {
		var size = 0;
		for (fd in struct.fields) size += fd.getSize();
		return size;
	}
	override function getDynSize(type:CppType, val:String):String {
		var parts = new Vector(struct.fields.length);
		var hasDynSize = false;
		for (i => fd in struct.fields) {
			var t = fd.type;
			var dynSize = t.proc.getDynSize(t, '$val.${fd.name}');
			parts[i] = dynSize;
			if (dynSize != null) hasDynSize = true;
		}
		if (!hasDynSize) return null;
		for (i => fd in struct.fields) if (parts[i] == null) {
			parts[i] = "" + fd.getSize();
		}
		return '(' + parts.join(' + ') + ')';
	}
	override public function usesStructs(type:CppType):Bool {
		return true;
	}
	override public function usesGmkSpec(type:CppType):Bool {
		return true;
	}
}