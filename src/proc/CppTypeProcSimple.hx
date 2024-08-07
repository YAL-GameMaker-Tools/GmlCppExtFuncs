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
		return docType;
	}
}
class CppTypeProcSimpleChar extends CppTypeProcSimple {
	override public function getGmlDocType(type:CppType):String {
		if (type.ptrCount == 1) return "string";
		return super.getGmlDocType(type);
	}
}