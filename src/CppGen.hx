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
	public static var hasGmkPath(get, never):Bool;
	static function get_hasGmkPath(){
		return outGmkPath != null;
	}
	
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
			for (struct in CppStruct.list) if (struct.shouldForwardDeclare) {
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
	public static function procArg(full:String, indexStructs:Bool) {
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
		//Sys.println("cwd: " + Sys.getCwd());
		config.handleArgs(args);
		if (args.length == 0 || outGmlPath == null || outCppPath == null) {
			Sys.println("Check README for arguments!");
			Sys.stdin().readLine();
			return;
		}
		for (full in args) {
			procArg(full, true);
		}
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