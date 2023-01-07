package proc;

/**
 * ...
 * @author 
 */
class CppTypeProcString extends CppTypeProcSimple {
	public function new() {
		super("buffer_string", "string", 8);
	}
	override public function getDynSize(type:CppType, val:String):String {
		return '1 + strlen($val)';
	}
}