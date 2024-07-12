package func;
import tools.CppBuf;
using StringTools;

/**
 * ...
 * @author 
 */
class CppFuncMangled {
	public static var isUsed = false;
	public static function print(fn:CppFunc, cpp:CppBuf) {
		isUsed = true;
		var retCppType = fn.retType.toCppType();
		var retVoid = retCppType == "void";
		fn.printExtern(cpp, retCppType, false, null);
		var config = CppGen.config;
		
		var argDoc:CppBuf = new CppBuf();
		var argDecl:CppBuf = new CppBuf(); argDecl.indent = cpp.indent + 1;
		var argCall:CppBuf = new CppBuf();
		var argi = 0;
		var hasResult = false, hasRest = false;
		var minArgs = -1;
		var sep = false;
		for (arg in fn.args) {
			var t = arg.type;
			if (retVoid && t.name == "YYResult" && ((t.ptrCount == 1) /*xor*/!= (t.isRef))) {
				hasResult = true;
				if (argCall.length > 0) argCall.addString(", ");
				if (t.isRef) {
					argCall.addString("result");
				} else argCall.addString("&result");
				continue;
			}
			if (t.name == "YYSelf" || t.name == "YYOther") {
				var isSelf = t.name == "YYSelf";
				if (argCall.length > 0) argCall.addString(", ");
				argCall.addString(isSelf ? "self" : "other");
				continue;
			}
			
			var isOpt = arg.value != null;
			if (argDoc.length > 0) argDoc.addString(", ");
			if (t.name == "YYRest") {
				hasRest = true;
				argDoc.addString("...");
			} else if (isOpt) argDoc.addString("?");
			
			argDoc.addString(arg.name);
			var varName = "_arg_" + arg.name;
			argDecl.addFormat("%s %s;", t.toCppType(), varName);
			if (isOpt) {
				if (minArgs < 0) minArgs = argi;
				argDecl.addFormat("%|if (argc > %d) {%+", argi);
			} else argDecl.addString(" ");
			argDecl.addFormat('__YYArg_%s("%s", %s, %d);',
				t.toCppMacroType(), arg.name, varName, argi);
			if (isOpt) {
				argDecl.addFormat("%-} else %s = %s;", varName, arg.value);
			}
			argDecl.addLine();
			
			if (argCall.length > 0) argCall.addString(", ");
			argCall.addString(varName);
			
			if (hasRest) break;
			argi += 1;
		}
		
		cpp.addFormat("/// %s(%b)%s\n", fn.name, argDoc, retVoid && !hasResult ? "" : "->");
		var cppName = config.cppNameMangled.replace("$", fn.name);
		cpp.addFormat("%s ", config.exportPrefixM);
		cpp.addFormat("void %s", cppName);
		cpp.addString("(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg)");
		cpp.addFormat(" {%+");
		cpp.addFormat('#define __YYFUNCNAME__ "%s"%|', fn.name);
		var maxArgs = argi;
		if (minArgs < 0) minArgs = maxArgs;
		if (hasRest && minArgs == 0) {
			cpp.addFormat("__YYArgCheck_any;");
		} else if (hasRest) {
			cpp.addFormat("__YYArgCheck_rest(%d);", minArgs);
		} else if (minArgs != maxArgs) {
			cpp.addFormat("__YYArgCheck_range(%d, %d);", minArgs, maxArgs);
		} else {
			cpp.addFormat("__YYArgCheck(%d);", minArgs);
		}
		cpp.addLine();
		cpp.addBuffer(argDecl);
		if (!retVoid) {
			cpp.addFormat("%s _result = ", retCppType);
		}
		cpp.addFormat("%s(%b);%|", fn.name, argCall);
		if (!retVoid) {
			cpp.addFormat("__YYResult_%s(%s);%|", fn.retType.toCppMacroType(), "_result");
		}
		cpp.addFormat('#undef __YYFUNCNAME__');
		cpp.addFormat("%-}%|%|");
	}
}