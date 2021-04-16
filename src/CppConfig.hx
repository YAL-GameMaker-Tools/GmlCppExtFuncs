package ;

/**
 * ...
 * @author YellowAfterlife
 */
class CppConfig {
	public var helperPrefix:String = "ext_";
	public var includes:Array<String> = ["gml_ext.h"];
	public var prepend:Array<String> = [];
	public var append:Array<String> = [];
	public var cppName = "$_raw";
	public var cppPost = "$_raw_post";
	public var cppVector = "$_raw_vec";
	public var exportPrefix = "dllx";
	public var functionTag = "dllg";
	
	public function new() {
		
	}
	
}