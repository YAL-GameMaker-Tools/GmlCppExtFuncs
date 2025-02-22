package misc;
import tools.CppBuf;
using StringTools;

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
	public var templateStart:String = null;
	public var templateEnd:String = null;
	public function new(name:String) {
		this.name = name;
		bufMethods.indent = 1;
		bufStatics.indent = 1;
	}
	public function setTemplate(tpl:String) {
		static var rxCode = ~/\$code\b/;
		if (templateStart != null) {
			CppGen.warn('Constructor $name already has a template!');
		}
		if (rxCode.match(tpl)) {
			templateStart = rxCode.matchedLeft().rtrim();
			templateEnd = rxCode.matchedRight();
		} else {
			templateStart = tpl;
		}
	}
	public static function find(name:String) {
		var ctr = map[name];
		if (ctr == null) {
			ctr = new GmlConstructor(name);
			list.push(ctr);
			map[name] = ctr;
		}
		return ctr;
	}
	public static function print(out:CppBuf) {
		if (list.length == 0) return;
		out.addFormat("// auto-generated!");
		for (ctr in list) {
			out.addFormat("%|%|");
			var param = ctr.isID ? "_id" : "_ptr";
			if (ctr.templateStart != null) {
				out.addString(ctr.templateStart);
			} else {
				out.addFormat("function %s(%s) constructor %{", ctr.name, param);
				out.addFormat("%|%s = %s;", ctr.isID ? "__id__" : "__ptr__", param);
			}
			out.addBuffer(ctr.bufStatics);
			out.addBuffer(ctr.bufMethods);
			if (ctr.templateEnd != null) {
				out.addString(ctr.templateEnd);
			} else {
				out.addFormat("%-}");
			}
		}
	}
}