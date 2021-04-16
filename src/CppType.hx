package ;
import proc.CppTypeProc;

/**
 * ...
 * @author YellowAfterlife
 */
class CppType {
	public static var useMap:Map<String, Bool> = new Map();
	
	public var name:String;
	public var isConst:Bool = false;
	public var isPointer:Bool = false;
	public var isRef:Bool = false;
	public var params:Array<CppType> = [];
	
	public var proc(get, never):CppTypeProc;
	function get_proc():CppTypeProc {
		if (__proc == null) __proc = CppTypeHelper.find(this);
		return __proc;
	}
	var __proc:CppTypeProc = null;
	
	public function new(name:String) {
		this.name = name;
		useMap[name] = true;
	}
	
	/** If this is a vector<T>, returns T */
	public function unpackVector():CppType {
		return name == "vector" && params.length == 1 ? params[0] : null;
	}
	
	/** If this is a vector<T>, returns T */
	public function unpackGmlVector():CppType {
		return name == "gml_vector" && params.length == 1 ? params[0] : null;
	}
	
	public static function read(q:CppReader, ?name:String):CppType {
		q.skipSpaces();
		if (name == null) name = q.readIdent();
		if (name == "") return null;
		var isConst = false;
		while (q.loop) {
			switch (name) {
				case "unsigned":
					name = "unsigned " + q.readSpIdent();
				case "const":
					isConst = true;
					name = q.readSpIdent();
				default:
					if (q.peekn(2) == "::") {
						q.skip(2);
						name = q.readSpIdent();
					} else break;
			}
		}
		if (name == "") return null;
		//
		var cppType = new CppType(name);
		cppType.isConst = isConst;
		//
		q.skipSpaces();
		if (q.peek() == "<".code) {
			q.skip();
			while (q.loop) {
				cppType.params.push(read(q));
				q.skipSpaces();
				switch (q.read()) {
					case ",".code:
						q.skipSpaces();
					case ">".code: break;
				}
			}
		}
		//
		q.skipSpaces();
		cppType.isPointer = q.skipIfEqu("*".code);
		cppType.isRef = q.skipIfEqu("&".code);
		//
		return cppType;
	}
	
	public function toGmlCppType():String {
		if (isPointer) switch (name) {
			case "char", "byte", "uint8_t": return 'const $name*';
		}
		return switch (name) {
			case "void", "bool",
				"char", "int8_t", "uint8_t", "byte",
				"short", "int16_t", "uint16_t",
				"int", "int32_t", "uint32_t",
				"float", "double"
			: "double";
			default: null;
		}
	}
	
	private var __toCppType_cache:String;
	public function toCppType() {
		if (__toCppType_cache != null) return __toCppType_cache;
		var s = new StringBuf();
		if (isConst) s.add("const ");
		s.add(name);
		if (params.length > 0) {
			s.add("<");
			var sep = false;
			for (param in params) {
				if (sep) s.add(", "); else sep = true;
				s.add(param.toCppType());
			}
			s.add(">");
		}
		if (isPointer) s.add("*");
		if (isRef) s.add("&");
		__toCppType_cache = s.toString();
		return __toCppType_cache;
	}
	
	@:keep public function toString() {
		return toCppType();
	}
}