package ;

/**
 * ...
 * @author YellowAfterlife
 */
class CppFuncArg {
	public var type:CppType;
	public var name:String;
	public var value:String = null;
	public function new(type:CppType, name:String) {
		this.type = type;
		this.name = name;
	}
}