package proc;
import tools.CppBuf;

/**
 * Converts between a C++/GML dynamic-length arrays
 * @author YellowAfterlife
 */
class CppTypeProcVector extends CppTypeProc {
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var _arr = '_arr_$z';
		var _ind = '_ind_$z';
		var _len = '_len_$z';
		var isGMK = CppGen.config.isGMK;
		gml.addFormat("var %s = buffer_read(_buf, buffer_u32);", _len);
		if (isGMK) {
			gml.addFormat("%|%vdp = ds_list_create();", _arr);
		} else {
			gml.addFormat("%|%vdp = array_create(%s);", _arr, _len);
		}
		gml.addFormat("%|for (%vdb; %s < %s; %s += 1) %{", _ind,"0", _ind,_len, _ind);
		var vect = type.params[0];
		var val = vect.proc.gmlRead(gml, vect, z +1);
		if (isGMK) {
			gml.addFormat("%|ds_list_add(%s, %s);", _arr, val);
		} else {
			gml.addFormat("%|%s[%s] = %s;", _arr, _ind, val);
		}
		gml.addFormat("%-}%|");
		return _arr;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var _arr = '_arr_$z';
		var _ind = '_ind_$z';
		var _len = '_len_$z';
		var isGMK = CppGen.config.isGMK;
		gml.addFormat("%|%vdp = %s;", _arr, val);
		gml.addFormat("%|%vdp = %s(%s);", _len,
			isGMK ? "ds_list_size" : "array_length_1d", _arr
		);
		gml.addFormat('%|%bw;', 'u32', _len);
		gml.addFormat("%|for (%vdb; %s < %s; %s += 1) %{", _ind,"0", _ind,_len, _ind);
		var vect = type.params[0];
		if (isGMK) {
			vect.proc.gmlWrite(gml, vect, z + 1, 'ds_list_find_value($_arr, $_ind)');
		} else {
			vect.proc.gmlWrite(gml, vect, z + 1, '$_arr[$_ind]');
		}
		gml.addFormat("%-}");
	}
	override public function cppRead(cpp:CppBuf, type:CppType, vp:String):String {
		var _len = vp + '_n';
		var _ind = vp + '_i';
		var _item = vp + '_v';
		cpp.addFormat('%|auto %s = _in.read<uint32_t>();', _len);
		cpp.addFormat('%|%s %s(%s);', type.toCppType(), vp, _len);
		cpp.addFormat('%|for (auto %s = 0u; %s < %s; %s++) %{', _ind, _ind,_len, _ind);
			var itemType = type.unpackVector();
			cpp.addFormat('%|%s[%s] = %s;', vp, _ind, itemType.proc.cppRead(cpp, itemType, _item));
		cpp.addFormat('%-}');
		return vp;
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, vp:String, val:String):Void {
		var vp_len = vp + '_n';
		var vp_ind = vp + '_i';
		var vp_item = vp + '_v';
		cpp.addFormat('%|auto& %s = %s;', vp, val);
		cpp.addFormat('%|auto %s = %s.size();', vp_len, vp);
		cpp.addFormat('%|_out.write<uint32_t>((uint32_t)%s);', vp_len);
		cpp.addFormat('%|for (auto %s = 0u; %0 < %s; %0++) %{', vp_ind, vp_len);
			var itemType = type.unpackVector();
			itemType.proc.cppWrite(cpp, itemType, vp_item, vp + '[$vp_ind]');
		cpp.addFormat('%-}');
	}
	override public function getGmlDocType(type:CppType):String {
		var t = type.params[0];
		if (t == null) return "array<any>";
		var inner = t.proc.getGmlDocTypeEx(t);
		if (inner == null) inner = "any";
		return "array<" + inner + ">";
	}
	override public function usesStructs(type:CppType):Bool {
		var t = type.params[0];
		return t.proc.usesStructs(t);
	}
	override public function usesGmkSpec(type:CppType):Bool {
		var t = type.params[0];
		return t.proc.usesGmkSpec(t);
	}
	override public function getDynSize(type:CppType, val:String):String {
		var param = type.unpackVector().toCppType();
		return '4 + $val.size() * sizeof($param)';
	}
}
class CppTypeProcTinyArray extends CppTypeProcVector {
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		return '#error Use tiny_const_array for function inputs';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String):Void {
		var ts = type.unpackVector().toCppType();
		cpp.addFormat('%|_out.write_tiny_array<$ts>($val);');
	}
}
class CppTypeProcTinyConstArray extends CppTypeProcVector {
	override public function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		var ts = type.unpackVector().toCppType();
		return '_in.read_tiny_const_array<$ts>()';
	}
	override public function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String):Void {
		var ts = type.unpackVector().toCppType();
		cpp.addFormat('%|_out.write_tiny_const_array<$ts>($val);');
	}
}