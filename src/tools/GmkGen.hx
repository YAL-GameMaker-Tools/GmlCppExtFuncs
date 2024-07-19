package tools;

import sys.io.File;

/**
	If you are targeting pre-Studio versions of GameMaker,
	additional functions will be added to C++ code and a heavily modified autogen.gml
	will be output to a separate file.
	@author YellowAfterlife
**/
class GmkGen {
	public static var usedHelpers:Map<String, Bool> = new Map();
	static var numberTypes:Array<GmkGenPair> = (function() {
		var result:Array<GmkGenPair> = [];
		function add(gmlType:String, cppType:String) {
			result.push({
				gmlType: gmlType,
				cppType: cppType,
			});
		}
		function addSize(size:Int) {
			add("u" + size, "uint" + size + "_t");
			add("s" + size, "int" + size + "_t");
		}
		add("bool", "bool");
		addSize(8);
		addSize(16);
		addSize(32);
		add("f32", "float");
		add("f64", "double");
		add("u64", "int64_t");
		return result;
	})();
	public static var argBuffer = "gmk_buffer_args";
	public static function run(gml:String, cpp:String) {
		var cppBuf = new CppBuf();
		var config = CppGen.config;
		var ep = config.exportPrefix;
		var hp = config.helperPrefix;
		gml = tools.GmlConditionalComments.proc(gml, 0.81, true);
		inline function addGMKI() {
			cppBuf.addFormat("/// #gmki%|");
		}
		//
		{
			var rxPrepare = new EReg("\\b" + hp + "_prepare_buffer" + "\\b"
			+ "\\(" + "(.*?)" + "\\)", "g");
			var fnPrepare = hp + "_gmkb_prepare";
			var found = false;
			gml = rxPrepare.map(gml, function(rx) {
				found = true;
				return "external_call(global.f_" + fnPrepare + ", " + rx.matched(1) + ")";
			});
			if (found) {
				addGMKI();
				cppBuf.addFormat("%s double %s(double _size) %{", ep, fnPrepare);
					cppBuf.addFormat("%|%s.prepare((int)_size);", argBuffer);
					cppBuf.addFormat("%|return 1;");
				cppBuf.addFormat("%-}%|");
			}
		}
		//
		{
			var rxRewind = new EReg("\\bbuffer_seek\\(_buf, buffer_seek_start, 0\\)", "g");
			var fnRewind = hp + "_gmkb_rewind";
			var found = false;
			gml = rxRewind.map(gml, rx -> {
				found = true;
				return "external_call(global.f_" + fnRewind + ")";
			});
			if (found) {
				addGMKI();
				cppBuf.addFormat("%s double %s() %{", ep, fnRewind);
					cppBuf.addFormat("%|%s.rewind();", argBuffer);
					cppBuf.addFormat("%|return 1;");
				cppBuf.addFormat("%-}%|");
			}
		};
		//
		var startedSection = false;
		inline function beginSection() {
			startedSection = false;
		}
		inline function ensureSection(name:String) {
			if (!startedSection) {
				startedSection = true;
				cppBuf.addFormat("// %s:%|", name);
			}
		}
		// number reads:
		beginSection();
		for (t in numberTypes) {
			var rxRead = new EReg("\\b" + "buffer_read" + "\\("
				+ "\\s*" + "_buf,"
				+ "\\s*" + "buffer_" + t.gmlType
			+ "\\)", "g");
			var fnRead = hp + "_gmkb_read_" + t.gmlType;
			
			var found = usedHelpers[fnRead];
			gml = rxRead.map(gml, function(rx) {
				found = true;
				return "external_call(global.f_" + fnRead + ")";
			});
			
			if (found) {
				ensureSection("reads");
				addGMKI();
				cppBuf.addFormat("%s double %s() {", ep, fnRead);
				cppBuf.addFormat("%+return (double)%s.read<%s>();", argBuffer, t.cppType);
				cppBuf.addFormat("%-}%|");
			}
		}
		// number writes:
		beginSection();
		if (true) { // ptr as u64 (but this is x86 so we're only using the lower 32 bits)
			var rxWrite = new EReg("\\b" + "buffer_write" + "\\("
				+ "\\s*" + "_buf,"
				+ "\\s*" + "buffer_ptr" + ","
				+ "\\s*" + "(.+?)" // -> arg
			+ "\\)", 'g');
			var fnWrite = hp + "_gmkb_write_ptr";
			
			var found = usedHelpers[fnWrite];
			gml = rxWrite.map(gml, function(rx) {
				found = true;
				return "external_call(global.f_" + fnWrite + ", " + rx.matched(1) + ")";
			});
			
			if (found) {
				ensureSection("writes");
				addGMKI();
				cppBuf.addFormat("%s double %s(double val) {%+", ep, fnWrite);
				cppBuf.addFormat("%s.write((int64_t)(int32_t)val);", argBuffer);
				cppBuf.addFormat("%|return 1;");
				cppBuf.addFormat("%-}%|");
			}
		}
		for (t in numberTypes) {
			var rxWrite = new EReg("\\b" + "buffer_write" + "\\("
				+ "\\s*" + "_buf,"
				+ "\\s*" + "buffer_" + t.gmlType + ","
				+ "\\s*" + "(.+?)" // -> arg
			+ "\\)", 'g');
			var fnWrite = hp + "_gmkb_write_" + t.gmlType;
			
			var found = usedHelpers[fnWrite];
			gml = rxWrite.map(gml, function(rx) {
				found = true;
				return "external_call(global.f_" + fnWrite + ", " + rx.matched(1) + ")";
			});
			
			if (found) {
				ensureSection("writes");
				addGMKI();
				cppBuf.addFormat("%s double %s(double val) {%+", ep, fnWrite);
				var isU64 = t.gmlType == "u64";
				if (isU64) {
					// oh no
					cppBuf.addFormat("#if defined(TINY) && (INTPTR_MAX == INT32_MAX)");
					cppBuf.addFormat("%|int64_t result;");
					cppBuf.addFormat("%|__asm {");
					cppBuf.addFormat("%+fld val");
					cppBuf.addFormat("%|fistp result");
					cppBuf.addFormat("%-}");
					cppBuf.addFormat("%|%s.write(result);", argBuffer);
					cppBuf.addFormat("%|#else%|");
				}
				cppBuf.addFormat("%s.write((%s)val);", argBuffer, t.cppType);
				if (isU64) cppBuf.addFormat("%|#endif");
				cppBuf.addFormat("%|return 1;");
				cppBuf.addFormat("%-}%|");
			}
		}
		//
		gml = new EReg(""
			+ "(\\w+_raw)"
			+ "\\("
			+ "buffer_get_address\\(_buf\\)"
		, "g").map(gml, function(rx) {
			return "external_call(global.f_" + rx.matched(1) + ', ""';
		});
		//
		gml = StringTools.replace(gml, "buffer_get_address(_buf)", '""');
		
		#if sys
		File.saveContent(CppGen.outGmkPath, gml);
		#else
		trace("gmk");
		trace(gml);
		#end
		
		if (cppBuf.length == 0) return cpp;
		return cpp + "// GM8.1 and earlier:\n" + cppBuf.toString();
	}
}
typedef GmkGenPair = {
	var gmlType:String;
	var cppType:String;
}