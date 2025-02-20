package ;

/**
 * ...
 * @author YellowAfterlife
 */
class CppConfig {
	public var helperPrefix:String = "ext";
	public var includes:Array<String> = ["gml_ext.h"];
	public var prepend:Array<String> = [];
	public var append:Array<String> = [];
	public var cppName = "$_raw";
	public var cppNameMangled = "$_yyr";
	public var cppPost = "$_raw_post";
	public var cppVector = "$_raw_vec";
	public var cppStore = "$1_raw_store_$2";
	public var exportPrefix = "dllx";
	public var exportPrefixM = "dllm";
	public var functionTag = "dllg";
	public var functionTagM = "dllgm";
	//
	
	/** Controls how vectors are represented on GML side */
	public var vectorMode:GmlVectorMode = GmlVectorMode.VmArray;
	
	/** Controls how structs are represented on GML side */
	public var storageMode:GmlStorageMode = GmlStorageMode.SmStruct;
	
	/** Controls how gml_id/gml_ptr are represented on GML side */
	public var boxMode:GmlBoxMode = GmlBoxMode.BmStruct;
	
	/** Whether currently generating code for GM8.1 */
	public var isGMK = false;
	
	public var gmlWindowHandle = "window_handle()";
	
	/** Prefer ds_map/ds_list over arrays for GM:S/GMS2.2 */
	public var preferDS = false;
	//
	public var structMode = "0";
	public var structModeVal(get, never):Null<Bool>;
	public var useWASM:Bool = false;
	private function get_structModeVal():Null<Bool> {
		return switch (structMode) {
			case "1", "true": true;
			case "0", "false": false;
			default: null;
		}
	}
	
	//
	public var argList:Array<CppConfigHelpItem> = [];
	public var argMap:Map<String, CppConfigArgBase> = new Map();
	function addArgImpl(arg:CppConfigArgBase) {
		argList.push(arg);
		argMap[arg.name] = arg;
		return arg;
	}
	inline function addArgSection(name) {
		argList.push(new CppConfigHeader(name));
	}
	inline function addArg(name, func, help) {
		return addArgImpl(new CppConfigArg(name, help, func));
	}
	inline function addArg1(name, func, help, ?param) {
		return addArgImpl(new CppConfigArg1(name, help, func, param));
	}
	
	public function new() {
		addArg("--help", () -> showHelp(false), [
			"Shows argument help"
		]);
		addArg("--help-md", () -> showHelp(true), [
			"Shows argument help, in Markdown"
		]);
		
		addArgSection("Inputs");
		var pathArg = new CppConfigArgBase(null, [
			"A relative or absolute path to a C/C++ file to scan.  ",
			"You can specify multiple of these!  ",
			"File name may contain `*` for simple wildcard matches (`test/lib_*.cpp`).",
		]);
		pathArg.params = ["<path>"];
		argList.push(pathArg);
		addArg1("--index", s -> CppGen.procArg(s, false), [
			"Scans the file for typedefs/usings, but will not mirror structs from it.",
		], "path");
		
		addArgSection("Outputs");
		addArg1("--cpp", s -> CppGen.outCppPath = s, [
			"A path to a file where auto-generated C++ functions will be.  ",
			"Usually this is a file in your C++ project."
		], "path");
		addArg1("--gml", s -> CppGen.outGmlPath = s, [
			"A path to a file where auto-generated GML functions will be.  ",
			"Usually this is a file in your GM extension."
		], "path");
		addArg1("--gml-constructors", s -> CppGen.outGmlExtrasPath = s, [
			"If you are using constructor+method comment tags,",
			"this is where the generated GML constructor functions will reside."
		], "path");
		
		addArgSection("Functions and tags");
		addArg1("--prefix", s -> helperPrefix = s, [
			'Sets the prefix for GML helper functions (default: $helperPrefix)'
		], "snip");
		addArg1("--function-tag", s -> functionTag = s, [
			'Changes the macro-tag for unmangled functions (default: $functionTag)  ',
			'The tool will only generate wrappers for functions prepended with this tag.',
		], "tag");
		addArg1("--function-tag-m", s -> functionTagM = s, [
			'Changes the macro-tag for mangled/YYRunnerInterface functions (default: $functionTagM)'
		], "tag");
		addArg1("--export-tag", s -> exportPrefix = s, [
			'Changes the tag/macro for generated unmangled functions (default: $exportPrefix)',
		], "tag");
		addArg1("--export-tag-m", s -> exportPrefixM = s, [
			'Changes the tag/macro for generated mangled functions (default: $exportPrefixM)',
		], "tag");
		
		addArgSection("C++ file");
		addArg1("--prepend", s -> prepend.push(s), [
			"Adds a line of code at the beginning of the auto-generated C++ file."
		], "line");
		addArg1("--append", s -> append.push(s), [
			"Adds a line of code at the end of the auto-generated C++ file."
		], "line");
		addArg1("--include", s -> includes.push(s), [
			'Adds an `#include "<path>"` to the auto-generated C++ file.'
		], "path");
		
		addArgSection("Esoteric");
		addArg1("--struct", s -> structMode = s, [
			"Changes how C++ structs are converted to/from GML:",
			"- 1: always uses GML structs for C++ structs",
			"- 0: always uses arrays for C++ structs",
			"- auto: generates GmxGen-specific wrapper, like:  ",
			"  ```gml",
			"  // GMS >= 2.3",
			"  struct-based code",
			"  /*/",
			"  array-based code",
			"  //*/",
			"  ```",
			"- Other values: uses the value as a condition, like:  ",
			"  ```gml",
			"  // GMS >= 2.3",
			"  if (value) {",
			"  	struct-based code",
			"  } else //*/",
			"  {",
			"  	array-based code",
			"  }",
			"  ```",
		]);
		addArg("--prefer-ds", () -> preferDS = true, [
			"Prefer ds_maps and ds_lists over arrays in GM versions without structs."
		]);
		addArg("--wasm", () -> useWASM = true, [
			"Enables WebAssembly-specific tweaks to code generation."
		]);
		addArg1("--gmk", s -> CppGen.outGmkPath = s, [
			"A path to a file where GM8.1 scripts will be.  ",
			"These will follow 8.1 constraints (such as using lists instead of arrays)",
			"and will generate additional code to make up for lacking API."
		], "path");
	}
	public function showHelp(md) {
		var lines = ["The following command-line arguments are supported:"];
		for (arg in argList) if (arg.visible) {
			arg.showHelp(lines, md);
		}
		#if sys
		for (line in lines) Sys.println(line);
		Sys.exit(0);
		#else
		for (line in lines) trace(line);
		#end
	}
	
