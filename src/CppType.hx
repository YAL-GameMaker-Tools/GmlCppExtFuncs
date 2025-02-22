package ;
import proc.CppTypeProcGmlPointer;
import proc.CppTypeProc;
import tools.CppReader;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class CppType {
	/** 0: forward declare, 1: value declare */
	public static var useMap:Map<String, Int> = new Map();
	public static var typedefs:Map<String, CppType> = new Map();
	public static var docNames:Map<String, String> = new Map();
	
	/** "char" for `const char*` */
	public var name:String;
	
	/** `const int` vs `int` */
	public var isConst:Bool = false;
	
	/** 0 -> int, 1 -> int*, 2 -> int**, etc. */
	public var ptrCount:Int = 0;
	
	/** `int&` vs `int` */
	public var isRef:Bool = false;
	
	/** `[CppType("int")]` for `vector<int>` */
	public var params:Array<CppType> = [];
	
	/** "vector" for `vector<int>` */
	public var docKey:String;
	
	/** "vector<int>" for `vector<int>` */
	public var docKeyFull:String;
	
	public function new(name:String) {
		this.name = name;
		docKey = name;
		docKeyFull = name;
	}
	public function markUsed(level:Int) {
		if (level > 0) {
			useMap[name] = 1;
			for (t in params) t.markUsed(level);
		} else {
			if (!useMap.exists(name)) useMap[name] = 0;
			for (t in params) {
				if (!useMap.exists(t.name)) useMap[t.name] = 0;
			}
		}
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
	
	// conveniences:
	public function getSize():Int {
		return proc.getSize(this);
	}
	public function gmlRead(gml, depth) {
		return proc.gmlRead(gml, this, depth);
	}
	public function gmlReadOut(gml, depth, out) {
		return proc.gmlReadOut(gml, this, depth, out);
	}
	public function gmlWrite(gml, depth, val) {
		proc.gmlWrite(gml, this, depth, val);
	}
	public function cppRead(cpp, prefix) {
		return proc.cppRead(cpp, this, prefix);
	}
	public function cppWrite(cpp, prefix, val) {
		proc.cppWrite(cpp, this, prefix, val);
	}
	public function cppDynSize(cpp, prefix, val, result) {
		return proc.cppDynSize(cpp, this, prefix, val, result);
	}
	public function hasDynSize() {
		return proc.hasDynSize(this);
	}
	public function seekRec(fn:(CppType) -> Bool) {
		return proc.seekRec(this, fn);
	}
	
	//{ unpack
	
	/** If this is a vector<T>, returns T */
	public function unpackVector():CppType {
		return switch (name) {
			case "vector", "tiny_array", "tiny_const_array", "gml_inout_vector": params[0];
			default: null;
		}
	}
	
	public function unpackOptional():CppType {
		return switch (name) {
			case "optional", "tiny_optional": params[0];
			default: null;
		}
	}
	
	/** If this is a vector<T>, returns T */
	public function unpackGmlVector():CppType {
		return name == "gml_vector" && params.length == 1 ? params[0] : null;
	}
	
	//}
	
	public static function read(q:tools.CppReader, ?name:String, markUsed:Bool = true):CppType {
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
				case "signed":
					name = q.readSpIdent();
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
		var cppType:CppType = typedefs[name];
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
		} else {
			cppType.docKeyFull = cppType.docKey = name;
		}
		if (isConst) prepare().isConst = isConst;
		//
		q.skipSpaces();
		if (q.peek() == "<".code) {
			prepare();
			q.skip();
			var full = cppType.docKey + "<";
			var sep = false;
			while (q.loop) {
				var paramType = read(q, null, false);
				if (sep) full += ","; else sep = true;
				full += paramType.docKeyFull;
				cppType.params.push(paramType);
				q.skipSpaces();
				switch (q.read()) {
					case ",".code:
						q.skipSpaces();
					case ">".code: break;
				}
			}
			if (CppTypeHelper.isSugar(cppType)) {
				cppType.docKeyFull = cppType.docKey = cppType.params[0].docKey;
			} else {
				cppType.docKeyFull = full + ">";
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
		//
		if (markUsed) {
			var useLevel = 1;
			if (cppType.ptrCount > 0) {
				useLevel = 0;
			} else switch (cppType.name) {
				case "gml_ptr", "gml_ptr_destroy": useLevel = 0;
				default:
			}
			cppType.markUsed(useLevel);
		}
		//
		return cppType;
	}
	
	/** Outside of YYRI, you can only have pointers and 64-bit floats **/
	public function toGmlCppType(isReturn:Bool):String {
		if (isReturn) {
			if (ptrCount == 1 && name == "char") {
				return isConst ? "const char*" : "char*";
			}
		} else {
			if (ptrCount > 0) {
				return toCppType();
			}
			var tp = proc;
			if (tp is CppTypeProcGmlPointer) {
				var tpp:CppTypeProcGmlPointer = cast tp;
				if (!tpp.isID) return params[0].toCppType() + "*";
			}
		}
		/*if (ptrCount == 1) {
			switch (name) {
				case "char" if (isConst): return "const char*";
				case "byte", "uint8_t": return (isConst ? "const " : "") + '$name*';
			}
		}*/
		return switch (name) {
			case "void", "bool",
				"char", "int8_t", "uint8_t", "byte",
				"short", "int16_t", "uint16_t",
				"int", "int32_t", "uint32_t", "long",
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
	
	public function toCppType_mutable() {
		var t = toCppType();
		if (t.startsWith("const ")) return t.substring("const ".length);
		return t;
	}
	
	private var __toCppMacroType_cache:String;
	public function toCppMacroType(nested:Bool = false) {
		if (__toCppMacroType_cache != null) return __toCppMacroType_cache;
		var s = new StringBuf();
		
		if (isConst) s.add("const_");
		s.add(name.replace(" ", "_"));
		if (isRef) s.add("_ref");
		for (_ in 0 ... ptrCount) s.add("_ptr");
		
		if (params.length > 0) {
			if (nested) s.add("_sof_"); else s.add("_of_");
			for (i => pt in params) {
				if (i > 0) s.add("__");
				s.add(pt.toCppMacroType(true));
			}
			// 1<2<3,4>,5<6>> -> 1_of_2_sof_3__4_eof__5_sof_6_eof
			if (nested) s.add("_eof");
		}
		
		__toCppMacroType_cache = s.toString();
		return __toCppMacroType_cache;
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
		return 'CppType(cpp: "${toCppType()}", name: "${name}", ptrCount: ${ptrCount}, params: [${params.join(", ")}] }';
	}
}