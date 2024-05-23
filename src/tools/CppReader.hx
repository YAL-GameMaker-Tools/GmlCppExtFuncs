package tools ;
import tools.CharCode;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class CppReader {
	public var name:String;
	public var str:String;
	public var pos:Int = 0;
	public var len:Int;
	public function new(s:String, name:String) {
		this.name = name;
		str = s;
		len = s.length;
	}
	
	public var loop(get, never):Bool;
	private inline function get_loop():Bool {
		return pos < len;
	}
	
	public function read():tools.CharCode {
		return str.unsafeCodeAt(pos++);
	}
	
	public inline function peek():tools.CharCode {
		return str.unsafeCodeAt(pos);
	}
	public inline function peekAt(ofs:Int):tools.CharCode {
		return str.unsafeCodeAt(pos + ofs);
	}
	
	public function peekn(n:Int):String {
		return str.substr(pos, n);
	}
	public function peeknAt(ofs:Int, n:Int):String {
		return str.substr(pos + ofs, n);
	}
	
	public function substr(pos:Int, len:Int):String {
		return str.substr(pos, len);
	}
	
	public function substring(start:Int, end:Int):String {
		return str.substring(start, end);
	}
	
	public inline function skip(n:Int = 1):Void {
		pos += n;
	}
	public inline function back(n:Int = 1):Void {
		pos -= n;
	}
	
	public function skipIfEqu(c:tools.CharCode):Bool {
		if (peek() == c) {
			skip(1);
			return true;
		} else return false;
	}
	
	public function readIdent(?pastFirst:Bool):String {
		var start = pastFirst ? pos - 1 : pos;
		while (loop) {
			var c = peek();
			if (c.isIdent1()) pos++; else break;
		}
		return substring(start, pos);
	}
	
	public function readSpIdent():String {
		inline this.skipSpaces();
		return inline this.readIdent();
	}
	
	public function readLspIdent():String {
		inline this.skipLineSpaces();
		return inline this.readIdent();
	}
	
	public function readLine():String {
		var start = pos;
		while (loop) {
			var c = peek();
			if (c == "\n".code) {
				return substring(start, pos++);
			} else skip();
		}
		return substring(start, pos);
	}
	
	public function readLineNonSpace():String {
		var start = pos;
		while (loop) {
			var c = peek();
			if (c == "\n".code) break;
			if (!c.isLineSpace()) skip(); else break;
		}
		return substring(start, pos);
	}
	
	public function skipUntil(c:tools.CharCode) {
		while (loop) {
			if (read() == c) break;
		}
	}
	
	public function skipSpaces() {
		while (loop) {
			var c = peek();
			if (c.isSpace()) skip(); else break;
		}
	}
	
	public function skipLineSpaces() {
		while (loop) {
			var c = peek();
			if (c.isLineSpace()) skip(); else break;
		}
	}
	
	public function skipUntilStr(s:String) {
		var n = s.length;
		while (loop) {
			if (substr(pos, n) == s) {
				pos += n;
				break;
			} else pos++;
		}
	}
	
	public function skipCString(c1:tools.CharCode) {
		while (loop) {
			var c = read();
			if (c == c1) break;
			if (c == "\\".code) {
				pos++;
			}
		}
	}
	
	public function getRow(pos:Int):Int {
		var row = 0;
		while (pos > 0) {
			row += 1;
			pos = str.lastIndexOf("\n", pos - 1);
		}
		return row;
	}
}