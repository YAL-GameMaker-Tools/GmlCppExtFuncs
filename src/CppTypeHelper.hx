package ;
import proc.*;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeHelper {
	public static var map:Map<String, CppTypeProc> = (function() {
		inline function simple(name:String, docName:String, size:Int) {
			return new CppTypeProcSimple(name, docName, size);
		}
		var bool = simple("buffer_bool", "bool", 1);
		var s8 = simple("buffer_s8", "int", 1);
		var u8 = simple("buffer_u8", "int", 1);
		var s16 = simple("buffer_s16", "int", 2);
		var u16 = simple("buffer_u16", "int", 2);
		var s32 = simple("buffer_s32", "int", 4);
		var u32 = simple("buffer_u32", "int", 4);
		var s64 = simple("buffer_u64", "int", 8);
		var u64 = simple("buffer_u64", "int", 8);
		var f32 = simple("buffer_f32", "number", 4);
		var f64 = simple("buffer_f64", "number", 8);
		
		return [
			"bool" => (bool:CppTypeProc),
			"char" => s8, "unsigned char" => u8,
			"int8_t" => s8, "uint8_t" => u8,
			"short" => s16, "unsigned short" => u16,
			"int16_t" => s16, "uint16_t" => u16,
			"int" => s32, "unsigned int" => u32,
			"int32_t" => s32, "uint32_t" => u32,
			"long long" => s64, "int64" => s64,
			"int64_t" => s64, "uint64_t" => u64,
			"float" => f32, "double" => f64,
			"vector" => new CppTypeProcVector(),
			"gml_vector" => new CppTypeProcGmlVector(),
			"tuple" => new CppTypeProcTuple(),
		];
	})();
	
	public static function find(t:CppType):CppTypeProc {
		var tp = map[t.name];
		return tp;
	}
}