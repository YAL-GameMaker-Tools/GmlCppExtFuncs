package proc;
import func.CppFuncArg;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcGmlBuffer extends CppTypeProc {
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		return '_in.read_gml_buffer()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String):Void {
		cpp.addFormat("%|#error You may not return GML buffers at this time");
	}
	
	static var rxInOut:EReg = ~/^_*([iI]n_*)?([oO]ut)?[_A-Z]/i;
	function getArgUses() {
		var name = CppFuncArg.current.name;
		var _in = true, _out = false;
		if (rxInOut.match(name)) {
			_in = rxInOut.matched(1) != null;
			_out = rxInOut.matched(2) != null;
			if (_out == false) _in = true;
		}
		return { isInput: _in, isOutput: _out };
	}
	
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var v = '_val_$z';
		var wasm = CppGen.config.useWASM;
		var vwb = '_wb_$z';
		gml.addFormat("%|var %s = %s;", v, val);
		if (wasm) gml.addFormat("%|var %s;", vwb);
		gml.addFormat("%|if (buffer_exists(%s)) %{", v);
		if (wasm) {
			var pfx = CppGen.config.helperPrefix;
			var vlen = '_len_$z';
			gml.addFormat("%|if (%(s)_is_js) %{", pfx);
				gml.addFormat("%|var %s = buffer_get_size(%s);", vlen, v);
				gml.addFormat("%|%s = %(s)_wasm_alloc(%s", vwb, pfx, vlen);
				if (getArgUses().isInput) gml.addFormat(", buffer_get_address(%s)", v);
				gml.addString(");");
				gml.addFormat('%|%bw;', 'u64', vwb);
				gml.addFormat('%|%bw;', 's32', vlen);
				gml.addFormat('%|%bw;', 's32', 'buffer_tell($v)');
			gml.addFormat("%-} else %{");
		}
		
		// native:
		gml.addFormat('%|%bw;', 'u64', 'int64(buffer_get_address($v))');
		gml.addFormat('%|%bw;', 's32', 'buffer_get_size($v)');
		gml.addFormat('%|%bw;', 's32', 'buffer_tell($v)');
		if (wasm) gml.addFormat("%-}"); // closes if-js-else
		
		// no buffer:
		gml.addFormat("%-} else %{");
		if (wasm) gml.addFormat("%|%s = undefined;", vwb);
		gml.addFormat('%|%bw;', 'u64', '0');
		gml.addFormat('%|%bw;', 's32', '0');
		gml.addFormat('%|%bw;', 's32', '0');
		gml.addFormat("%-}");
	}
	override public function gmlCleanup(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		if (CppGen.config.useWASM) {
			var pfx = CppGen.config.helperPrefix;
			// todo: this wouldn't work right for vector of buffers/etc.
			gml.addFormat("%|if (%(s)_is_js) ", pfx);
			gml.addFormat("%(s)_wasm_free(%s", pfx, '_wb_$z');
			if (getArgUses().isOutput) {
				var v = '_val_$z';
				gml.addFormat(", buffer_get_address(%s), buffer_get_size(%s)", v, v);
			}
			gml.addString(");");
		}
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		return 'show_error("Unsupported type gml_buffer", true)';
	}
	override public function getGmlDocType(type:CppType):String {
		return "buffer";
	}
	override public function getSize(type:CppType):Int {
		return 16;
	}
}