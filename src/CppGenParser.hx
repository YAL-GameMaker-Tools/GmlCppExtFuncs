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
class CppGenParser {
	public static function procFile(path:String, cpp:String, indexStructs:Bool) {
		var config = CppGen.config;
		var kwMacro = config.functionTag;
		var kwMacroM = config.functionTagM;
		var kwMacroLQ = kwMacro.toLowerCase();
		var kwMacroLen = kwMacro.length;
		cpp = StringTools.replace(cpp, "\r", "");
		var q = new CppReader(cpp, Path.withoutDirectory(path));
		var fnCond = "";
		var defValue = null;
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
								&& q.peeknAt(1, kwMacroLen).toLowerCase() == kwMacroLQ
								&& q.peekAt(kwMacroLen + 1) == ":".code
							) {
								q.skip(2 + kwMacroLen);
								var meta = q.readIdent();
								switch (meta.toLowerCase()) {
									case "docname":
										q.skipLineSpaces();
										var cppName = q.readLineNonSpace();
										q.skipLineSpaces();
										var docName = q.readLineNonSpace();
										CppType.docNames[cppName] = docName;
									case "cond":
										q.skipLineSpaces();
										fnCond = q.readLine().trim();
									case "defvalue":
										q.skipLineSpaces();
										defValue = q.readLine().trim();
									default:
										Sys.println("Unknown documentation tag "
											+ q.peeknAt(1, kwMacroLen) + ":" + meta);
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
					} else if (w == kwMacro || w == kwMacroM) {
						var fn = func.CppFuncReader.read(q);
						if (fn != null) {
							if (w == kwMacroM) fn.isMangled = true;
							fn.condition = fnCond;
							if (defValue != null) {
								fn.defValue = defValue;
								defValue = null;
							}
						}
					}
				}
			}
		} // can continue
	}
}