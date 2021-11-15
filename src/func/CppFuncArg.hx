package func ;

/**
 * ...
 * @author YellowAfterlife
 */
class CppFuncArg {
	public var index:Int;
	public var type:CppType;
	public var name:String;
	public var value:String = null;
	public static var current:CppFuncArg = null;
	public function new(index:Int, type:CppType, name:String) {
		this.index = index;
		this.type = type;
		this.name = name;
	}
}