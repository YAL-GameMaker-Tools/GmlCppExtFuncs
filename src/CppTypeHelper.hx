package ;
import proc.*;
import proc.CppTypeProcSimple;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeHelper {
	static var map:Map<String, CppTypeProc> = (function() {
		inline function simple(name:String, docName:String, size:Int) {
			return new CppTypeProcSimple(name, docName, size);
		}
		var bool = simple("buffer_bool", "bool", 1);
		var s8 = new CppTypeProcSimpleChar("buffer_s8", "int", 1);
		var u8 = simple("buffer_u8", "int", 1);
		var s16 = simple("buffer_s16", "int", 2);
		var u16 = simple("buffer_u16", "int", 2);
		var s32 = simple("buffer_s32", "int", 4);
		var u32 = simple("buffer_u32", "int", 4);
		var s64 = simple("buffer_u64", "int", 8);
		var u64 = simple("buffer_u64", "int", 8);
		var f32 = simple("buffer_f32", "number", 4);
		var f64 = simple("buffer_f64", "number", 8);
		var str = new CppTypeProcString();
		var gmlPtr = new CppTypeProcGmlPointer(false);
		var gmlID = new CppTypeProcGmlPointer(true);
		
		return [
			// 1-byte:
			"bool" => (bool:CppTypeProc),
			"char" => s8, "unsigned char" => u8,
			"int8" => s8, "int8_t" => s8,
			"uint8" => u8, "uint8_t" => u8,
			// 2-byte:
			"short" => s16, "unsigned short" => u16,
			"int16" => s16, "int16_t" => s16,
			"uint16" => u16, "uint16_t" => u16,
			// 4-byte:
			"int" => s32, "unsigned int" => u32,
			"int32" => s32, "int32_t" => s32,
			"uint32" => u32, "uint32_t" => u32,
			// 8-byte:
			"long long" => s64,
			"int64" => s64, "int64_t" => s64,
			"uint64" => u64, "uint64_t" => u64,
			// floating-point:
			"float" => f32, "double" => f64,
			// special cases:
			"char*" => str,
			"gml_ptr" => gmlPtr,
			"gml_ptr_destroy" => gmlPtr,
			"gml_id" => gmlID,
			"gml_id_destroy" => gmlID,
			"vector" => new CppTypeProcVector(),
			"tuple" => new CppTypeProcTuple(),
			"optional" => new CppTypeProcOptional(),
			"gml_buffer" => new CppTypeProcGmlBuffer(),
			"GAME_HWND" => new CppTypeProcGameHwnd(),
			"gml_asset_index_of" => new CppTypeProcAssetIndexOf(),
			"vector<char*>" => new CppTypeProcStringVector(),
		];
	})();
	
	public static function find(t:CppType):CppTypeProc {
		var tp = map[t.toKey()];
		if (tp != null) return tp;
		tp = map[t.name];
		if (tp != null) return tp;
		Sys.println('Couldn\'t find type ${t.toString()}'
			//+ haxe.CallStack.toString(haxe.CallStack.callStack())
		);
		return new CppTypeProcError(t.toString());
	}
}