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
		var gmlHeader = null;
		var gmlConstrutor = null;
		var gmlMethod = null;
		while (q.loop) {
			var c = q.read();
			switch (c) {
				case '"'.code, "'".code: q.skipCString(c);
				case "/".code: {
					var metaType = null;
					var metaText = null;
					var metaStart = 0;
					var metaAfter = 0;
					switch (q.peek()) {
						case "/".code: {
							q.skip();
							if (q.peek() == "/".code) q.skip();
							q.skipLineSpaces();
							if (q.peek() == "@".code
								&& q.peeknAt(1, kwMacroLen).toLowerCase() == kwMacroLQ
								&& q.peekAt(kwMacroLen + 1) == ":".code
							) { // `// @dllg meta:`
								q.skip(2 + kwMacroLen);
								metaType = q.readIdent();
								metaStart = q.pos;
								metaText = q.readLine();
								metaAfter = q.pos;
							} else q.skipUntil("\n".code);
						}; // `//`
						case "*".code: {
							q.skip();
							if (q.peek() == "*".code && q.peekAt(1) != "/".code) q.skip();
							q.skipSpaces();
							if (q.peek() == "@".code
								&& q.peeknAt(1, kwMacroLen).toLowerCase() == kwMacroLQ
								&& q.peekAt(kwMacroLen + 1) == ":".code
							) { // `/* @dllg:meta ... */
								q.skip(2 + kwMacroLen);
								metaType = q.readIdent();
								q.skipLineSpaces();
								metaStart = q.pos;
								var end = q.skipUntilStr("*/") ? q.pos - 2 : q.pos;
								metaAfter = q.pos;
								
								metaText = q.substring(metaStart, end);
								metaText = metaText.replace("\r", "");
								while (metaText.endsWith("*")) {
									metaText = metaText.substr(0, metaText.length - 1);
								}
								metaText = metaText.trim();
							} else q.skipUntilStr("*/");
						} // `/*`
					} // switch peek
					if (metaType != null) switch (metaType.toLowerCase()) {
						case "docname":
							q.pos = metaStart;
							q.skipLineSpaces();
							var cppName = q.readLineNonSpace();
							q.skipLineSpaces();
							var docName = q.readLineNonSpace();
							CppType.docNames[cppName] = docName;
							q.pos = metaAfter;
						case "cond": fnCond = metaText.trim();
						case "defvalue": defValue = metaText.trim();
						case "gmlheader": gmlHeader = metaText.trim();
						case "type": CppTypeProcCustom.parse(metaText);
						case "method": gmlMethod = metaText.trim();
						case "constructor": {
							gmlConstrutor = metaText.trim();
							if (gmlConstrutor == "") gmlConstrutor = null;
						}
						default:
							CppGen.warn("Unknown documentation tag "
								+ q.peeknAt(1, kwMacroLen) + ":" + metaType);
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
						CppStruct.read(q, isSourceFile);
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
							if (gmlHeader != null) {
								fn.gmlHeader = gmlHeader;
								gmlHeader = null;
							}
							if (gmlMethod != null) {
								var rx = ~/^(\w+)?([:.])(\w+)$/;
								if (!rx.match(gmlMethod)) {
									CppGen.warn('"$gmlMethod" does not follow the '
										+ 'Constructor:method / Constructor.staticMethod format');
								} else if (rx.matched(1) == null && gmlConstrutor == null) {
									CppGen.warn('"$gmlMethod" does specify a constructor');
								} else {
									var ctrName = rx.matched(1);
									if (ctrName == null) ctrName = gmlConstrutor;
									fn.gmlConstructor = ctrName;
									fn.gmlMethod = rx.matched(3);
									fn.gmlIsStatic = rx.matched(2) == ".";
								}
								gmlMethod = null;
							}
						}
					}
				}
			}
		} // can continue
	}
}