package func ;

/**
 * ...
 * @author YellowAfterlife
 */
class CppFuncArg {
	public var index:Int;
	public var type:CppType;
	public var name:String;
	/** default value (if omitted) **/
	public var value:String = null;
	/** like `double` or `const char*`. If it's null, it goes in the buffer **/
	public var exportType:String;
	/** but also we'll put things in the buffer if we're out of argument space **/
	public var putInBuffer = true;
	public var isSelf = false;
	public var gmlArgument:String = null;
	public var gmlUnpacked:String = null;
	public static var current:CppFuncArg = null;
	public function new(index:Int, type:CppType, name:String) {
		this.index = index;
		this.type = type;
		this.name = name;
	}
	public function isOut() {
		return type.proc.isOut();
	}
}