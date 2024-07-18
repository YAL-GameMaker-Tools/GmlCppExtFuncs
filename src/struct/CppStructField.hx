package struct ;
import proc.CppTypeProc;

/**
 * ...
 * @author YellowAfterlife
 */
class CppStructField {
	public var type:CppType;
	
	public var name:String;
	public var size:Array<Int> = [];
	
	public function getSize() {
		var n = type.getSize();
		for (m in size) n *= m;
		return n;
	}
	public function new(type:CppType, name:String) {
		this.type = type;
		this.name = name;
	}
}