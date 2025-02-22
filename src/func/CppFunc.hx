package func ;
import proc.CppTypeProcGmlPointer;
import misc.GmlConstructor;
import proc.CppTypeProc;
import proc.CppTypeProcOptional;
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
	public var gmlHeader:String = null;
	/** A copy should be added to [Constructor] **/
	public var gmlConstructor:String = null;
	/** Method name for above **/
	public var gmlMethod:String = null;
	/** Whether this is a static method for constructor **/
	public var gmlStatic:Bool = false;
	public var metaComment:String = null;
	public var condition:String = "";
	/** Whether this is a YYRI function **/
	public var isMangled:Bool = false;
	
	public function new(name:String) {
		this.name = name;
		cppFuncName = name;
	}
	
	function printSelfWrite(gml:CppBuf, arg:CppFuncArg, toBuf) {
		var tp = arg.type.proc;
		if (!(tp is CppTypeProcGmlPointer)) {
			CppGen.warn("Methods should have a gml_pointer/gml_id argument in front");
			return null;
		}
		var gtp:CppTypeProcGmlPointer = cast tp;
		//
		var ctr = GmlConstructor.map[gmlConstructor];
		var typename = arg.type.params[0].name;
		if (ctr.isID == null) {
			ctr.isID = gtp.isID;
			ctr.cppType = typename;
		} else if (ctr.isID != gtp.isID || ctr.cppType != typename) {
			CppGen.warn('Re-definition of cpp type for $gmlConstructor from ${ctr.cppType} to $typename');
		}
		//
		return gtp.gmlWriteSelf(gml, arg.type, toBuf);
	}
	function printGmlArgsWrite(gml:CppBuf, gmlCleanup:CppBuf, hasOptArgs, isMethod) {
		var argi = 0;
		var wantSelf = isMethod && !gmlStatic;
		for (i => arg in args) {
			var tp = arg.type.proc;
			var argGmlRef = arg.gmlArgument;
			var keepGmlArgVar = tp.keepGmlArgVar(arg.type);
			arg.gmlUnpacked = null;
			if (arg.type.proc.useGmlArgument()) {
				if (wantSelf) {
					wantSelf = false;
					var val = printSelfWrite(gml, arg, arg.putInBuffer);
					if (!arg.putInBuffer) arg.gmlUnpacked = val;
					continue;
				}
				argi += 1;
			}
			if (arg.putInBuffer) {
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
			} else {
				arg.gmlUnpacked = arg.type.proc.gmlUnpack(gml, arg.type, 0, argGmlRef);
				if (keepGmlArgVar) {
					gml.addFormat('%vds = %s;', '_arg_' + arg.name, argGmlRef);
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
			if (calcBufSize) {
				if (arg.value != null) bufSize += 1;
				if (arg.putInBuffer) bufSize += arg.type.getSize();
			}
		}
		if (generateFuncExtern) cpp.addFormat(");%|");
		return bufSize;
	}
	public function print(gml:CppBuf, cpp:CppBuf) {
		if (isMangled) { CppFuncMangled.print(this, cpp); return; }
		printImpl(gml, cpp, false);
		if (gmlMethod != null) {
			var ctr = GmlConstructor.map[gmlConstructor];
			if (ctr == null) {
				ctr = new GmlConstructor(gmlConstructor);
				GmlConstructor.map[gmlConstructor] = ctr;
				GmlConstructor.list.push(ctr);
			}
			var buf = gmlStatic ? ctr.bufStatics : ctr.bufMethods;
			//
			var config = CppGen.config;
			var _structMode = config.structMode;
			var _boxMode = config.boxMode;
			config.structMode = "1";
			config.boxMode = BmStruct;
			printImpl(buf, new CppBuf(), true);
			config.structMode = _structMode;
			config.boxMode = _boxMode;
		}
	}
	public function printImpl(gml:CppBuf, cpp:CppBuf, isMethod:Bool) {
		var retType = this.retType;
		var retGcType = defValue != null ? null : retType.toGmlCppType(true);
		var retCppType = retType.toCppType();
		var hasReturn = retCppType != "void";
		var retTypeProc = hasReturn ? retType.proc : null;
		
		// GML start:
		if (isMethod) {
			gml.addFormat("%|%|");
			if (gmlStatic) gml.addFormat("/// @static%|");
			CppFuncGmlDoc.print(this, gml, hasReturn, retTypeProc, true);
			gml.addFormat("static %s = function() {%+", gmlMethod);
		} else {
			gml.addFormat("#define %s", name);
			CppFuncGmlDoc.print(this, gml, hasReturn, retTypeProc, false);
		}
		
		// figure out what goes in the buffer and what will be an actual argument:
		var config = CppGen.config;
		var needsBuffer = retGcType == null;
		var numPointers = 0;
		var numDoubles = 0;
		var hasOptArgs = args.filter(arg -> arg.value != null).length > 0;
		//
		var nextArgIndex = 0;
		for (i => arg in args) {
			if (i == 0 && isMethod && !gmlStatic) {
				var atp = arg.type.proc;
				if (atp is CppTypeProcGmlPointer) {
					var gtp:CppTypeProcGmlPointer = cast atp;
					var ctr = GmlConstructor.map[gmlConstructor];
					var typename = arg.type.params[0].name;
					if (ctr.isID == null) {
						ctr.isID = gtp.isID;
						ctr.cppType = typename;
					} else if (ctr.isID != gtp.isID || ctr.cppType != typename) {
						CppGen.warn('Re-definition of cpp type for $gmlConstructor from ${ctr.cppType} to $typename');
					}
					arg.gmlArgument = "self." + (gtp.isID ? "__id__" : "__ptr__");
					arg.isSelf = true;
					continue;
				} else {
					CppGen.warn("Non-static methods should have a gml_pointer/gml_id argument in front");
				}
			}
			arg.isSelf = false;
			var i = nextArgIndex++;
			arg.gmlArgument = hasOptArgs ? 'argument[$i]' : 'argument$i';
		}
		//
		for (arg in args) {
			CppFuncArg.current = arg;
			
			/*if (arg.type.proc is CppTypeProcGmlPointer && !arg.isSelf) {
				arg.exportType = null;
			} else */arg.exportType = arg.type.toGmlCppType(false);
			arg.putInBuffer = arg.exportType == null;
			if (arg.putInBuffer) {
				needsBuffer = true;
			} else if (arg.exportType == "double") {
				numDoubles += 1;
			} else {
				numPointers += 1;
			}
		}
		//
		var mixedArgs = numPointers > 0;
		if (!needsBuffer) {
			if (mixedArgs) {
				// up to 4 arguments in mixed-type functions
				if (numPointers + numDoubles > 4) needsBuffer = true;
			} else {
				// up to 16 arguments in double-only functions
				if (numDoubles > 16) needsBuffer = true;
			}
		}
		var exportedArgs = needsBuffer ? 2 : 0;
		var maxArgs = mixedArgs ? 4 : 16;
		var freePointers = maxArgs - exportedArgs;
		if (freePointers > numPointers) freePointers = numPointers;
		var freeDoubles = maxArgs - exportedArgs - numPointers;
		for (arg in args) {
			if (arg.exportType == null) continue;
			if (arg.exportType == "double") {
				if (freeDoubles > 0) {
					freeDoubles -= 1;
					arg.putInBuffer = false;
				} else {
					arg.putInBuffer = true;
					arg.exportType = null;
				}
			} else {
				if (freePointers > 0) {
					freePointers -= 1;
					arg.putInBuffer = false;
				} else {
					arg.putInBuffer = true;
					arg.exportType = null;
				}
			}
		}
		
		var gmlCleanup = new CppBuf();
		
		if (gmlHeader != null) {
			gml.addFormat("%s%|", gmlHeader);
		}
		
		// print extern function signature:
		var bufSize = printExtern(cpp, retCppType, true);
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
			}
		}
		if (hasDynSize) {
			if (retTypeProc != null) cpp.addFormat("static %s %s;%|", retCppType, dynSizeResult);
			for (arg in args) if (arg.isOut()) {
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
		cpp.addFormat("%s(", cppName);
		if (needsBuffer) {
			cpp.addFormat("void* %s, double %(s)_size", argPtr, argPtr);
		}
		var cppArgSep = needsBuffer;
		//
		var hasGMK = CppGen.outGmkPath != null;
		var cppArgs = new CppBuf();
		cppArgs.indent = cpp.indent + 1;
		if (needsBuffer) {
			if (hasGMK) {
				cppArgs.addFormat("auto _gmkb = %s.data();%|", tools.GmkGen.argBuffer);
				cppArgs.addFormat("if (_gmkb) %s = _gmkb;%|", argPtr);
			}
			cppArgs.addFormat("gml_istream _in(%s);", argPtr);
		} else cppArgs.addFormat("// no buffer!");
		
		if (!needsBuffer) {
			gml.addFormat("// no buffer!");
		} else if (hasGMK) {
			gml.addFormat("var _buf; _buf = %(s)_prepare_buffer(%d);", CppGen.config.helperPrefix, bufSize);
		} else {
			gml.addFormat("var _buf = %(s)_prepare_buffer(%d);", CppGen.config.helperPrefix, bufSize);
		}
		var hasBufArgs = false;
		for (i => arg in args) {
			CppFuncArg.current = arg;
			var argGmlRef = arg.gmlArgument;
			if (arg.putInBuffer) {
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
				if (cppArgSep) {
					cpp.addString(", ");
				} else cppArgSep = true;
				cpp.addFormat("%s _arg_%s", arg.exportType, arg.name);
			}
		}
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
			printGmlArgsWrite(gml, gmlCleanup, hasOptArgs, isMethod);
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
		var gmlCall = new CppBuf();
		gmlCall.addFormat("%s(", cppName);
		if (needsBuffer) gmlCall.addFormat("buffer_get_address(_buf), %d", bufSize);
		var gmlCallSep = needsBuffer;
		for (arg in args) if (!arg.putInBuffer) {
			if (gmlCallSep) {
				gmlCall.addString(", ");
			} else gmlCallSep = true;
			gmlCall.addFormat("%s", arg.gmlUnpacked ?? arg.gmlArgument);
		}
		gmlCall.addFormat(")");
		//
		var cppCall = new CppBuf();
		cppCall.addFormat("%s(", cppFuncName);
		for (i => arg in args) {
			if (i > 0) cppCall.addFormat(", ");
			if (!arg.putInBuffer && arg.exportType == "double" && arg.type.name != "double") {
				cppCall.addFormat("(%s)", arg.type.toCppType());
			}
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
			if (hasGMK) {
				cpp.addFormat("auto _gmkb = %s.data();%|", tools.GmkGen.argBuffer);
				cpp.addFormat("if (_gmkb) _out_ptr = _gmkb;%|");
			}
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
		if (defValue != null) {
			_retDefault = ['return $defValue;'];
		}
		else if (!hasReturn) {
			_retDefault = ['exit'];
		}
		else if (CppGen.outGmkPath != null) {
			var v23 = CppTypeProcOptional.getDefValue(retType, true, false);
			var v14 = CppTypeProcOptional.getDefValue(retType, false, false);
			var v8 = CppTypeProcOptional.getDefValue(retType, false, true);
			if (v23 == v14 && v14 == v8) {
				_retDefault = ['return $v23;'];
			} else if (v23 == v14) {
				_retDefault = [
					'// GMS >= 1:',
					'return $v14;',
					'/*/',
					'return $v8;',
					'//*/',
				];
			} else if (v14 == v8) {
				_retDefault = [
					'// GMS >= 2.3:',
					'return $v23;',
					'/*/',
					'return $v14;',
					'//*/',
				];
			} else {
				_retDefault = [
					'// GMS >= 2.3:',
					'return $v23;',
					'//*/',
					'// GMS >= 1 && GMS < 2.3:',
					'return $v14;',
					'//*/',
					'// GMS < 1:',
					'return $v8;',
					'//*/',
				];
			}
		} else {
			_retDefault = ['return undefined;'];
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
					arg.type.gmlReadOut(gml, 0, arg.gmlArgument);
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
			if (CppGen.hasGmkPath) {
				gml.addFormat("%|//*/");
				gml.addFormat("%|// GMS >= 1 && GMS < 2.3:");
			} else gml.addFormat("%|/*/");
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
		if (isMethod) {
			gml.addFormat("%-}");
		} else {
			gml.addFormat("%|%|");
		}
	}
}
