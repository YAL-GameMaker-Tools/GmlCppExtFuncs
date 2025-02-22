package func;

import proc.CppTypeProc;
import tools.CppBuf;
using StringTools;

class CppFuncGmlDoc {
	public static function print(fn:CppFunc, gml:CppBuf, hasReturn:Bool, retTypeProc:CppTypeProc, jsDoc:Bool) {
		var metaComment = fn.metaComment;
		if (metaComment != null && metaComment.startsWith("(")) {
			// function is preceded by `/// (...args)->`
			gml.addFormat("%|/// %s%s%|", fn.name, fn.metaComment);
			return;
		}
		if (!jsDoc) gml.addFormat("%|/// %s(", fn.name);
		var sep = false;
		for (arg in fn.args) {
			if (!arg.type.proc.useGmlArgument()) continue;
			if (jsDoc && !fn.gmlStatic && !sep) {
				// first arg is self
				sep = true;
				continue;
			}
			CppFuncArg.current = arg;
			if (!jsDoc) {
				if (sep) gml.add(", "); else sep = true;
			}
			//
			var argValue = arg.value;
			var isOpt = argValue == "{}";
			//
			if (jsDoc) {
				gml.addFormat("/// @param");
				if (arg.type != null) {
					var docType = arg.type.proc.getGmlDocTypeEx(arg.type);
					gml.addFormat(" {%s}", docType);
				}
				gml.addFormat(" %s%s", argValue != null ? "?" : "", arg.name);
				gml.addLine();
			} else {
				if (isOpt) {
					gml.addString("?");
					argValue = null;
				}
				gml.addFormat("%s", arg.name);
				if (arg.type != null) {
					var docType = arg.type.proc.getGmlDocTypeEx(arg.type);
					if (docType != null) gml.addFormat(":%s", docType);
				}
				if (argValue != null) gml.addFormat(" = %s", argValue);
			}
		}
		if (jsDoc) {
			if (hasReturn && retTypeProc != null) {
				var docType = retTypeProc.getGmlDocTypeEx(fn.retType);
				if (docType != null) gml.addFormat("/// @returns {%s}%|", docType);
			}
		} else {
			gml.add(")");
			if (metaComment != null && metaComment.startsWith("->")) {
				gml.addFormat("%s%|", metaComment);
				return;
			}
			if (hasReturn && retTypeProc != null) {
				gml.add("->");
				var docType = retTypeProc.getGmlDocTypeEx(fn.retType);
				if (docType != null) gml.addString(docType);
			}
			if (metaComment != null) gml.addFormat(" %s", metaComment);
			gml.addLine();
		}
	}
}