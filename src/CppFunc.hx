package ;
import proc.CppTypeProc;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class CppFunc {
	public static var list:Array<CppFunc> = [];
	
	public var name:String;
	public var args:Array<CppFuncArg> = [];
	public var retType:CppType;
	public function new(name:String) {
		this.name = name;
	}
	
	public function print(gml:CppBuf, cpp:CppBuf) {
		gml.addFormat("#define %s", name);
		
		//
		var config = CppGen.config;
		var argGcTypes = [];
		var hasOptArgs = false;
		for (arg in args) {
			if (arg.value != null) hasOptArgs = true;
			argGcTypes.push(arg.type.toGmlCppType());
		}
		var retCppType = retType.toCppType();
		var hasReturn = retCppType != "void";
		var retGcType = retType.toGmlCppType();
		var retTypeProc = hasReturn ? retType.proc : null;
		
		// documentation line:
		gml.addFormat("%|/// %s(", name);
		for (i => arg in args) {
			if (i > 0) gml.add(", ");
			gml.addFormat("%s", arg.name);
			if (arg.type != null) {
				var docType = arg.type.proc.getGmlDocType(arg.type);
				if (docType != null) gml.addFormat(":%s", docType);
			}
			if (arg.value != null) {
				gml.addFormat(" = %s", arg.value);
			}
		}
		gml.add(")");
		if (hasReturn && retTypeProc != null) {
			gml.add("->");
			var docType = retTypeProc.getGmlDocType(retType);
			if (docType != null) gml.addString(docType);
		}
		gml.addLine();
		
		// extern
		cpp.addFormat("extern %s %s(", retCppType, name);
		var bufSize = 0;
		for (i => arg in args) {
			if (i > 0) cpp.addString(", ");
			cpp.addFormat("%s %s", arg.type.toCppType(), arg.name);
			bufSize += arg.type.proc.getSize();
		}
		cpp.addFormat(");%|");
		if (retGcType == null) {
			var retSize = retType.proc.getSize();
			if (retSize > bufSize) bufSize = retSize;
		}
		if (bufSize == 0) bufSize = 1;
		
		//
		var vecType = retType.unpackVector();
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
		cppArgs.addFormat("gml_buffer _buf(_ptr);");
		
		var gmlCall = new CppBuf();
		gmlCall.addFormat("%s(buffer_get_address(_buf)", cppName);
		
		gml.addFormat("var _buf = %(s)_prepare_buffer(%d);", CppGen.config.helperPrefix, bufSize);
		var hasBufArgs = false;
		for (i => arg in args) {
			var argGcType = argGcTypes[i];
			var argGmlRef = hasOptArgs ? 'argument[$i]' : 'argument$i';
			switch (argGcType) {
				case null, "double":
					hasBufArgs = true;
					var td = CppTypeHelper.find(arg.type);
					cppArgs.addFormat("%|%s _arg_%s;%|", arg.type.toCppType(), arg.name);
					
					if (arg.value != null) {
						gml.addFormat("%|if (argument_count >= %d) {%+", i);
						gml.addFormat("buffer_write(_buf, buffer_bool, true);");
						cppArgs.addFormat("if (_buf.read<bool>()) {%+");
					}
					
					td.gmlWrite(gml, arg.type, 0, argGmlRef);
					cppArgs.addFormat('_arg_%s = %s;', arg.name, td.cppRead(cppArgs, arg.type));
					
					if (arg.value != null) {
						gml.addFormat("%-} else buffer_write(_buf, buffer_bool, false);");
						cppArgs.addFormat("%-} else _arg_%s = %s;", arg.name, arg.value);
					}
				default:
					cpp.addFormat(", %s %s", argGcType, arg.name);
					gmlCall.addFormat(", %s", argGmlRef);
			}
		}
		gmlCall.addFormat(")");
		cpp.addFormat(") {%+");
		cpp.addBuffer(cppArgs);
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
			cpp.addFormat("%|%s = %b;", cppVecStore, cppCall);
			cpp.addFormat("%|return 4 + %s.size() * /* sizeof(%s) */%d;", cppVecStore, cppVecType, vecType.proc.getSize());
			cpp.addFormat("%-}%|");
			cpp.addFormat("%s double %s(void* _ptr) {%+", config.exportPrefix, cppVecPost);
			cpp.addFormat("gml_buffer _buf(_ptr);");
			retTypeProc.cppWrite(cpp, retType, cppVecStore);
			cpp.addFormat("%|return 1;");
		} else if (!hasReturn) {
			cpp.addFormat("%|%b;", cppCall);
			cpp.addFormat("%|return 1;");
		} else if (retGcType != null) {
			cpp.addFormat("%|return %b;", cppCall);
		} else {
			cpp.addFormat("%|%s __ret__ = %b;", retCppType, cppCall);
			if (hasBufArgs) cpp.addFormat("%|_buf.rewind();");
			retTypeProc.cppWrite(cpp, retType, '__ret__');
			cpp.addFormat("%|return 1;");
		}
		//
		if (vecType != null) {
			gml.addFormat("%|var __size__ = %b;", gmlCall);
			gml.addFormat("%|if (__size__ == 0) return undefined;");
			gml.addFormat("%|if (__size__ <= 4) return [];");
			gml.addFormat("%|if (buffer_get_size(_buf) < __size__) buffer_resize(_buf, __size__);");
			gml.addFormat("%|%s(buffer_get_address(_buf));", cppVecPost);
			gml.addFormat("%|buffer_seek(_buf, buffer_seek_start, 0);");
			gml.addFormat("%|");
			gml.addFormat("return %s;", retTypeProc.gmlRead(gml, retType, 0));
		} else if (!hasReturn) {
			gml.addFormat("%|%b;", gmlCall);
		} else if (retGcType != null) {
			gml.addFormat("%|return %b;", gmlCall);
		} else {
			gml.addFormat("%|if (%b) {%+", gmlCall);
			if (hasBufArgs) gml.addFormat("buffer_seek(_buf, buffer_seek_start, 0);%|");
			gml.addFormat("return %s;", retTypeProc.gmlRead(gml, retType, 0));
			gml.addFormat("%-} else return undefined;");
		}
		//
		cpp.addFormat("%-}%|%|");
		gml.addFormat("%|%|");
	}
	
	public static function read(q:CppReader) {
		var retType = CppType.read(q);
		var fnName = q.readSpIdent();
		q.skipSpaces();
		if (!q.skipIfEqu("(".code)) return;
		//
		var fn = new CppFunc(fnName);
		fn.retType = retType;
		list.push(fn);
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
						var arg = new CppFuncArg(argType, argName);
						fn.args.push(arg);
						q.skipSpaces();
						if (q.skipIfEqu("=".code)) {
							q.skipSpaces();
							var valStart = q.pos;
							while (q.loop) {
								c = q.read();
								switch (c) {
									case "(".code: depth++;
									case ")".code: if (--depth <= 1) break;
									case ",".code: if (depth <= 1) break;
								}
							}
							arg.value = q.substring(valStart, q.pos - 1).trim();
							if (depth <= 0) break;
						}
					}
			}
		}
	}
}
