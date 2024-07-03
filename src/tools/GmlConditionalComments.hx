package tools;
using StringTools;

/**
 * ...
 * @author 
 */
class GmlConditionalComments {
	static function rxCondInit() {
		var rsOp = "\\s*(==|!=|\\>=|\\>|\\<=|\\<)";
		var rsVer = "\\s*(\\d+(?:\\.[\\d*])?)"; // 2, 2.3
		var rs = ("^"
			+ "/([/*])(" // -> "//" or "/*" prefix, -> line without prefix
			+ "(?:\\s*\\()?" // opt. (
			+ "\\s*GMS"
			+ rsOp // -> operator
			+ rsVer // -> version
			+ "(?:"
				+ "\\s*(\\&\\&|\\|\\|)" // -> and/or
				+ "\\s*GMS"
				+ rsOp // -> operator2
				+ rsVer // -> version2
			+ ")?"
			+ "(?:\\s*\\))?" // opt. )
			+ ":)" // trailing `:` (required!)
		);
		return new EReg(rs, "g");
	}
	static var rxCond:EReg = rxCondInit();
	static function parseCondition(snip:String, version:Float):Null<Bool> {
		//trace(snip);
		if (!rxCond.match(snip)) return null;
		
		var gi = 0;
		inline function next() return rxCond.matched(++gi);
		
		var ckind = next();
		var line = next();
		//
		var op1 = next();
		var ver1 = Std.parseFloat(next());
		if (Math.isNaN(ver1)) return null;
		//
		var boolOp = next();
		var op2 = next();
		var verStr2 = next();
		//
		function check(v:Float, op:String):Null<Bool> {
			return switch (op) {
				case "==": version == v;
				case "!=": version != v;
				case ">=": version >= v;
				case "<=": version <= v;
				case ">": version > v;
				case "<": version < v;
				default: null;
			};
		}
		
		if (boolOp != null) {
			var ver2 = verStr2 != null ? Std.parseFloat(verStr2) : null;
			if (Math.isNaN(ver2)) return null;
			var a1 = check(ver1, op1);
			var a2 = check(ver2, op2);
			if (a1 == null || a2 == null) return null;
			return switch (boolOp) {
				case "&&": a1 && a2;
				case "||": a1 || a2;
				default: null;
			}
		} else {
			return check(ver1, op1);
		}
	}
	public static function proc(gml:String, gmlVersion:Float, stripInactive:Bool) {
		//trace(gml);
		var q = new CcReader(gml);
		var start = 0;
		var out = new StringBuf();
		//
		inline function flush(till:Int) {
			if (start < till) out.add(gml.substring(start, till));
		}
		inline function add(s:String) {
			out.add(s);
		}
		//
		while (q.loop) {
			var cur = q.pos;
			var c = q.read();
			
			if (c != '/'.code) continue;
			var c1 = q.peek();
			var on:Null<Bool>;
			var single = c1 == '/'.code;
			var line:String;
			var closed = false;
			if (single) {
				while (q.loop) {
					c = q.peek();
					if (c == '\r'.code || c == '\n'.code) break;
					q.pos += 1;
				}
				line = q.substring(cur, q.pos);
			} else if (c1 == '*'.code) {
				q.pos += 1;
				while (q.loop) {
					c = q.peek();
					if (c == '*'.code || q.peekAt(1) == '/'.code) {
						closed = true;
						q.pos += 2;
						break;
					}
					if (c == '\r'.code || c == '\n'.code) {
						break;
					}
					q.pos += 1;
				}
				// single-line block comment, probably not what we want
				if (closed) continue;
				
				line = q.substring(cur, q.pos);
			} else continue;
			
			on = parseCondition(line, gmlVersion);
			if (on == null) continue; // not a condition
			
			if (on == single && !stripInactive) continue; // no change necessary
			
			flush(cur);
			if (!stripInactive) {
				add(on ? "//" : "/*");
				add(line.substring(2));
				start = q.pos;
				continue;
			}
			
			// then-block:
			q.skipSpaces();
			var start1 = q.pos;
			var end1 = q.skipCommentBlock();
			if (end1 == -1) continue;
			
			var hasElse = false;
			if (q.get(end1 - 1) == "/".code) {
				if (q.get(end1 - 2) == "/".code) {
					// `//*/`
					end1 -= 2;
				} else hasElse = true;
			} else {
				var p = end1 - 1;
				while (CcReader.isSpace(q.get(p - 1))) p -= 1;
				if (q.get(p - 1) == "/".code && q.get(p - 2) == "/".code) {
					// `//   */`
					p -= 2;
					end1 = p;
				}
			}
			
			//trace("line:" + line);
			//trace("then:<<<" + q.substring(start1, end1) + ">>>");
			if (on) {
				add(q.substring(start1, end1).trim());
			}
			
			if (!hasElse) {
				if (!on) q.skipSpaces();
				start = q.pos;
				//trace("no else");
				continue;
			}
			
			// else-block:
			q.skipSpaces();
			var start2 = q.pos;
			var end2 = q.skipCommentBlock();
			if (end2 == -1) continue;
			
			var p = end2 - 1;
			while (CcReader.isSpace(q.get(p - 1))) p -= 1;
			if (q.get(p - 1) == "/".code && q.get(p - 2) == "/".code) {
				// `//   */`
				p -= 2;
				end2 = p;
			}
			//trace("else:<<<" + q.substring(start2, end2) + ">>>");
			if (!on) {
				add(q.substring(start2, end2).trim());
			} else {
				q.skipSpaces();
			}
			start = q.pos;
		}
		if (start == 0) return gml;
		flush(q.pos);
		return out.toString();
	}
}
class CcReader {
	public var str:String;
	public var pos:Int = 0;
	public var len:Int;
	
	public var loop(get, never):Bool;
	inline function get_loop() {
		return pos < len;
	}
	
	public function new(s:String) {
		str = s;
		len = s.length;
	}
	
	public inline function get(p:Int) return str.unsafeCodeAt(p);
	public inline function peek() return str.unsafeCodeAt(pos);
	public inline function peekAt(n:Int) return str.unsafeCodeAt(pos + n);
	public function peekn(n:Int) {
		return str.substr(pos, n);
	}
	public inline function read() return str.unsafeCodeAt(pos++);
	public inline function skip(n:Int = 1) pos += n;
	public inline function substring(start:Int, end:Int) {
		return str.substring(start, end);
	}
	
	public static function isSpace(c:Int) {
		switch (c) {
			case " ".code, "\t".code, "\r".code, "\n".code:
				return true;
			default: return false;
		}
	}
	
	public function skipSpaces() {
		while (loop) {
			if (isSpace(peek())) pos += 1; else break;
		}
	}
	public function skipEscString() {
		while (loop) {
			var c = read();
			if (c == '"'.code) return;
			if (c == "\\".code) skip();
		}
	}
	public function skipCommentBlock() {
		while (loop) {
			var c = read();
			if (c == "*".code && loop && peek() == "/".code) {
				skip();
				return pos - 1;
			}
		}
		return -1;
	}
}