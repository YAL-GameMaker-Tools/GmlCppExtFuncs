package tools;
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
	
	static var addFormat_map:Map<String, CppBufFormatPart> = (function() {
		inline function simple(fn:CppBufFormatFunc) {
			return new CppBufFormatMeta(fn, true);
		}
		inline function arg(fn:CppBufFormatFunc) {
			return new CppBufFormatMeta(fn, false);
		}
		inline function addVarDeclPre(b:CppBuf, name:Any) {
			b.addFormat("var %s", name);
			if (CppGen.hasGmkPath) {
				b.addFormat("; %s", name);
			}
		}
		function addVarDecl(b:CppBuf, name:Any, val:Any) {
			addVarDeclPre(b, name);
			b.addString(" = ");
			b.add(val);
		}
		return [
			"%s" => FOne((b, val) -> b.addString(val)),
			"%b" => FOne((b, val) -> b.addBuffer(val)),
			"%d" => FOne((b, val) -> b.addInt(val)),
			"%vdp" => FOne((b, name) -> {
				addVarDeclPre(b, name);
			}),
			"%vds" => FTwo(addVarDecl),
			"%vdb" => FTwo((b, name, val) -> {
				var old = CppGen.config.isGMK;
				if (old) b.add("{ ");
				addVarDecl(b, name, val);
				if (old) b.add(" }");
			}),
			"%bw" => FTwo((b, type, val) -> {
				var config = CppGen.config;
				if (config.isGMK) {
					var f = config.helperPrefix + "_gmkb_write_" + type;
					GmkGen.usedHelpers[f] = true;
					b.addFormat('external_call(global.f_%s, %s)', f, val);
				} else {
					b.addFormat('buffer_write(_buf, buffer_%s, %s)', type, val);
				}
			}),
			"%|" => FZero(b -> b.addLine(0)),
			"%+" => FZero(b -> b.addLine(1)),
			"%-" => FZero(b -> b.addLine( -1)),
			"%{" => FZero(b -> {
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
		var argCount = 0;
		
		var start = 0;
		var q = new tools.CppReader(fmt, "");
		inline function flush(till:Int) {
			if (till > start) parts.push(FString(fmt.substring(start, till)));
		}
		while (q.loop) {
			if (q.read() != "%".code) continue;
			var at = q.pos - 1;
			flush(at);
			var tag;
			var c = q.peek();
			if (c.isDigit()) {
				q.skip();
				parts.push(FOneAt(c - "0".code));
				start = q.pos;
				continue;
			}
			if (c.isIdent0()) { // %s, %tag
				tag = q.readIdent(true);
			}
			else if (c == "(".code) { // %(tag)
				q.skipUntil(")".code);
				tag = "%" + q.substring(at + 2, q.pos - 1);
			}
			else { // %|, %+, etc.
				tag = q.substr(at, 2);
				q.pos += 1;
			}
			var meta = addFormat_map[tag];
			if (meta == null) throw 'Unknown format $tag in $fmt';
			parts.push(meta);
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
				case FString(s): addString(s);
				case FZero(f): f(this);
				case FOne(f):
					if (argi >= argc) throw "Not enough rest-arguments for %arg";
					f(this, rest[argi++]);
				case FOneAt(i):
					if (i >= argc) throw 'Not enough rest-arguments for %$i';
					add(rest[i]);
				case FTwo(f):
					if (argi + 1 >= argc) throw "Not enough rest-arguments for %arg";
					var a = rest[argi++];
					var b = rest[argi++];
					f(this, a, b);
			}
		}
		if (argi < argc) throw "Too many %args";
	}
	public static function fmt(fmt:String, rest:Rest<Any>) {
		var parts = addFormat_pre(fmt);
		var argi = 0;
		var argc = rest.length;
		var buf = new CppBuf();
		for (part in parts) {
			switch (part) {
				case FString(s):
					buf.addString(s);
				case FZero(f): f(buf);
				case FOne(f):
					if (argi >= argc) throw "Not enough rest-arguments for %arg";
					f(buf, rest[argi++]);
				case FOneAt(i):
					if (i >= argc) throw 'Not enough rest-arguments for %$i';
					buf.add(rest[i]);
				case FTwo(f):
					if (argi + 1 >= argc) throw "Not enough rest-arguments for %arg";
					var a = rest[argi++];
					var c = rest[argi++];
					f(buf, a, c);
			}
		}
		if (argi < argc) throw "Too many %args";
		return buf.toString();
	}
}
typedef CppBufFormatFunc = (b:CppBuf, val:Any, i:Int)->Void;
enum CppBufFormatPart {
	FString(s:String);
	FZero(fn:CppBuf->Void);
	FOne(fn:CppBuf->Any->Void);
	FOneAt(i:Int);
	FTwo(fn:CppBuf->Any->Any->Void);
}
class CppBufFormatMeta {
	public var func:CppBufFormatFunc;
	public var simple:Bool;
	public function new(fn:CppBufFormatFunc, simple:Bool) {
		this.func = fn;
		this.simple = simple;
	}
}