package ;
import func.CppFunc;
import haxe.io.Path;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import struct.CppStruct;
import tools.CppReader;
import tools.CppBuf;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class CppGen {
	public static var config:CppConfig = new CppConfig();
	
	public static var outCppPath:String = null;
	public static var outGmlPath:String = null;
	
	public static function procFile(path:String, cpp:String, indexStructs:Bool) {
		var kwMacro = config.functionTag;
		var kwMacroLen = kwMacro.length;
		cpp = StringTools.replace(cpp, "\r", "");
		var q = new CppReader(cpp, Path.withoutDirectory(path));
		var fnCond = "";
		while (q.loop) {
			var c = q.read();
			switch (c) {
				case '"'.code, "'".code: q.skipCString(c);
				case "/".code: {
					switch (q.peek()) {
						case "/".code:
							q.skip(2);
							q.skipLineSpaces();
							if (q.peek() == "@".code
								&& q.peeknAt(1, kwMacroLen) == kwMacro
								&& q.peekAt(kwMacroLen + 1) == ":".code
							) {
								q.skip(2 + kwMacroLen);
								var meta = q.readIdent();
								switch (meta) {
									case "docName":
										q.skipLineSpaces();
										var cppName = q.readLineNonSpace();
										q.skipLineSpaces();
										var docName = q.readLineNonSpace();
										CppType.docNames[cppName] = docName;
									case "cond":
										q.skipLineSpaces();
										fnCond = q.readLine().trim();
								}
							} else q.skipUntil("\n".code);
						case "*".code: q.skipUntilStr("*/");
					}
				}
				case "#".code: {
					q.skipUntil("\n".code);
					while (q.loop && q.peekAt( -2) == "\\".code) q.skipUntil("\n".code);
				};
				case _ if (c.isIdent0()): {
					var w = q.readIdent(true);
					if (w == "using") {
						q.skipSpaces();
						var name = q.readIdent();
						q.skipSpaces();
						if (q.skipIfEqu("=".code)) {
							q.skipSpaces();
							var type = CppType.read(q);
							//trace(path, q.getRow(q.pos), name, type);
							CppType.typedefs[name] = type;
						}
					} else if (w == "typedef") {
						var type = CppType.read(q);
						q.skipSpaces();
						var name = q.readIdent();
						if (name != "") {
							//trace(path, q.getRow(q.pos), name, type);
							CppType.typedefs[name] = type;
						}
					} else if (indexStructs && w == "struct") {
						struct.CppStruct.read(q);
					} else if (w == kwMacro) {
						var fn = func.CppFuncReader.read(q);
						if (fn != null) fn.condition = fnCond;
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
		if (struct.CppStruct.list.length > 0) {
			var prefix = false;
			for (struct in struct.CppStruct.list) {
				if (!CppType.useMap.exists(struct.name)) continue;
				if (!prefix) {
					prefix = true;
					cpp.addFormat("// Struct forward declarations:%|");
				}
				cpp.addFormat("// from %s:%|", struct.origin);
				cpp.addFormat("%s;%|", struct.impl);
			}
		}
		
		var fnCond = "";
		for (fn in func.CppFunc.list) {
			#if !sys
			trace(fn);
			#end
			if (fnCond != fn.condition) {
				if (fnCond != "") cpp.addFormat("#endif // %s%|%|", fnCond);
				fnCond = fn.condition;
				if (fnCond != "") cpp.addFormat("#if %s%|%|", fnCond);
			}
			fn.print(gml, cpp);
		}
		if (fnCond != "") cpp.addFormat("#endif // %s%|", fnCond);
		
		for (line in config.append) cpp.addFormat("%|%s", line);
		#if sys
		File.saveContent(outGmlPath, gml.toString());
		File.saveContent(outCppPath, cpp.toString());
		#else
		trace(gml.toString());
		trace(cpp.toString());
		#end
	}
	#if sys
	static function procArg(full:String, indexStructs:Bool) {
		var rel = Path.withoutDirectory(full);
		if (rel.indexOf("*") >= 0) {
			var rs = new EReg("([.*+?^${}()|[\\]\\/\\\\])", "g").replace(rel, "\\$1");
			rs = StringTools.replace(rs, "\\*", ".+?");
			var rx = try {
				new EReg("^" + rs + "$", "");
			} catch (x:Dynamic) {
				Sys.println("Couldn't make a regex for " + rel);
				return;
			}
			var dir = Path.normalize(Path.directory(full));
			var normCpp = Path.normalize(outCppPath);
			for (relx in FileSystem.readDirectory(dir)) {
				if (rx.match(relx)) {
					var fullx = dir + "/" + relx;
					if (fullx == normCpp) continue;
					procFile(fullx, File.getContent(fullx), indexStructs);
				}
			}
		} else procFile(full, File.getContent(full), indexStructs);
	}
	#end
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
				#if sys
				case "--index": procArg(args[i + 1], false); 2;
				#end
				default: 0;
			}
			if (remove > 0) {
				args.splice(i, remove);
			} else i += 1;
		}
		for (full in args) procArg(full, true);
		finish();
		#else
		var h = new haxe.Http("test.cpp?v=" + Date.now().getTime());
		h.onData = function(s) {
			procFile("test.cpp", cpp, true);
			finish();
		}
		h.request();
		#end
	}
}