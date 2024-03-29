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
	public var exportPrefix = "dllx";
	public var exportPrefixM = "dllm";
	public var functionTag = "dllg";
	public var functionTagM = "dllgm";
	public var useStructs = true;
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
	
}