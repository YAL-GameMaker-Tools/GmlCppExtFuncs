package ;
import haxe.Rest;

/**
 * ...
 * @author YellowAfterlife
 */
class CppBuf extends StringBuf {
	public var indent = 0;
	public function addLine(d:Int = 0) {
		indent += d;
		addChar("\n".code);
		for (_ in 0 ... indent) addChar("\t".code);
	}
	
	public inline function addString(s:String) add(s);
	public inline function addInt(i:Int) add(i);
	public inline function addBuffer(b:StringBuf) add(b.toString());
	
	static var addFormat_map:Map<String, CppBufFormatMeta> = (function() {
		inline function simple(fn:CppBufFormatFunc) {
			return new CppBufFormatMeta(fn, true);
		}
		inline function arg(fn:CppBufFormatFunc) {
			return new CppBufFormatMeta(fn, false);
		}
		return [
			"%s" => arg(function(b:CppBuf, val:Any, i:Int) b.addString(val)),
			"%b" => arg(function(b:CppBuf, val:Any, i:Int) b.addBuffer(val)),
			"%d" => arg(function(b:CppBuf, val:Any, i:Int) b.addInt(val)),
			"%|" => simple(function(b:CppBuf, val:Any, i:Int) b.addLine(0)),
			"%+" => simple(function(b:CppBuf, val:Any, i:Int) b.addLine(1)),
			"%-" => simple(function(b:CppBuf, val:Any, i:Int) b.addLine( -1)),
			"%{" => simple(function(b:CppBuf, val:Any, i:Int) {
				b.add("{");
				b.indent++;
			}),
		];
	})();
	
	static var addFormat_cache:Map<String, Array<CppBufFormatPart>> = new Map();
	static function addFormat_pre(fmt:String):Array<CppBufFormatPart> {
		var parts = addFormat_cache[fmt];
		if (parts != null) return parts;
		parts = [];
		var start = 0;
		var q = new CppReader(fmt, "");
		inline function flush(till:Int) {
			if (till > start) parts.push(FString(fmt.substring(start, till)));
		}
		while (q.loop) {
			if (q.read() != "%".code) continue;
			var at = q.pos - 1;
			flush(at);
			var tag;
			var c = q.peek();
			if (c.isIdent0()) {
				tag = q.readIdent(true);
			}
			else if (c == "(".code) {
				q.skipUntil(")".code);
				tag = "%" + q.substring(at + 2, q.pos - 1);
			}
			else {
				tag = q.substr(at, 2);
				q.pos += 1;
			}
			var meta = addFormat_map[tag];
			if (meta == null) throw 'Unknown format $tag in $fmt';
			parts.push(meta.simple ? FSimple(meta.func) : FNext(meta.func));
			start = q.pos;
		}
		flush(q.pos);
		addFormat_cache[fmt] = parts;
		return parts;
	}
	public function addFormat(fmt:String, rest:Rest<Any>) {
		var parts = addFormat_pre(fmt);
		var argi = 0;
		var argc = rest.length;
		for (part in parts) {
			switch (part) {
				case FString(s):
					addString(s);
				case FSimple(f):
					f(this, null, -1);
				case FNext(f):
					if (argi >= argc) throw "Not enough rest-arguments for %arg";
					f(this, rest[argi], argi);
					argi++;
			}
		}
		if (argi < argc) throw "Too many %args";
	}
	public static function fmt(fmt:String, rest:Rest<Any>) {
		var parts = addFormat_pre(fmt);
		var argi = 0;
		var argc = rest.length;
		var b = new CppBuf();
		for (part in parts) {
			switch (part) {
				case FString(s):
					b.addString(s);
				case FSimple(f):
					f(b, null, -1);
				case FNext(f):
					if (argi >= argc) throw "Not enough rest-arguments for %arg";
					f(b, rest[argi], argi);
					argi++;
			}
		}
		if (argi < argc) throw "Too many %args";
		return b.toString();
	}
}
typedef CppBufFormatFunc = (b:CppBuf, val:Any, i:Int)->Void;
enum CppBufFormatPart {
	FString(s:String);
	FSimple(fn:CppBufFormatFunc);
	FNext(fn:CppBufFormatFunc);
}
class CppBufFormatMeta {
	public var func:CppBufFormatFunc;
	public var simple:Bool;
	public function new(fn:CppBufFormatFunc, simple:Bool) {
		this.func = fn;
		this.simple = simple;
	}
}