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
	
	public function new() {
		
	}
	
	public function handleArgs(args:Array<String>){
		var i = 0;
		while (i < args.length) {
			var remove = switch (args[i]) {
				case "--prefix": helperPrefix = args[i + 1]; 2;
				case "--function-tag": functionTag = args[i + 1]; 2;
				case "--function-tagm": functionTagM = args[i + 1]; 2;
				case "--export-tag": exportPrefix = args[i + 1]; 2;
				case "--export-tagm": exportPrefixM = args[i + 1]; 2;
				case "--prepend": prepend.push(args[i + 1]); 2;
				case "--append": append.push(args[i + 1]); 2;
				case "--include": includes.push(args[i + 1]); 2;
				//
				case "--struct": structMode = args[i + 1]; 2;
				case "--prefer-ds": preferDS = true; 1;
				case "--window-handle": gmlWindowHandle = args[i + 1]; 2;
				//
				case "--gml": CppGen.outGmlPath = args[i + 1]; 2;
				case "--gml-extras": CppGen.outGmlExtrasPath = args[i + 1]; 2;
				case "--cpp": CppGen.outCppPath = args[i + 1]; 2;
				case "--wasm": useWASM = true; 1;
				case "--gmk": CppGen.outGmkPath = args[i + 1]; 2;
				#if sys
				case "--index": CppGen.procArg(args[i + 1], false); 2;
				#end
				default: 0;
			}
			if (remove > 0) {
				args.splice(i, remove);
			} else i += 1;
		}
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