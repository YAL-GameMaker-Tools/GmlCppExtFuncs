package misc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class GmlConstructor {
	public static var map:Map<String, GmlConstructor> = new Map();
	public static var list:Array<GmlConstructor> = [];
	//
	public var name:String;
	public var cppType:String = null;
	public var isID:Null<Bool> = null;
	public var bufMethods:CppBuf = new CppBuf();
	public var bufStatics:CppBuf = new CppBuf();
	public function new(name:String) {
		this.name = name;
		bufMethods.indent = 1;
		bufStatics.indent = 1;
	}
	public static function print(out:CppBuf) {
		if (list.length == 0) return;
		out.addFormat("// auto-generated!");
		for (ctr in list) {
			out.addFormat("%|%|");
			var param = ctr.isID ? "_id" : "_ptr";
			out.addFormat("function %s(%s) constructor %{", ctr.name, param);
			out.addFormat("%|%s = %s;", ctr.isID ? "__id__" : "__ptr__", param);
			out.addBuffer(ctr.bufStatics);
			out.addBuffer(ctr.bufMethods);
			out.addFormat("%-}");
		}
	}
}