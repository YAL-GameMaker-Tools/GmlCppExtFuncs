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
			var argGmlRef = hasOptArgs ? 'argument[$argi]' : 'argument$argi';
			if (arg.type.proc.useGmlArgument()) argi += 1;
			if (gcTypeUsesBuffer(argGcType)) {
				if (arg.value != null) {
					gml.addFormat("%|if (argument_count >= %d) {%+", argi);
					gml.addFormat("buffer_write(_buf, buffer_bool, true);");
				}
				
				CppFuncArg.current = arg;
				arg.type.proc.gmlWrite(gml, arg.type, 0, argGmlRef);
				arg.type.proc.gmlCleanup(gmlCleanup, arg.type, 0, argGmlRef);
				
				if (arg.value != null) {
					gml.addFormat("%-} else buffer_write(_buf, buffer_bool, false);");
				}
			}
		}
	}
	
	public function printExtern(cpp:CppBuf, retCppType:String, calcBufSize:Bool):Int {
		if (retCppType == null) retCppType = retType.toCppType();
		var bufSize = 0;
		if (generateFuncExtern) cpp.addFormat("extern %s %s(", retCppType, name);
		for (i => arg in args) {
			if (generateFuncExtern) {
				if (i > 0) cpp.addString(", ");
				CppFuncArg.current = arg;
				cpp.addFormat("%s %s", arg.type.toCppType(), arg.name);
			}
			if (arg.value != null) bufSize += 1;
			if (calcBufSize) bufSize += arg.type.getSize();
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
		var bufSize = printExtern(cpp, retCppType, true);
		if (retGcType == null) {
			var retSize = retType.getSize();
			if (retSize > bufSize) bufSize = retSize;
		}
		if (bufSize == 0) bufSize = 1;
		
		//
		var dynSizeStore = config.cppVector.replace("$", name);
		var dynSizeSnip:String = null;
		var dynSizePost = "";
		if (retTypeProc != null && retGcType == null) {
			dynSizeSnip = retTypeProc.getDynSize(retType, dynSizeStore);
			if (dynSizeSnip != null) {
				dynSizePost = config.cppPost.replace("$", name);
				cpp.addFormat("static %s %s;%|", retCppType, dynSizeStore);
			}
		}
		
		//
		var argPtr = "_in_ptr";
		if (dynSizeSnip == null && hasReturn && retGcType == null) {
			argPtr = "_inout_ptr";
		}
		//
		var cppName = config.cppName.replace("$", name);
		cpp.addFormat("%s ", config.exportPrefix);
		cpp.addFormat("%s ", retGcType != null ? retGcType : "double");
		cpp.addFormat("%s(void* %s, double %(s)_size", cppName, argPtr, argPtr);
		//
		var cppArgs = new CppBuf();
		cppArgs.indent = cpp.indent + 1;
		if (CppGen.outGmkPath != null) {
			cppArgs.addFormat("auto _gmkb = %s.data();%|", tools.GmkGen.argBuffer);
			cppArgs.addFormat("if (_gmkb) %s = _gmkb;%|", argPtr);
		}
		cppArgs.addFormat("gml_istream _in(%s);", argPtr);
		
		var gmlCall = new CppBuf();
		gmlCall.addFormat("%s(buffer_get_address(_buf), %d", cppName, bufSize);
		
		var hasGMK = CppGen.outGmkPath != null;
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
				var td = CppTypeHelper.find(arg.type);
				cppArgs.addFormat("%|%s _arg_%s;%|", arg.type.toCppType(), arg.name);
				
				if (arg.value != null) cppArgs.addFormat("if (_in.read<bool>()) {%+");
				
				cppArgs.addFormat('_arg_%s = %s;', arg.name, td.cppRead(cppArgs, arg.type));
				
				if (arg.value != null) cppArgs.addFormat("%-} else _arg_%s = %s;", arg.name, arg.value);
			} else {
				cpp.addFormat(", %s _arg_%s", argGcType, arg.name);
				gmlCall.addFormat(", %s", argGmlRef);
			}
		}
		gmlCall.addFormat(")");
		cpp.addFormat(") {%+");
		cpp.addBuffer(cppArgs);
		//
		var structMode = CppGen.config.structMode;
		var structModeVal = CppGen.config.structModeVal;
		var structModeCond = structMode != "auto";
		function structModeProc(_proc:Void->Void, useStructs:Void->Bool) {
			function proc(sm, bm, gmk = false) {
				config.storageMode = sm;
				config.boxMode = bm;
				config.isGMK = gmk;
				_proc();
			}
			var gmk = CppGen.outGmkPath != null;
			if (gmk) {
				var arrayOnly = structModeVal == false || !useStructs();
				if (arrayOnly) {
					gml.addFormat("%|/* GMS >= 1:");
					proc(SmArray, BmArray);
					gml.addFormat("%|//*/");
				} else {
					gml.addFormat("%|/* GMS >= 2.3:");
					proc(SmStruct, BmStruct);
					gml.addFormat("%|//*/");
					gml.addFormat("%|/* GMS < 2.3 && GMS >= 1:");
					proc(SmArray, BmArray);
					gml.addFormat("%|//*/");
				}
				gml.addFormat("%|// GMS < 1:");
				proc(arrayOnly ? SmList : SmMap, BmList, true);
				gml.addFormat("%|//*/");
			} else if (structModeVal != null) {
				if (structModeVal) {
					proc(SmStruct, BmStruct);
				} else {
					proc(SmArray, BmArray);
				}
			} else {
				if (useStructs()) {
					gml.addFormat("%|// GMS >= 2.3:");
					if (structModeCond) {
						gml.addFormat("%|if (%s) %{", structMode);
					}
					proc(SmStruct, BmStruct);
					if (structModeCond) {
						gml.addFormat("%-} else //*/");
						gml.addFormat("%|%{");
					} else {
						gml.addFormat("%|/*/");
					}
					proc(SmArray, BmArray);
					if (structModeCond) {
						gml.addFormat("%-}");
					} else {
						gml.addFormat("%|//*/");
					}
				} else {
					proc(SmArray, BmArray);
				}
			}
		}
		//
		structModeProc(function() {
			printGmlArgsWrite(gml, gmlCleanup, argGcTypes, hasOptArgs);
		}, function() {
			var argsUseStructs = false;
			for (arg in args) {
				if (arg.type.proc.usesStructs(arg.type)) {
					argsUseStructs = true;
					break;
				}
			}
			return argsUseStructs;
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
		if (dynSizeSnip != null) {
			cpp.addFormat("%|%s = %b;", dynSizeStore, cppCall);
			cpp.addFormat("%|return (double)(%s);", dynSizeSnip);
			cpp.addFormat("%-}%|");
			cpp.addFormat("%s double %s(void* _out_ptr, double _out_ptr_size) {%+", config.exportPrefix, dynSizePost);
			cpp.addFormat("gml_ostream _out(_out_ptr);");
			retTypeProc.cppWrite(cpp, retType, dynSizeStore);
			cpp.addFormat("%|return 1;");
		} else if (!hasReturn) {
			cpp.addFormat("%|%b;", cppCall);
			cpp.addFormat("%|return 1;");
		} else if (retGcType != null) {
			cpp.addFormat("%|return %b;", cppCall);
		} else {
			cpp.addFormat("%|%s _ret = %b;", retCppType, cppCall);
			cpp.addFormat("%|gml_ostream _out(%s);", argPtr);
			retTypeProc.cppWrite(cpp, retType, '_ret');
			cpp.addFormat("%|return 1;");
		}
		//
		inline function printReturn(pre:Bool):Void {
			structModeProc(function() {
				if (pre) gml.addLine();
				var rx = retTypeProc.gmlRead(gml, retType, 0);
				if (gmlCleanup.length > 0) {
					gml.addFormat("%|%vdp = %s;", "_result", rx);
					gml.addBuffer(gmlCleanup);
					gml.addFormat("%|return _result;");
				} else gml.addFormat("%|return %s;", rx);
			}, function() {
				return retTypeProc.usesStructs(retType);
			});
		}
		//
		var _retDefault:Array<String>;
		if (CppGen.outGmkPath != null && defValue == null) {
			_retDefault = [
				'// GMS >= 1:',
				'return undefined;',
				'/*/',
				'return -1;',
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
		if (dynSizeSnip != null) {
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
			printReturn(true);
		} else if (!hasReturn) {
			gml.addFormat("%|%b;", gmlCall);
			gml.addBuffer(gmlCleanup);
		} else if (retGcType != null) {
			if (gmlCleanup.length > 0) {
				gml.addFormat("%|%vdp = %b;", "_result", gmlCall);
				gml.addBuffer(gmlCleanup);
				gml.addFormat("%|return _result;");
			} else gml.addFormat("%|return %b;", gmlCall);
		} else {
			gml.addFormat("%|if (%b) %{", gmlCall);
			if (hasBufArgs) {
				gml.addFormat("%|buffer_seek(_buf, buffer_seek_start, 0);");
			}
			printReturn(false);
			gml.addFormat("%-} else "); addDefaultRet();
		}
		//
		cpp.addFormat("%-}%|%|");
		gml.addFormat("%|%|");
	}
}
