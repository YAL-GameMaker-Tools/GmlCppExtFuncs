package struct ;
import proc.CppTypeProcStruct;
import tools.CppReader;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class CppStruct {
	public static var list:Array<CppStruct> = [];
	public static var map:Map<String, CppStruct> = new Map();
	public var name:String;
	public var parent:String;
	/** "file.cpp:line" */
	public var origin:String;
	public var fields:Array<struct.CppStructField> = [];
	public var proc:CppTypeProcStruct;
	/** C++ implementation */
	public var impl:String;
	public function new(name:String) {
		this.name = name;
		proc = new CppTypeProcStruct(this);
	}
	
	public static function readStructField(q:tools.CppReader, struct:CppStruct, firstIdent:String) {
		var fdType = CppType.read(q, firstIdent);
		if (fdType == null) return;
		while (q.loop) {
			q.skipSpaces();
			var fdName = q.readIdent();
			if (fdName == "") break;
			q.skipSpaces();
			if (q.peek() == "(".code) break; // retType funcName()
			var fd = new struct.CppStructField(fdType, fdName);
			while (q.skipIfEqu("[".code)) {
				q.skipSpaces();
				var n = Std.parseInt(q.readIdent());
				q.skipSpaces();
				q.skipIfEqu("]".code);
				q.skipSpaces();
				if (n == null) break;
				fd.size.push(n);
			}
			//
			struct.fields.push(fd);
			q.skipSpaces();
			if (q.skipIfEqu("=".code)) {
				q.skipSpaces();
				var depth = 0;
				while (q.loop) {
					var c = q.read();
					switch (c) {
						case '"'.code, "'".code: q.skipCString(c);
						case "/".code: {
							switch (q.peek()) {
								case "/".code: q.skipUntil("\n".code);
								case "*".code: q.pos++; q.skipUntilStr("*/");
							}
						}
						case "{".code, "(".code: depth++;
						case "}".code, ")".code: depth--;
						case ",".code if (depth == 0): q.back(); break;
						case ";".code if (depth == 0): q.back(); break;
					}
				}
			}
			//
			q.skipSpaces();
			switch (q.peek()) {
				case ",".code: q.skip();
				case ";".code: q.skip(); break;
			}
		}
	}
	
	public static function read(q:tools.CppReader) {
		var structStart = q.pos - "struct".length;
		q.skipSpaces();
		var structName = q.readIdent();
		var struct = new CppStruct(structName);
		struct.origin = q.name + ":" + q.getRow(structStart);
		@:privateAccess CppTypeHelper.map[structName] = struct.proc;
		list.push(struct);
		map[structName] = struct;
		q.skipSpaces();
		if (q.skipIfEqu(":".code)) {
			q.skipSpaces();
			struct.parent = q.readIdent();
		}
		var depth = 0;
		while (q.loop) {
			var c = q.read();
			switch (c) {
				case '"'.code, "'".code: q.skipCString(c);
				case "/".code: {
					switch (q.peek()) {
						case "/".code: q.skipUntil("\n".code);
						case "*".code: q.pos++; q.skipUntilStr("*/");
					}
				}
				case "{".code, "(".code: depth++;
				case "}".code, ")".code: if (--depth <= 0) break;
				case _ if (c.isIdent0() && depth == 1): {
					var w = q.readIdent(true);
					switch (w) {
						case "public", "private": {};
						case _ if (w == structName): {};
						default:
							readStructField(q, struct, w);
					}
				}
				default:
			}
		} // can continue
		struct.impl = q.substring(structStart, q.pos);
		//trace(q.name, structName, structStart, q.len, q.substring(0, structStart) + "<<" + struct.impl + ">>" + q.substring(q.pos, q.len));
	}
}
