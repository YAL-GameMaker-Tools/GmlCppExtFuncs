package proc;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProc {
	public function new() {
		
	}
	
	/**
		Should return a snip of GML code to read a value (that was written by C++) from `_buf`.
		
		GML code can be appended into `gml` if additional logic is necessary.
		
		When doing so, each line should be followed by a linebreak (or addFormat("...%|"))
		
		@param	gml    (code buffer)
		@param	type   Value type
		@param	depth  (for generating non-conflicting local variable names)
		@return	GML code for use as a final value
	**/
	public function gmlRead(gml:CppBuf, type:CppType, depth:Int):String {
		throw "todo";
	}
	
	/**
	 * Should append GML code to write a value for use by C++ to `_buf`.
	 * @param	gml    (code buffer)
	 * @param	type   Value type
	 * @param	depth  (for generating non-conflicting local variable names)
	 * @param	val    Value as a GML expression string
	 */
	public function gmlWrite(gml:CppBuf, type:CppType, depth:Int, val:String):Void {
		throw "todo";
	}
	
	public function gmlCleanup(gml:CppBuf, type:CppType, depth:Int, val:String):Void {
		
	}
	
	/**
	 * Should append C++ code to read a value written by GML from `_in`.
	 * @param	cpp   (code buffer)
	 * @param	type  Value type
	 * @return	C++ code to use as a final value
	 */
	public function cppRead(cpp:CppBuf, type:CppType):String {
		var ts = type.toCppType();
		return '_in.read<$ts>()';
	}
	
	/**
	 * Should append C++ code to write a value for use by GML to `_out`.
	 * @param	cpp   (code buffer)
	 * @param	type  Value type
	 * @param	val   Value as a C++ expression string
	 */
	public function cppWrite(cpp:CppBuf, type:CppType, val:String):Void {
		cpp.addFormat('%|_out.write<%s>(%s);', type.toCppType(), val);
	}
	
	/**
	 * Should return the size of a value for the given type(+parameters).
	 * This is used to ensure that a GML buffer is large enough for function arguments/return value
	 * to be written to it without going out-of-bounds.
	 * 
	 * Vectors are an exception from this behaviour due to their size depending on value.
	 * @param	type
	 * @return
	 */
	public function getSize(type:CppType):Int {
		return 8;
	}
	
	/**
	 * Can return a snippet of code 
	 */
	public function getDynSize(type:CppType, val:String):String {
		return null;
	}
	
	public function getAlignment(type:CppType):Int {
		return getSize(type);
	}
	public function getGmlDocType(type:CppType):String {
		return null;
	}
	public function getGmlDocTypeEx(type:CppType):String {
		var t = CppType.docNames[type.docKey];
		if (t == null) t = CppType.docNames[type.docKeyFull];
		return t != null ? t : getGmlDocType(type);
	}
	
	/** Does this use structs? (and might need a conditional block) */
	public function usesStructs(type:CppType):Bool {
		return false;
	}
	
	/** Does this use GM<=8.1 logic? (and might need another conditional block) */
	public function usesGmkSpec(type:CppType):Bool {
		return false;
	}
	
	/**
	 * Some things (such as GameHwnd) are passed to C++, but are not passed to the GML wrapper.
	 */
	public function useGmlArgument():Bool {
		return true;
	}
}