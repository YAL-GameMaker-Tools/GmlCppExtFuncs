package ;
import proc.CppTypeProcEnum;
import proc.CppTypeProcCustom;
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
	public static function procFile(path:String, cpp:String, isSourceFile:Bool) {
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
							q.skip();
							if (q.peek() == "/".code) q.skip();
							q.skipLineSpaces();
							if (q.peek() == "@".code
								&& q.peeknAt(1, kwMacroLen).toLowerCase() == kwMacroLQ
								&& q.peekAt(kwMacroLen + 1) == ":".code
							) { // `// @dllg meta:`
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
										CppGen.warn("Unknown documentation tag "
											+ q.peeknAt(1, kwMacroLen) + ":" + meta);
								}
							} else q.skipUntil("\n".code);
						case "*".code: {
							q.skip();
							if (q.peek() == "*".code && q.peekAt(1) != "/".code) q.skip();
							q.skipSpaces();
							if (q.peek() == "@".code
								&& q.peeknAt(1, kwMacroLen).toLowerCase() == kwMacroLQ
								&& q.peekAt(kwMacroLen + 1) == ":".code
							) { // `/* @dllg:meta ... */
								q.skip(2 + kwMacroLen);
								var meta = q.readIdent();
								q.skipLineSpaces();
								var start = q.pos;
								var end = q.skipUntilStr("*/") ? q.pos - 2 : q.pos;
								
								var block = q.substring(start, end);
								block = block.replace("\r", "");
								while (block.endsWith("*")) {
									block = block.substr(0, block.length - 1);
								}
								block = block.trim();
								
								if (meta == "type") {
									CppTypeProcCustom.parse(block);
								} else {
									CppGen.warn("Unknown documentation tag "
										+ meta
									);
								}
							} else q.skipUntilStr("*/");
						}
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
						// todo: bad behaviour on `typedef unsigned long long X` and alike - skip to `;` and run a regex?
						var type = CppType.read(q);
						q.skipSpaces();
						var name = q.readIdent();
						if (name != "") {
							//trace(path, q.getRow(q.pos), name, type, type.name, type.ptrCount);
							CppType.typedefs[name] = type;
						}
					} else if (w == "struct") {
						struct.CppStruct.read(q, isSourceFile);
					} else if (w == "enum") {
						q.skipSpaces();
						var name = q.readIdent();
						if (name == "class") {
							q.skipSpaces();
							name = q.readIdent();
						}
						@:privateAccess CppTypeHelper.map[name] = new CppTypeProcEnum(name);
					}
					else if (w == kwMacro || w == kwMacroM) {
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