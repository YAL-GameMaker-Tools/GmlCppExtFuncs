package ;
import haxe.io.Path;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

/**
 * ...
 * @author YellowAfterlife
 */
class CppGen {
	public static var config:CppConfig = new CppConfig();
	
	public static var outCppPath:String = null;
	public static var outGmlPath:String = null;
	
	public static function procFile(path:String, cpp:String) {
		var kwMacro = config.functionTag;
		var q = new CppReader(cpp, Path.withoutDirectory(path));
		while (q.loop) {
			var c = q.read();
			switch (c) {
				case '"'.code, "'".code: q.skipCString(c);
				case "/".code: {
					switch (q.peek()) {
						case "/".code: q.skipUntil("\n".code);
						case "*".code: q.skipUntilStr("*/");
					}
				}
				case _ if (c.isIdent0()): {
					var w = q.readIdent(true);
					if (w == "struct") {
						CppStruct.read(q);
					} else if (w == kwMacro) {
						CppFunc.read(q);
					}
				}
			}
		} // can continue
	}
	
	public static function finish() {
		var gml = new CppBuf();
		var cpp = new CppBuf();
		for (line in config.prepend) cpp.addFormat("%s%|", line);
		for (inc in config.includes) {
			cpp.addFormat('#include "%s"%|', inc);
		}
		if (CppStruct.list.length > 0) {
			var prefix = false;
			for (struct in CppStruct.list) {
				if (!CppType.useMap.exists(struct.name)) continue;
				if (!prefix) {
					prefix = true;
					cpp.addFormat("// Struct forward declarations:%|");
				}
				cpp.addFormat("// from %s:%|", struct.origin);
				cpp.addFormat("%s;%|", struct.impl);
			}
		}
		for (fn in CppFunc.list) {
			#if !sys
			trace(fn);
			#end
			fn.print(gml, cpp);
		}
		for (line in config.append) cpp.addFormat("%|%s", line);
		#if sys
		File.saveContent(outGmlPath, gml.toString());
		File.saveContent(outCppPath, cpp.toString());
		#else
		trace(gml.toString());
		trace(cpp.toString());
		#end
	}
	
	static function test(cpp:String) {
		procFile("test.cpp", cpp);
		finish();
	}
	static function main() {
		#if sys
		var args = Sys.args();
		var i = 0;
		//Sys.println("cwd: " + Sys.getCwd());
		while (i < args.length) {
			var remove = switch (args[i]) {
				case "--prefix": config.helperPrefix = args[i + 1]; 2;
				case "--function-tag": config.functionTag = args[i + 1]; 2;
				case "--prepend": config.prepend.push(args[i + 1]); 2;
				case "--append": config.append.push(args[i + 1]); 2;
				case "--include": config.includes.push(args[i + 1]); 2;
				case "--struct": config.structMode = args[i + 1]; 2;
				case "--gml": outGmlPath = args[i + 1]; 2;
				case "--cpp": outCppPath = args[i + 1]; 2;
				default: 0;
			}
			if (remove > 0) {
				args.splice(i, remove);
			} else i += 1;
		}
		for (full in args) {
			var rel = Path.withoutDirectory(full);
			if (rel.indexOf("*") >= 0) {
				var rs = new EReg("([.*+?^${}()|[\\]\\/\\\\])", "g").replace(rel, "\\$1");
				rs = StringTools.replace(rs, "\\*", ".+?");
				var rx = try {
					new EReg("^" + rs + "$", "");
				} catch (x:Dynamic) {
					Sys.println("Couldn't make a regex for " + rel);
					continue;
				}
				var dir = Path.normalize(Path.directory(full));
				var normCpp = Path.normalize(outCppPath);
				for (relx in FileSystem.readDirectory(dir)) {
					if (rx.match(relx)) {
						var fullx = dir + "/" + relx;
						if (fullx == normCpp) continue;
						procFile(fullx, File.getContent(fullx));
					}
				}
			} else procFile(full, File.getContent(full));
		}
		finish();
		#else
		var h = new haxe.Http("test.cpp?v=" + Date.now().getTime());
		h.onData = function(s) test(s);
		h.request();
		#end
	}
}