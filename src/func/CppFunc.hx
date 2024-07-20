package func ;
import proc.CppTypeProc;
using StringTools;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppFunc {
	public static var list:Array<CppFunc> = [];
	
	public var name:String;
	public var cppFuncName:String;
	public var generateFuncExtern:Bool = true;
	public var args:Array<CppFuncArg> = [];
	public var retType:CppType;
	/**
	 * GML code for default return value if the native extension failed to load.
	 * This forces functions with GML-friendly return types to internally return OK/fail
	 * since functions from unloaded binaries simply return 0 or "".
	 */
	public var defValue:String = null;
	public var metaComment:String = null;
	public var condition:String = "";
	public var isMangled:Bool = false;
	
	public function new(name:String) {
		this.name = name;
		cppFuncName = name;
	}
	
	function printGmlDoc(gml:CppBuf, hasReturn:Bool, retTypeProc:CppTypeProc) {
		if (metaComment != null && metaComment.startsWith("(")) {
			// `/// (...args)->`
			gml.addFormat("%|/// %s%s%|", name, metaComment);
			return;
		}
		gml.addFormat("%|/// %s(", name);
		var sep = false;
		for (i => arg in args) {
			if (!arg.type.proc.useGmlArgument()) continue;
			CppFuncArg.current = arg;
			if (sep) gml.add(", "); else sep = true;
			var argValue = arg.value;
			if (argValue == "{}") {
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
		gml.add(")");
		if (metaComment != null && metaComment.startsWith("->")) {
			gml.addFormat("%s%|", metaComment);
			return;
		}
		if (hasReturn && retTypeProc != null) {
			gml.add("->");
			var docType = retTypeProc.getGmlDocTypeEx(retType);
			if (docType != null) gml.addString(docType);
		}
		if (metaComment != null) gml.addFormat(" %s", metaComment);
		gml.addLine();
	}
	
	function gcTypeUsesBuffer(argGcType) {
		return argGcType == null || argGcType == "double";
	}
	
	function printGmlArgsWrite(gml:CppBuf, gmlCleanup:CppBuf, argGcTypes, hasOptArgs) {
		var argi = 0;
		for (i => arg in args) {
			var argGcType = argGcTypes[i];
			var tp = arg.type.proc;
			var argGmlRef = hasOptArgs ? 'argument[$argi]' : 'argument$argi';
			var keepGmlArgVar = tp.keepGmlArgVar(arg.type);
			
			if (arg.type.proc.useGmlArgument()) argi += 1;
			if (gcTypeUsesBuffer(argGcType)) {
				if (keepGmlArgVar) {
					gml.addFormat('%|var _arg_%s;', arg.name);
				}
				if (arg.value != null) {
					gml.addFormat("%|if (argument_count >= %d) %{", argi);
					gml.addFormat('%|%bw;', "bool", "true");
				}
				if (keepGmlArgVar) {
					gml.addFormat('%|_arg_%s = %s;', arg.name, argGmlRef);
					argGmlRef = '_arg_' + arg.name;
				}
				
				CppFuncArg.current = arg;
				arg.type.proc.gmlWrite(gml, arg.type, 0, argGmlRef);
				arg.type.proc.gmlCleanup(gmlCleanup, arg.type, 0, argGmlRef);
				
				if (arg.value != null) {
					gml.addFormat("%-} else ");
					if (keepGmlArgVar) {
						gml.addFormat('%{');
						gml.addFormat('%|%s = %s;%|', argGmlRef, CppGen.config.isGMK ? '0' : 'undefined');
					}
					gml.addFormat("%bw;", "bool", "false");
					if (keepGmlArgVar) gml.addFormat('%-}');
				}
			} else if (keepGmlArgVar) {
				gml.addFormat('%vds = %s;', '_arg_' + arg.name, argGmlRef);
			}
		}
	}
	
	public function printExtern(cpp:CppBuf, retCppType:String, calcBufSize:Bool, argGcTypes):Int {
		if (retCppType == null) retCppType = retType.toCppType();
		var bufSize = 0;
		var ptrArgCount = 2;
		if (generateFuncExtern) cpp.addFormat("extern %s %s(", retCppType, name);
		for (i => arg in args) {
			
			if (generateFuncExtern) {
				if (i > 0) cpp.addString(", ");
				CppFuncArg.current = arg;
				cpp.addFormat("%s %s", arg.type.toCppType(), arg.name);
			}
			if (calcBufSize) {
				if (arg.value != null) bufSize += 1;
				
				var argGcType = argGcTypes != null ? argGcTypes[i] : null;
				if (!gcTypeUsesBuffer(argGcType) && ptrArgCount < 4) {
					ptrArgCount += 1;
				} else {
					bufSize += arg.type.getSize();
				}
			}
		}
		if (generateFuncExtern) cpp.addFormat(");%|");
		return bufSize;
	}
	
	public function print(gml:CppBuf, cpp:CppBuf) {
		if (isMangled) { CppFuncMangled.print(this, cpp); return; }
		gml.addFormat("#define %s", name);
		
		var retType = this.retType;
		var retGcType = defValue != null ? null : retType.toGmlCppType();
		var retCppType = retType.toCppType();
		var hasReturn = retCppType != "void";
		var retTypeProc = hasReturn ? retType.proc : null;
		var retTypeOpt = retType.unpackOptional();
		
		var config = CppGen.config;
		var argGcTypes = [];
		var ptrArgCount = 2;
		var hasOptArgs = false;
		for (arg in args) {
			CppFuncArg.current = arg;
			if (arg.value != null) hasOptArgs = true;
			var argGcType = arg.type.toGmlCppType();
			if (!gcTypeUsesBuffer(argGcType)) {
				if (ptrArgCount >= 4) {
					argGcType = null;
				} else ptrArgCount += 1;
			}
			argGcTypes.push(argGcType);
		}
		var gmlCleanup = new CppBuf();
		
		// documentation line:
		printGmlDoc(gml, hasReturn, retTypeProc);
		
		// print extern function signature:
		var bufSize = printExtern(cpp, retCppType, true, argGcTypes);
		if (retGcType == null) {
			var retSize = retType.getSize();
			if (retSize > bufSize) bufSize = retSize;
		}
		if (bufSize == 0) bufSize = 1;
		
		//
		var dynSizeBase = config.cppStore.replace("$1", name);
		inline function dynSizeVar(name) {
			return dynSizeBase.replace("$2", name);
		}
		var hasDynSize = false;
		var dynSizeResult = dynSizeVar("return");
		var dynSizePost = "";
		if (retTypeProc != null && retGcType == null) {
			if (retType.hasDynSize()) {
				hasDynSize = true;
			}
		}
		var hasOutArgs = false;
		for (arg in args) if (arg.isOut()) {
			hasOutArgs = true;
			if (arg.type.hasDynSize()) {
				hasDynSize = true;
				var atCpp;
				switch (arg.type.name) {
					case "gml_inout":
						atCpp = arg.type.params[0].toCppType();
					case "gml_inout_vector":
						atCpp = "std::vector<" + arg.type.params[0].toCppType() + ">";
					default: atCpp = arg.type.toCppType();
				}
				cpp.addFormat("static %s %s;%|", atCpp, dynSizeVar(arg.name));
			}
		}
		if (hasDynSize) {
			if (retTypeProc != null) cpp.addFormat("static %s %s;%|", retCppType, dynSizeResult);
			dynSizePost = config.cppPost.replace("$", name);
		}
		
		//
		var argPtr = "_in_ptr";
		if (!hasDynSize && (hasReturn && retGcType == null || hasOutArgs)) {
			argPtr = "_inout_ptr";
		}
		//
		var cppName = config.cppName.replace("$", name);
		cpp.addFormat("%s ", config.exportPrefix);
		cpp.addFormat("%s ", retGcType != null ? retGcType : "double");
		cpp.addFormat("%s(void* %s, double %(s)_size", cppName, argPtr, argPtr);
		//
		var hasGMK = CppGen.outGmkPath != null;
		var cppArgs = new CppBuf();
		cppArgs.indent = cpp.indent + 1;
		if (hasGMK) {
			cppArgs.addFormat("auto _gmkb = %s.data();%|", tools.GmkGen.argBuffer);
			cppArgs.addFormat("if (_gmkb) %s = _gmkb;%|", argPtr);
		}
		cppArgs.addFormat("gml_istream _in(%s);", argPtr);
		
		var gmlCall = new CppBuf();
		gmlCall.addFormat("%s(buffer_get_address(_buf), %d", cppName, bufSize);
		
		if (hasGMK) {
			gml.addFormat("var _buf; _buf = %(s)_prepare_buffer(%d);", CppGen.config.helperPrefix, bufSize);
		} else {
			gml.addFormat("var _buf = %(s)_prepare_buffer(%d);", CppGen.config.helperPrefix, bufSize);
		}
		var hasBufArgs = false;
		var argi = 0;
		for (i => arg in args) {
			CppFuncArg.current = arg;
			var argGcType = argGcTypes[i];
			var argGmlRef = hasOptArgs ? 'argument[$argi]' : 'argument$argi';
			if (arg.type.proc.useGmlArgument()) argi += 1;
			if (gcTypeUsesBuffer(argGcType)) {
				hasBufArgs = true;
				var tp = arg.type.proc;
				var argVar = '_arg_' + arg.name;
				var argPre = '_a_' + arg.name;
				var argCppType = arg.type.toCppType();
				//
				if (arg.value != null) {
					cppArgs.addFormat("%|%s %s;", argCppType, argVar);
					cppArgs.addFormat("%|if (_in.read<bool>()) %{");
				}
				var argExpr = tp.cppRead(cppArgs, arg.type, argPre);
				if (arg.value != null) {
					cppArgs.addFormat('%|%s = %s;', argVar, argExpr);
					cppArgs.addFormat("%-} else %s = %s;", argVar, arg.value);
				} else {
					cppArgs.addFormat("%|%s %s = %s;", argCppType, argVar, argExpr);
				}
			} else {
				cpp.addFormat(", %s _arg_%s", argGcType, arg.name);
				gmlCall.addFormat(", %s", argGmlRef);
			}
		}
		gmlCall.addFormat(")");
		cpp.addFormat(") {%+");
		cpp.addBuffer(cppArgs);
		//
		inline function structModeProc(
			_proc:Void->Void,
			useStructs:Void->Bool,
			useGmkSpec:Void->Bool,
		) {
			proc.CppTypeProcCond.run(gml, _proc, useStructs, useGmkSpec);
		}
		//
		structModeProc(function() {
			printGmlArgsWrite(gml, gmlCleanup, argGcTypes, hasOptArgs);
		}, function() {
			for (arg in args) {
				if (arg.type.proc.usesStructs(arg.type)) return true;
			}
			return false;
		}, function() {
			for (arg in args) {
				if (arg.type.proc.usesGmkSpec(arg.type)) return true;
			}
			return false;
		});
		//
		var cppCall = new CppBuf();
		cppCall.addFormat("%s(", cppFuncName);
		for (i => arg in args) {
			if (i > 0) cppCall.addFormat(", ");
			cppCall.addFormat("_arg_%s", arg.name);
		}
		cppCall.addFormat(")");
		
		//
		inline function writeOutArgs(dyn) {
			for (arg in args) if (arg.isOut()) {
				arg.type.cppWrite(cpp, '_r_' + arg.name, dyn ? dynSizeVar(arg.name) : '_a_' + arg.name);
			}
		}
		if (hasDynSize) {
			if (hasReturn) {
				cpp.addFormat("%|%s = %b;", dynSizeResult, cppCall);
			} else cpp.addFormat("%|%b;", cppCall);
			var dynSize = "_dyn_size";
			var dsb = cpp.fork();
			var fixedSize = 0;
			for (arg in args) if (arg.isOut()) {
				cpp.addFormat("%|%s = %s;", dynSizeVar(arg.name), '_a_' + arg.name);
				if (arg.type.hasDynSize()) {
					fixedSize += arg.type.cppDynSize(dsb, '_sz_' + arg.name, '_a_' + arg.name, dynSize);
				}
			}
			if (hasReturn && retType.hasDynSize()) {
				fixedSize += retType.cppDynSize(dsb, '_sz_return', dynSizeResult, dynSize);
			}
			cpp.addFormat("%|size_t %s = %d;", dynSize, fixedSize);
			cpp.addBuffer(dsb);
			cpp.addFormat("%|return (double)(%s);", dynSize);
			cpp.addFormat("%-}%|");
			//
			cpp.addFormat("%s double %s(void* _out_ptr, double _out_ptr_size) {%+", config.exportPrefix, dynSizePost);
			cpp.addFormat("gml_ostream _out(_out_ptr);");
			writeOutArgs(true);
			if (hasReturn) {
				retTypeProc.cppWrite(cpp, retType, '_r', dynSizeResult);
			}
			cpp.addFormat("%|return 1;");
		} else {
			if (!hasReturn) {
				cpp.addFormat("%|%b;", cppCall);
				if (hasOutArgs) {
					cpp.addFormat("%|gml_ostream _out(%s);", argPtr);
					writeOutArgs(false);
				}
				cpp.addFormat("%|return 1;");
			} else if (retGcType != null) {
				if (hasOutArgs) {
					cpp.addFormat("%|%s _result = %b;", retCppType, cppCall);
					cpp.addFormat("%|gml_ostream _out(%s);", argPtr);
					writeOutArgs(false);
					cpp.addFormat("%|return _result;");
				} else cpp.addFormat("%|return %b;", cppCall);
			} else {
				cpp.addFormat("%|%s _result = %b;", retCppType, cppCall);
				cpp.addFormat("%|gml_ostream _out(%s);", argPtr);
				writeOutArgs(false);
				retTypeProc.cppWrite(cpp, retType, '_r', '_result');
				cpp.addFormat("%|return 1;");
			}
		}
		//
		inline function printReturn():Void {
			structModeProc(function() {
				var rx = retTypeProc.gmlRead(gml, retType, 0);
				if (gmlCleanup.length > 0) {
					gml.addFormat("%|%vdp = %s;", "_result", rx);
					gml.addBuffer(gmlCleanup);
					gml.addFormat("%|return _result;");
				} else gml.addFormat("%|return %s;", rx);
			}, function() {
				return retTypeProc.usesStructs(retType);
			}, function() {
				return retTypeProc.usesGmkSpec(retType);
			});
		}
		//
		var _retDefault:Array<String>;
		if (CppGen.outGmkPath != null && defValue == null) {
			_retDefault = [
				'// GMS >= 1:',
				'return undefined;',
				'/*/',
				'return chr(0);',
				'//*/',
			];
		} else {
			_retDefault = [
				'return ' + (defValue ?? "undefined") + ';'
			];
		}
		inline function addDefaultRet() {
			if (_retDefault.length != 1) {
				gml.addFormat("%{");
				for (line in _retDefault) {
					gml.addFormat("%|%s", line);
				}
				gml.addFormat("%-}");
			} else {
				gml.addString(_retDefault[0]);
			}
		}
		//
		function readOutArgs() {
			structModeProc(function() {
				for (i => arg in args) if (arg.isOut()) {
					arg.type.gmlReadOut(gml, 0, hasOptArgs ? 'argument[$i]' : 'argument$i');
				}
			}, function() {
				for (arg in args) if (arg.isOut()) {
					if (arg.type.proc.usesStructs(arg.type)) return true;
				}
				return false;
			}, function() {
				for (arg in args) if (arg.isOut()) {
					if (arg.type.proc.usesGmkSpec(arg.type)) return true;
				}
				return false;
			});
		}
		if (hasDynSize) {
			gml.addFormat("%|%vdp = %b;", "__size__", gmlCall);
			gml.addFormat("%|if (__size__ == 0) "); addDefaultRet();
			gml.addFormat("%|if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);");
			
			gml.addFormat("%|// GMS >= 2.3:");
			gml.addFormat("%|buffer_set_used_size(_buf, __size__);");
			gml.addFormat("%|/*/");
			gml.addFormat("%|buffer_poke(_buf, __size__ - 1, buffer_u8, 0);");
			gml.addFormat("%|//*/");
			
			gml.addFormat("%|%s(buffer_get_address(_buf), __size__);", dynSizePost);
			gml.addFormat("%|buffer_seek(_buf, buffer_seek_start, 0);");
			readOutArgs();
			if (hasReturn) printReturn();
		} else if (!hasReturn) {
			gml.addFormat("%|%b;", gmlCall);
			if (hasOutArgs) {
				gml.addFormat("%|buffer_seek(_buf, buffer_seek_start, 0);");
				readOutArgs();
			}
			gml.addBuffer(gmlCleanup);
		} else if (retGcType != null) {
			if (hasOutArgs) {
				gml.addFormat("%|buffer_seek(_buf, buffer_seek_start, 0);");
				readOutArgs();
			}
			if (gmlCleanup.length > 0) {
				gml.addFormat("%|%vdp = %b;", "_result", gmlCall);
				gml.addBuffer(gmlCleanup);
				gml.addFormat("%|return _result;");
			} else {
				gml.addFormat("%|return %b;", gmlCall);
			}
		} else {
			gml.addFormat("%|if (%b) %{", gmlCall);
			if (hasBufArgs) {
				gml.addFormat("%|buffer_seek(_buf, buffer_seek_start, 0);");
			}
			readOutArgs();
			printReturn();
			gml.addFormat("%-} else "); addDefaultRet();
		}
		//
		cpp.addFormat("%-}%|%|");
		gml.addFormat("%|%|");
	}
}
