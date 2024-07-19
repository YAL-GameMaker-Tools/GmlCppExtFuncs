package struct;

import proc.CppTypeProc;
import tools.CppBuf;

class GmlStructIO {
	public static function createTail(struct:CppStruct, gml:CppBuf) {
		switch (CppGen.config.storageMode) {
			case SmStruct:
				gml.addFormat("{}; // %s", struct.name);
			case SmArray:
				gml.addFormat("array_create(%d); // %s", struct.fields.length, struct.name);
			case SmMap:
				gml.addFormat("ds_map_create(); // %s", struct.name);
			case SmList:
				gml.addFormat("ds_list_create(); // %s", struct.name);
		}
	}
	
	public static function readFields(struct:CppStruct, gml:CppBuf, z:Int, structVar:String, isOut:Bool) {
		var mode = CppGen.config.storageMode;
		var useArrays = mode == SmStruct || mode == SmArray;
		var acc = isOut ? "@" : "";
		
		// this gets called recursively to handle reading fixed-size arrays like `type field[d1][d2]`
		function proc(gml:CppBuf, type:CppType, tp:CppTypeProc, z:Int, size:Array<Int>, size_ind:Int) {
			if (size_ind >= size.length) {
				return tp.gmlRead(gml, type, z + 1);
			}
			if (size_ind == size.length - 1 && type.name == "char") {
				// the last char[n] segment becomes a string
				var fn = CppGen.config.helperPrefix + "_read_chars";
				return '$fn(_buf, ${size[size_ind]})';
			}
			var _arr = '_arr_$z';
			var _ind = '_ind_$z';
			var _len = size[size_ind];
			
			// declaration:
			gml.addFormat("%|%vdp = ", _arr);
			if (useArrays) {
				gml.addFormat("array_create(%d);", _len);
			} else {
				gml.addFormat("ds_list_create();");
			}
			
			// array itself
			gml.addFormat('%|for (%vdb; %0 < %d; %0 += 1) %{', _ind, "0", _len);
				var val = proc(gml, type, tp, z + 1, size, size_ind + 1);
				if (useArrays) {
					gml.addFormat("%s[%s%s] = %s;", _arr, acc, _ind, val);
				} else {
					gml.addFormat("ds_list_add(%s, %s", _arr, val);
				}
			gml.addFormat("%-}");
			
			return _arr;
		} // proc
		
		for (i => fd in struct.fields) {
			var tp = fd.type.proc;
			var val = proc(gml, fd.type, tp, z + 1, fd.size, 0);
			switch (mode) {
				case SmStruct:
					gml.addFormat("%|%s.%s = %s;", structVar, fd.name, val);
				case SmArray:
					gml.addFormat("%|%s[%s%d] = %s; // %s", structVar, acc, i, val, fd.name);
				case SmMap:
					gml.addFormat('%|ds_map_add(%s, "%s", %s);', structVar, fd.name, val);
				case SmList:
					gml.addFormat('%|ds_list_add(%s, %s); // %s', structVar, val, fd.name);
			}
		}
	}
	
	public static function writeFields(struct:CppStruct, gml:CppBuf, z:Int, structVar:String) {
		var mode = CppGen.config.storageMode;
		var useArrays = mode == SmStruct || mode == SmArray;
		
		function proc(gml:CppBuf, type:CppType, tp:CppTypeProc, z:Int, size:Array<Int>, size_ind:Int, val:String) {
			if (size_ind >= size.length) {
				tp.gmlWrite(gml, type, z + 1, val);
				return;
			}
			if (size_ind == size.length - 1 && type.name == "char") {
				// same char[n] -> string conversion
				var fn = CppGen.config.helperPrefix + "_write_chars";
				gml.addFormat('%|%s(_buf, %s, %d)', fn, val, size[size_ind]);
				return;
			}
			var _arr = '_arr_$z';
			var _ind = '_ind_$z';
			var _len = size[size_ind];
			gml.addFormat("%|%vdp = %s;", _arr, val);
			gml.addFormat('%|for (%vdb; %0 < %d; %0 += 1) %{', _ind, 0, _len);
				var val = useArrays ? '$_arr[$_ind]' : 'ds_list_find_value($_arr, $_ind)';
				proc(gml, type, tp, z + 1, size, size_ind + 1, val);
			gml.addFormat("%-}");
		} // proc
		
		for (i => fd in struct.fields) {
			var note = false;
			var val = structVar;
			switch (mode) {
				case SmStruct:
					val += "." + fd.name;
				case SmArray:
					note = true;
					val += '[$i]';
				case SmMap:
					val = 'ds_map_find_value($val, "${fd.name}")';
				case SmList:
					note = true;
					val = 'ds_list_find_value($val, ${i})';
			}
			
			proc(gml, fd.type, fd.type.proc, z + 1, fd.size, 0, val);
			if (note) gml.addFormat(" // %s", fd.name);
		}
	}
}