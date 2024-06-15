package ;
import tools.GmkGen;
import func.CppFunc;
import func.CppFuncMangled;
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
	public static var outGmkPath:String = null;
	
	public static inline function procFile(path:String, cpp:String, indexStructs:Bool) {
		CppGenParser.procFile(path, cpp, indexStructs);
	}
	
	public static function warn(text:String) {
		#if js
		js.Browser.console.warn(text);
		#else
		Sys.println(text);
		#end
	}
	
	static function writeIfNotSame(path:String, text:String) {
		#if sys
		if (!FileSystem.exists(path)) {
			File.saveContent(path, text);
		} else {
			var curr = try {
				File.getContent(path);
			} catch (x:Dynamic) null;
			if (curr != text) File.saveContent(path, text);
		}
		#else
		trace(path);
		trace(text);
		#end
	}
	
	public static function finish() {
		var gml = new CppBuf();
		var cpp = new CppBuf();
		
		for (line in config.prepend) {
			cpp.addFormat("%s%|", line);
		}
		for (fn in CppFunc.list) if (fn.isMangled) {
			config.includes.insert(1, "gml_extm.h");
			break;
		}
		for (inc in config.includes) {
			cpp.addFormat('#include "%s"%|', inc);
		}
		
		if (outGmkPath != null) {
			cpp.addFormat("gmk_buffer %s;%|", GmkGen.argBuffer);
		}
		
		if (CppStruct.list.length > 0) {
			var prefix = false;
			for (struct in CppStruct.list) {
				var byval = CppType.useMap[struct.name];
				if (byval == null) continue;
				if (!prefix) {
					prefix = true;
					cpp.addFormat("// Struct forward declarations:%|");
				}
				cpp.addFormat("// from %s:%|", struct.origin);
				if (byval > 0) {
					cpp.addFormat("%s;%|", struct.impl);
				} else cpp.addFormat("struct %s;%|", struct.name);
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
		
		var gmlCode = gml.toString();
		var cppCode = cpp.toString();
		if (outGmkPath != null) {
			cppCode = tools.GmkGen.run(gmlCode, cppCode);
		}
		writeIfNotSame(outGmlPath, gmlCode);
		writeIfNotSame(outCppPath, cppCode);
	}
	#if sys
	static function procArg(full:String, indexStructs:Bool) {
		var rel = Path.withoutDirectory(full);
		if (rel.indexOf("*") >= 0) {
			var rs = new EReg("([.*+?^${}()|[\\]\\/\\\\])", "g").replace(rel, "\\$1");
			rs = StringTools.replace(rs, "\\*", ".*?");
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
				case "--function-tagm": config.functionTagM = args[i + 1]; 2;
				case "--export-tag": config.exportPrefix = args[i + 1]; 2;
				case "--export-tagm": config.exportPrefixM = args[i + 1]; 2;
				case "--prepend": config.prepend.push(args[i + 1]); 2;
				case "--append": config.append.push(args[i + 1]); 2;
				case "--include": config.includes.push(args[i + 1]); 2;
				case "--struct": config.structMode = args[i + 1]; 2;
				case "--gml": outGmlPath = args[i + 1]; 2;
				case "--cpp": outCppPath = args[i + 1]; 2;
				case "--wasm": config.useWASM = true; 1;
				case "--gmk": outGmkPath = args[i + 1]; 2;
				#if sys
				case "--index": procArg(args[i + 1], false); 2;
				#end
				default: 0;
			}
			if (remove > 0) {
				args.splice(i, remove);
			} else i += 1;
		}
		if (args.length == 0 || outGmlPath == null || outCppPath == null) {
			Sys.println("Check README for arguments!");
			Sys.stdin().readLine();
			return;
		}
		for (full in args) procArg(full, true);
		finish();
		#else
		var h = new haxe.Http("test.cpp?v=" + Date.now().getTime());
		h.onData = function(cpp) {
			procFile("test.cpp", cpp, true);
			finish();
		}
		h.request();
		#end
	}
}