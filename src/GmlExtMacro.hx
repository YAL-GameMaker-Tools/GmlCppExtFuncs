package ;
import func.CppFunc;
import func.CppFuncArg;
import haxe.macro.Compiler;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.io.File;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class GmlExtMacro {
	static var isFirstClass:Bool = false;
	static var initFunc:String;
	static var gmlAutogen:CppBuf;
	static var cppAutogen:CppBuf;
	public static function build():Array<Field> {
		var localClass:ClassType = {
			var r_class = Context.getLocalClass();
			if (r_class == null) {
				Context.error("Should be applied to a class", Context.currentPos());
				return null;
			}
			r_class.get();
		}
		
		var cppAutogen = new CppBuf();
		
		var fields = Context.getBuildFields();
		for (field in fields) {
			if (field.meta == null) continue;
			
			var dllExport = field.meta.filter(m -> m.name == ":dllExport")[0];
			if (dllExport == null) continue;
			
			var mf = switch (field.kind) {
				case FFun(f): f;
				default:
					Context.error("@:dllExport should be applied to a function.", field.pos);
					continue;
			}
			
			var fname = field.name;
			var exportName = fname;
			if (dllExport.params != null) switch (dllExport.params[0]) {
				case null:
				case { expr: EConst(CString(_name)) }: exportName = _name;
				default:
			}
			
			var cf = new CppFunc(exportName);
			cf.cppFuncName = localClass.pack.concat([localClass.name + "_obj", fname]).join("::");
			cf.retType = CppTypeMacroHelper.fromComplexType(mf.ret);
			cf.generateFuncExtern = false;
			if (cf.retType == null) {
				Context.error("Couldn't convert return type for " + field.name
					+ " (" + ComplexTypeTools.toString(mf.ret) + ")", field.pos);
				continue;
			}
			for (arg in mf.args) {
				var cargType = CppTypeMacroHelper.fromComplexType(arg.type);
				if (cargType == null) {
					Context.error("Couldn't convert type for " + field.name
						+ " argument " + arg.name
						+ " (" + ComplexTypeTools.toString(arg.type) + ")", field.pos);
					continue;
				}
				var carg = new CppFuncArg(cargType, arg.name);
				cf.args.push(carg);
			}
			cf.print(gmlAutogen, cppAutogen);
		}
		
		var cppFileCodeStr = cppAutogen.toString();
		if (isFirstClass) {
			isFirstClass = false;
			cppFileCodeStr = [
				'extern "C" const char *hxRunLibrary();',
				'extern "C" void hxcpp_set_top_of_stack();',
				'dllx const char* $initFunc() {',
				'\t' + 'hxcpp_set_top_of_stack();',
				'\t' + 'const char* result = hxRunLibrary();',
				'\t' + 'return result ? result : "OK!";',
				'}',
				cppFileCodeStr
			].join("\n");
		}
		GmlExtMacro.cppAutogen.add(cppFileCodeStr);
		cppFileCodeStr = "#include <gml_ext.h>\n" + cppFileCodeStr;
		var cppFileCodeMeta = localClass.meta.extract(":cppFileCode")[0];
		if (cppFileCodeMeta != null) {
			if (cppFileCodeMeta.params != null) {
				switch (cppFileCodeMeta.params[0]) {
					case null:
					case { expr: EConst(CString(_code)) }:
						cppFileCodeStr = _code + "\n" + cppFileCodeStr;
					default:
				}
			}
			localClass.meta.remove(":cppFileCode");
		}
		localClass.meta.add(":cppFileCode", [macro $v{cppFileCodeStr}], localClass.pos);
		
		return fields;
	}
	public static function macroMain() {
		var name = Context.definedValue("HAXE_OUTPUT_FILE");
		if (name == null) {
			name = Context.definedValue("autogen_main");
			if (name == null) name = "Main";
		}
		CppGen.config.helperPrefix = name;
		
		isFirstClass = true;
		initFunc = Context.definedValue("autogen_init");
		if (initFunc == null) {
			initFunc = name + "_init_raw";
		}
		
		gmlAutogen = new CppBuf();
		cppAutogen = new CppBuf();
		cppAutogen.add("#include <gml_ext.h>\n");
		var gmlAutogenPath = Context.definedValue("autogen_gml");
		var cppAutogenPath = Context.definedValue("autogen_cpp");
		Context.onAfterGenerate(function() {
			if (Sys.systemName() == "Windows") {
				var dllPath = Compiler.getOutput() + "\\" + name;
				#if debug
				dllPath += "-debug";
				#end
				dllPath += ".dll";
				
				var projectDir = Sys.getCwd();
				projectDir = StringTools.replace(projectDir, "/", "\\");
				
				var arch = "x86";
				#if HXCPP_M64
				arch = "x64";
				#end
				
				var config = "Release";
				#if debug
				config = "Debug";
				#end
				
				Sys.command("cmd", [
					"/C", "postBuild.bat",
					dllPath,
					projectDir + "..\\",
					projectDir,
					arch,
					config,
				]);
			}
			File.saveContent(gmlAutogenPath, gmlAutogen.toString());
			File.saveContent(cppAutogenPath, cppAutogen.toString());
		});
		//trace("hi!", autogenPath);
	}
}