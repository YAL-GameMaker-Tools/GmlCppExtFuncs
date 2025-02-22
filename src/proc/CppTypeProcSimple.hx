package proc;
import proc.CppTypeProc;
import tools.CppBuf;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcSimple extends CppTypeProc {
	public var bufType:String;
	public var shortBufType:String;
	public var docType:String;
	public var size:Int;
	public function new(bufType:String, docType:String, size:Int) {
		super();
		this.bufType = bufType;
		if (bufType.startsWith('buffer_')) {
			shortBufType = bufType.substring('buffer_'.length);
		} else throw 'Unexpected buffer type "$bufType"';
		this.docType = docType;
		this.size = size;
	}
	override public function gmlRead(gml:CppBuf, type:CppType, depth:Int):String {
		return 'buffer_read(_buf, $bufType)';
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, depth:Int, val:String):Void {
		gml.addFormat('%|%bw;', shortBufType, val);
	}
	override public function getSize(type:CppType):Int {
		return size;
	}
	override public function getGmlDocType(type:CppType):String {
		// TODO: JSDoc types
		return docType;
	}
}
class CppTypeProcSimpleChar extends CppTypeProcSimple {
	override public function getGmlDocType(type:CppType):String {
		if (type.ptrCount == 1) return "string";
		return super.getGmlDocType(type);
	}
}
class CppTypeProcSimpleIntPtr extends CppTypeProcSimple {
	public function new(){
		super("buffer_u64", "int", 8);
	}
	override public function gmlRead(gml:CppBuf, type:CppType, depth:Int):String {
		if (CppGen.config.isGMK) {
			return 'buffer_read(_buf, buffer_s32)';
		} else return "ptr(" + super.gmlRead(gml, type, depth) + ")";
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, depth:Int, val:String):Void {
		if (CppGen.config.isGMK) {
			gml.addFormat('%|%bw;', "s32", val);
		} else {
			super.gmlWrite(gml, type, depth, val);
		}
	}
	override public function usesGmkSpec(type:CppType):Bool {
		return true;
	}
}