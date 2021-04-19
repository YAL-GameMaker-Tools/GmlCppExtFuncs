package proc;
import proc.CppTypeProc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcSimple extends CppTypeProc {
	public var bufType:String;
	public var docType:String;
	public var size:Int;
	public function new(bufType:String, docType:String, size:Int) {
		super();
		this.bufType = bufType;
		this.docType = docType;
		this.size = size;
	}
	override public function gmlRead(gml:CppBuf, type:CppType, depth:Int):String {
		return 'buffer_read(_buf, $bufType)';
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, depth:Int, val:String):Void {
		gml.addFormat('%|buffer_write(_buf, %s, %s);', bufType, val);
	}
	override public function getSize(type:CppType):Int {
		return size;
	}
	override public function getGmlDocType(type:CppType):String {
		return docType;
	}
}