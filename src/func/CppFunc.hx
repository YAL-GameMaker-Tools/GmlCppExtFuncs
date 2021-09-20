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
	public var args:Array<func.CppFuncArg> = [];
	public var retType:CppType;
	public var metaComment:String = null;
	public var condition:String = "";
	
	public function new(name:String) {
		this.name = name;
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
			if (sep) gml.add(", "); else sep = true;
			gml.addFormat("%s", arg.name);
			if (arg.type != null) {
				var docType = arg.type.proc.getGmlDocTypeEx(arg.type);
				if (docType != null) gml.addFormat(":%s", docType);
			}
			if (arg.value != null) {
				gml.addFormat(" = %s", arg.value);
			}
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
	
	function printGmlArgsWrite(gml:CppBuf, argGcTypes, hasOptArgs) {
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
				
				arg.type.proc.gmlWrite(gml, arg.type, 0, argGmlRef);
				
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
			if (arg.value != null) hasOptArgs = true;
			argGcTypes.push(arg.type.toGmlCppType());
		}
		
		// documentation line:
		printGmlDoc(gml, hasReturn, retTypeProc);
		
		// print extern function signature:
		cpp.addFormat("extern %s %s(", retCppType, name);
		var bufSize = 0;
		for (i => arg in args) {
			if (i > 0) cpp.addString(", ");
			cpp.addFormat("%s %s", arg.type.toCppType(), arg.name);
			bufSize += arg.type.getSize();
		}
		cpp.addFormat(");%|");
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
		var cppName = config.cppName.replace("$", name);
		cpp.addFormat("%s ", config.exportPrefix);
		cpp.addFormat("%s ", retGcType != null ? retGcType : "double");
		cpp.addFormat("%s(void* _ptr", cppName);
		//
		var cppArgs = new CppBuf();
		cppArgs.indent = cpp.indent + 1;
		cppArgs.addFormat("gml_istream _in(_ptr);");
		
		var gmlCall = new CppBuf();
		gmlCall.addFormat("%s(buffer_get_address(_buf)", cppName);
		
		gml.addFormat("var _buf = %(s)_prepare_buffer(%d);", CppGen.config.helperPrefix, bufSize);
		var hasBufArgs = false;
		var argi = 0;
		for (i => arg in args) {
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
			printGmlArgsWrite(gml, argGcTypes, hasOptArgs);
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
		cppCall.addFormat("%s(", name);
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
			cpp.addFormat("%s double %s(void* _ptr) {%+", config.exportPrefix, cppVecPost);
			cpp.addFormat("gml_ostream _out(_ptr);");
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
			cpp.addFormat("%|gml_ostream _out(_ptr);");
			retTypeProc.cppWrite(cpp, retType, '_ret');
			cpp.addFormat("%|return 1;");
		}
		//
		inline function printReturn(pre:Bool):Void {
			structModeProc(function() {
				if (pre) gml.addLine();
				gml.addFormat("return %s;", retTypeProc.gmlRead(gml, retType, 0));
			}, function() {
				return retTypeProc.usesStructs(retType);
			});
		}
		if (vecType != null) {
			gml.addFormat("%|var __size__ = %b;", gmlCall);
			gml.addFormat("%|if (__size__ == 0) return undefined;");
			gml.addFormat("%|if (__size__ <= 4) return [];");
			gml.addFormat("%|if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);");
			gml.addFormat("%|%s(buffer_get_address(_buf));", cppVecPost);
			gml.addFormat("%|buffer_seek(_buf, buffer_seek_start, 0);");
			printReturn(true);
		} else if (!hasReturn) {
			gml.addFormat("%|%b;", gmlCall);
		} else if (retGcType != null) {
			gml.addFormat("%|return %b;", gmlCall);
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
