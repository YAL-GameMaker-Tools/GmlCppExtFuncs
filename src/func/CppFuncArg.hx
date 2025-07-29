package func ;

/**
 * ...
 * @author YellowAfterlife
 */
class CppFuncArg {
	/** C++ argument index */
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
	
	/**
		If this argument has a GML argument associated with it, this will be the expression to use.
		When we are auto-generating a constructor, this can also be things like `self.__id__`.
	**/
	public var gmlArgument:String = null;
	public var gmlArgumentIndex:Int = -1;
	public var gmlUnpacked:String = null;
	public var gmlUnpackedPerVersion:Map<Int, String> = new Map();
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