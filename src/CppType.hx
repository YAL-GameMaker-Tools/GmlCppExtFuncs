package ;
import proc.CppTypeProc;
import tools.CppReader;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class CppType {
	public static var useMap:Map<String, Bool> = new Map();
	public static var typedefs:Map<String, CppType> = new Map();
	public static var docNames:Map<String, String> = new Map();
	
	public var name:String;
	public var isConst:Bool = false;
	/** 0 -> int, 1 -> int*, 2 -> int**, etc. */
	public var ptrCount:Int = 0;
	public var isRef:Bool = false;
	public var params:Array<CppType> = [];
	public var docKey:String;
	
	public function new(name:String) {
		this.name = name;
		docKey = name;
		useMap[name] = true;
	}
	public function copy():CppType {
		var t = new CppType(name);
		t.isConst = isConst;
		t.ptrCount = ptrCount;
		t.isRef = isRef;
		for (p in params) t.params.push(p.copy());
		return t;
	}
	
	public var proc(get, never):CppTypeProc;
	function get_proc():CppTypeProc {
		if (__proc == null) __proc = CppTypeHelper.find(this);
		return __proc;
	}
	var __proc:CppTypeProc = null;
	
	public function getSize():Int {
		return proc.getSize(this);
	}
	public function getAlignment():Int {
		return proc.getAlignment(this);
	}
	
	//{ unpack
	
	/** If this is a vector<T>, returns T */
	public function unpackVector():CppType {
		return name == "vector" ? params[0] : null;
	}
	
	public function unpackOptional():CppType {
		return name == "optional" ? params[0] : null;
	}
	
	/** If this is a vector<T>, returns T */
	public function unpackGmlVector():CppType {
		return name == "gml_vector" && params.length == 1 ? params[0] : null;
	}
	
	//}
	
	public static function read(q:tools.CppReader, ?name:String):CppType {
		var typePrefix = name;
		var typeStart = q.pos;
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
		var cppType = typedefs[name];
		var isTypedef = cppType != null;
		var wantCopy = isTypedef;
		var wantReset = isTypedef;
		inline function prepare():CppType {
			if (wantCopy) {
				wantCopy = false;
				cppType = cppType.copy();
			}
			return cppType;
		}
		//
		if (cppType == null) {
			cppType = new CppType(name);
		} else cppType.docKey = name;
		if (isConst) prepare().isConst = isConst;
		//
		q.skipSpaces();
		if (q.peek() == "<".code) {
			prepare();
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
		while (q.skipIfEqu("*".code)) {
			prepare().ptrCount++;
			q.skipSpaces();
		}
		if (q.skipIfEqu("&".code)) {
			prepare().isRef = true;
		}
		//
		var fullType = q.substring(typeStart, q.pos);
		if (typePrefix != null) fullType = typePrefix + fullType;
		cppType.__toCppType_cache = fullType.trim();
		return cppType;
	}
	
	public function toGmlCppType():String {
		if (ptrCount == 1) switch (name) {
			case "char", "byte", "uint8_t": return '$name*';
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
	private var __toCppType_name:String;
	public function toCppType() {
		if (__toCppType_cache != null) return __toCppType_cache;
		var s = new StringBuf();
		if (isConst) s.add("const ");
		
		if (__toCppType_name != null) {
			s.add(__toCppType_name);
		} else s.add(name);
		
		if (params.length > 0) {
			s.add("<");
			var sep = false;
			for (param in params) {
				if (sep) s.add(","); else sep = true;
				s.add(param.toCppType());
			}
			s.add(">");
		}
		for (_ in 0 ... ptrCount) s.add("*");
		if (isRef) s.add("&");
		__toCppType_cache = s.toString();
		return __toCppType_cache;
	}
	
	private var __toKey_cache:String;
	public function toKey():String {
		if (__toKey_cache != null) return __toKey_cache;
		var s = new StringBuf();
		s.add(name);
		if (params.length > 0) {
			s.add("<");
			var sep = false;
			for (param in params) {
				if (sep) s.add(","); else sep = true;
				s.add(param.toKey());
			}
			s.add(">");
		}
		for (_ in 0 ... ptrCount) s.add("*");
		__toKey_cache = s.toString();
		return __toKey_cache;
	}
	
	@:keep public function toString() {
		return toCppType();
	}
}