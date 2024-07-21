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
		GmlStructIO.readFields(struct, gml, z, structVar, false);
		return structVar;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var structVar = "_struct_" + z;
		gml.addFormat("%|%vdp = %s;", structVar, val);
		GmlStructIO.writeFields(struct, gml, z, structVar);
	}
	//
	override function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		cpp.addFormat('%|%s %s;', type.toCppType_mutable(), prefix);
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
	override function cppDynSize(cpp:CppBuf, type:CppType, prefix:String, val:String, result:String):Int {
		var fixed = 0;
		var tmp = cpp.fork();
		for (fd in struct.fields) {
			// TODO: what if we have a `dynSizeType x[32]`
			fixed += fd.type.proc.cppDynSize(tmp, fd.type,
				prefix + '_f_' + fd.name,
				prefix + "." + fd.name,
				result
			) * fd.getQuantity();
		}
		if (tmp.hasText) {
			cpp.addFormat("%|auto& %s = %s;", prefix, val);
			cpp.addBuffer(tmp);
		}
		return fixed;
	}
	
	override function seekRec(type:CppType, fn:CppType -> Bool):Bool {
		for (fd in struct.fields) {
			if (fn(fd.type)) return true;
		}
		return false;
	}
	override public function usesStructs(type:CppType):Bool {
		return true;
	}
	override public function usesGmkSpec(type:CppType):Bool {
		return true;
	}
	override function isMap(type:CppType):Bool {
		return CppGen.config.storageMode == SmMap;
	}
	override function isList(type:CppType):Bool {
		return CppGen.config.storageMode == SmList;
	}
}