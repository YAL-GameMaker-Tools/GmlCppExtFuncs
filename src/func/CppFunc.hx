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
	public var args:Array<func.CppFuncArg> = [];
	public var retType:CppType;
	public var metaComment:String = null;
	public var condition:String = "";
	
	public function new(name:String) {
		this.name = name;
		cppFuncName = name;
	}
	
	function printGmlDoc(gml:CppBuf, hasReturn:Bool, retTypeProc:CppTypeProc) {
		if (metaComment != null && metaComment.startsWith("(")) {
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
	
	public function print(gml:CppBuf, cpp:CppBuf) {
		gml.addFormat("#define %s", name);
		
		var retType = this.retType;
		var retGcType = retType.toGmlCppType();
		var retCppType = retType.toCppType();
		var hasReturn = retCppType != "void";
		var retTypeProc = hasReturn ? retType.proc : null;
		var retTypeOpt = retType.unpackOptional();
		
		var config = CppGen.config;
		var argGcTypes = [];
		var hasOptArgs = false;
		for (arg in args) {
			CppFuncArg.current = arg;
			if (arg.value != null) hasOptArgs = true;
			argGcTypes.push(arg.type.toGmlCppType());
		}
		var gmlCleanup = new CppBuf();
		
		// documentation line:
		printGmlDoc(gml, hasReturn, retTypeProc);
		
		// print extern function signature:
		var bufSize = 0;
		if (generateFuncExtern)cpp.addFormat("extern %s %s(", retCppType, name);
		for (i => arg in args) {
			if (generateFuncExtern) {
				if (i > 0) cpp.addString(", ");
				CppFuncArg.current = arg;
				cpp.addFormat("%s %s", arg.type.toCppType(), arg.name);
			}
			if (arg.value != null) bufSize += 1;
			bufSize += arg.type.getSize();
		}
		if (generateFuncExtern) cpp.addFormat(");%|");
		if (retGcType == null) {
			var retSize = retType.getSize();
			if (retSize > bufSize) bufSize = retSize;
		}
		if (bufSize == 0) bufSize = 1;
		
		//
		var vecType = (retTypeOpt != null ? retTypeOpt : retType).unpackVector();
		var cppVecType = "", cppVecStore = "", cppVecPost = "";
		if (vecType != null) {
			cppVecStore = config.cppVector.replace("$", name);
			cppVecPost = config.cppPost.replace("$", name);
			cppVecType = vecType.toCppType();
			cpp.addFormat("static vector<%s> %s;%|", cppVecType, cppVecStore);
		}
		
		//
		var argPtr = "_in_ptr";
		if (vecType == null && hasReturn && retGcType == null) {
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
		cppArgs.addFormat("gml_istream _in(%s);", argPtr);
		
		var gmlCall = new CppBuf();
		gmlCall.addFormat("%s(buffer_get_address(_buf), %d", cppName, bufSize);
		
		gml.addFormat("var _buf = %(s)_prepare_buffer(%d);", CppGen.config.helperPrefix, bufSize);
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
		inline function structModeProc(_proc:Void->Void, useStructs:Void->Bool) {
			inline function proc(z:Bool) {
				CppGen.config.useStructs = z;
				_proc();
			}
			if (structModeVal != null) {
				proc(structModeVal);
			} else {
				if (useStructs()) {
					gml.addFormat("%|// GMS >= 2.3:");
					if (structModeCond) gml.addFormat("%|if (%s) %{", structMode);
					proc(true);
					if (structModeCond) {
						gml.addFormat("%-} else //*/");
						gml.addFormat("%|%{");
					} else {
						gml.addFormat("%|/*/");
					}
					proc(false);
					if (structModeCond) {
						gml.addFormat("%-}");
					} else {
						gml.addFormat("%|//*/");
					}
				} else proc(false);
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
		if (vecType != null) {
			if (retTypeOpt != null) {
				cpp.addFormat("%|auto _ret = %b;", cppCall);
				cpp.addFormat("%|if (!_ret.has_value()) return 0;");
				cpp.addFormat("%|%s = _ret.value();", cppVecStore);
			} else {
				cpp.addFormat("%|%s = %b;", cppVecStore, cppCall);
			}
			cpp.addFormat("%|return (double)(4 + %s.size() * sizeof(%s));", cppVecStore, cppVecType);
			cpp.addFormat("%-}%|");
			cpp.addFormat("%s double %s(void* _out_ptr, double _out_ptr_size) {%+", config.exportPrefix, cppVecPost);
			cpp.addFormat("gml_ostream _out(_out_ptr);");
			if (retTypeOpt != null) {
				retTypeOpt.proc.cppWrite(cpp, retTypeOpt, cppVecStore);
			} else {
				retTypeProc.cppWrite(cpp, retType, cppVecStore);
			}
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
					gml.addFormat("var _result = %s;%b%|return _result;", rx, gmlCleanup);
				} else gml.addFormat("return %s;", rx);
			}, function() {
				return retTypeProc.usesStructs(retType);
			});
		}
		if (vecType != null) {
			gml.addFormat("%|var __size__ = %b;", gmlCall);
			gml.addFormat("%|if (__size__ == 0) return undefined;");
			gml.addFormat("%|if (__size__ <= 4) return [];");
			gml.addFormat("%|if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);");
			gml.addFormat("%|%s(buffer_get_address(_buf), __size__);", cppVecPost);
			gml.addFormat("%|buffer_seek(_buf, buffer_seek_start, 0);");
			printReturn(true);
		} else if (!hasReturn) {
			gml.addFormat("%|%b;", gmlCall);
			gml.addBuffer(gmlCleanup);
		} else if (retGcType != null) {
			if (gmlCleanup.length > 0) {
				gml.addFormat("%|var _result = %b;%b%|return _result;", gmlCall, gmlCleanup);
			} else gml.addFormat("%|return %b;", gmlCall);
		} else {
			gml.addFormat("%|if (%b) {%+", gmlCall);
			if (hasBufArgs) gml.addFormat("buffer_seek(_buf, buffer_seek_start, 0);%|");
			printReturn(false);
			gml.addFormat("%-} else return undefined;");
		}
		//
		cpp.addFormat("%-}%|%|");
		gml.addFormat("%|%|");
	}
}
