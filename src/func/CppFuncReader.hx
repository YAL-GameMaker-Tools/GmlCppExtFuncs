package func;
import tools.CppReader;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class CppFuncReader {
	public static function read(q:tools.CppReader):CppFunc {
		var fnStart = q.pos;
		//
		var retType = CppType.read(q);
		var fnName = q.readSpIdent();
		q.skipSpaces();
		if (!q.skipIfEqu("(".code)) return null;
		//
		var fn = new CppFunc(fnName);
		fn.retType = retType;
		CppFunc.list.push(fn);
		//
		var readArg = true;
		var depth = 1;
		var args = [];
		while (q.loop) {
			var c = q.read();
			switch (c) {
				case "(".code: depth++;
				case ")".code: if (--depth <= 0) break;
				case ",".code if (depth == 1):
					readArg = true;
				case _ if (c.isIdent0()):
					var w = q.readIdent(true);
					if (readArg) {
						readArg = false;
						var argType = CppType.read(q, w);
						var argName = q.readSpIdent();
						if (argName == "") continue;
						var arg = new func.CppFuncArg(fn.args.length, argType, argName);
						fn.args.push(arg);
						q.skipSpaces();
						if (q.skipIfEqu("=".code)) {
							q.skipSpaces();
							var valStart = q.pos;
							var comma = false;
							while (q.loop) {
								c = q.read();
								switch (c) {
									case "(".code: depth++;
									case ")".code: if (--depth <= 1) break;
									case ",".code:
										if (depth <= 1) {
											comma = true;
											break;
										}
								}
							}
							arg.value = q.substring(valStart, q.pos - 1).ltrim();
							if (comma) q.back();
							if (depth <= 0) break;
						}
					}
			}
		}
		//
		var lineStart = q.str.lastIndexOf("\n", fnStart);	
		if (lineStart >= 0) {
			var prevLineStart = q.str.lastIndexOf("\n", lineStart - 1);
			if (prevLineStart < 0) prevLineStart = 0;
			var prevLine = q.str.substring(prevLineStart, lineStart);
			var prevLineCmtStart = prevLine.lastIndexOf("///");
			if (prevLineCmtStart >= 0) {
				fn.metaComment = prevLine.substring(prevLineCmtStart + 3).trim();
			}
		}
		//
		return fn;
	}
}