	public function handleArgs(args:Array<String>){
		var i = 0;
		while (i < args.length) {
			var handler = argMap[args[i]];
			var remove:Int;
			if (handler != null) {
				remove = handler.apply(args, i);
			} else remove = 0;
			if (remove > 0) {
				args.splice(i, remove);
			} else i += 1;
		}
	}
}
class CppConfigHelpItem {
	public var visible = true;
	public function showHelp(out:Array<String>, md:Bool) {
		//
	}
	function addNotes(out:Array<String>, notes:Array<String>, md) {
		for (line in notes) {
			var str = line;
			if (!md && StringTools.endsWith(str, "  ")) {
				str = str.substring(0, str.length - 2);
			}
			if (!md) str = "    " + str;
			out.push(str);
		}
	}
}
class CppConfigHeader extends CppConfigHelpItem {
	public var name:String;
	public var extras:Array<String>;
	public function new(name:String, ?extras) {
		this.name = name;
		this.extras = extras ?? [];
	}
	override function showHelp(out:Array<String>, md:Bool) {
		if (md) out.push("");
		out.push(md ? '# $name' : '$name:');
		addNotes(out, extras, md);
	}
}
class CppConfigArgBase extends CppConfigHelpItem {
	public var name:String;
	public var help:Array<String>;
	public var params:Array<String> = [];
	public function new(name, help) {
		this.name = name;
		this.help = help;
	}
	public function apply(args:Array<String>, at:Int):Int {
		return 1;
	}
	override function showHelp(out:Array<String>, md:Bool) {
		if (md) out.push("");
		var vp = (name != null ? [name] : []).concat(params);
		var vps = vp.join(" ");
		if (md) vps = StringTools.htmlEscape(vps);
		out.push((md ? "## " : "") + vps);
		addNotes(out, help, md);
	}
}
class CppConfigArg extends CppConfigArgBase {
	public var func:()->Void;
	public function new(name, help, fn) {
		super(name, help);
		func = fn;
	}
	override function apply(args:Array<String>, at:Int):Int {
		func();
		return 1;
	}
}
class CppConfigArg1 extends CppConfigArgBase {
	public var func:(arg:String)->Void;
	public function new(name, help, fn, param) {
		super(name, help);
		params.push("<" + (param ?? "value") + ">");
		func = fn;
	}
	override function apply(args:Array<String>, at:Int):Int {
		func(args[at + 1]);
		return 2;
	}
}
enum GmlStorageMode {
	/** GMS 2.3.x and GM2022+ */
	SmStruct;
	/** GM:S to GMS 2.2.x */
	SmArray;
	/** GM8.1 */
	SmMap;
	/** GM8.1 (if structMode is force-off) */
	SmList;
}
enum GmlVectorMode {
	/** GM:S and newer **/
	VmArray;
	/** GM8.1 **/
	VmList;
}
enum GmlBoxMode {
	/** GMS 2.3.x and GM2022+ */
	BmStruct;
	/** GM:S to GMS 2.2.x */
	BmArray;
	/** GM8.1 */
	BmGrid;
}