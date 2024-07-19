package proc;
import tools.CppBuf;

/**
 * Converts between a C++/GML dynamic-length arrays
 * @author YellowAfterlife
 */
class CppTypeProcVector extends CppTypeProc {
	static function unpack(type:CppType) {
		return type.params[0];
	}
	function gmlWrite_item(gml:CppBuf, type:CppType, z:Int, v_arr:String, v_ind:String):Void {
		var vect = type.params[0];
		switch (CppGen.config.vectorMode) {
			case VmArray:
				vect.proc.gmlWrite(gml, vect, z + 1, '$v_arr[$v_ind]');
			case VmList:
				vect.proc.gmlWrite(gml, vect, z + 1, 'ds_list_find_value($v_arr, $v_ind)');
		}
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var v_arr = '_arr_$z';
		var v_ind = '_ind_$z';
		var v_len = '_len_$z';
		var isArray = switch (CppGen.config.vectorMode) {
			case VmArray: true;
			case VmList: false;
		}
		gml.addFormat("%|%vdp = %s;", v_arr, val);
		gml.addFormat("%|%vdp = %s(%s);", v_len, isArray ? "array_length_1d" : "ds_list_size", v_arr);
		gml.addFormat('%|%bw;', 'u32', v_len);
		gml.addFormat("%|for (%vdb; %0 < %s; %0 += 1) %{", v_ind, "0", v_len);
			gmlWrite_item(gml, type, z, v_arr, v_ind);
		gml.addFormat("%-}");
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var _arr = '_arr_$z';
		var _ind = '_ind_$z';
		var _len = '_len_$z';
		var isGMK = CppGen.config.isGMK;
		gml.addFormat("%|var %s = buffer_read(_buf, buffer_u32);", _len);
		if (isGMK) {
			gml.addFormat("%|%vdp = ds_list_create();", _arr);
		} else {
			gml.addFormat("%|%vdp = array_create(%s);", _arr, _len);
		}
		gml.addFormat("%|for (%vdb; %s < %s; %s += 1) %{", _ind,"0", _ind,_len, _ind);
		var vect = unpack(type);
		var val = vect.proc.gmlRead(gml, vect, z +1);
		if (isGMK) {
			gml.addFormat("%|ds_list_add(%s, %s);", _arr, val);
		} else {
			gml.addFormat("%|%s[%s] = %s;", _arr, _ind, val);
		}
		gml.addFormat("%-}%|");
		return _arr;
	}
	
	override public function cppRead(cpp:CppBuf, type:CppType, vp:String):String {
		var _len = vp + '_n';
		var _ind = vp + '_i';
		var _item = vp + '_v';
		cpp.addFormat('%|auto %s = _in.read<uint32_t>();', _len);
		var vt;
		if (type.name == "gml_inout_vector") {
			vt = "std::vector<" + type.params[0].toCppType() + ">";
		} else vt = type.toCppType();
		cpp.addFormat('%|%s %s(%s);', vt, vp, _len);
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
	
	override function seekRec(type:CppType, fn:CppType -> Bool):Bool {
		return fn(type.params[0]);
	}
	override function hasDynSize(type:CppType):Bool {
		return true;
	}
	function cppDynSize_extraPerItem(type:CppType):Int {
		return 0;
	}
	override function cppDynSize(cpp:CppBuf, type:CppType, vp:String, val:String, result:String):Int {
		var vp_len = vp + '_n';
		var vp_ind = vp + '_i';
		var vp_item = vp + '_v';
		
		var tmp = cpp.fork(1);
		var itemType = type.unpackVector();
		var itemSize = itemType.cppDynSize(tmp, vp_item, '$vp[$vp_ind]', result);
		if (tmp.hasText || itemSize > 0) {
			cpp.addFormat("%|auto& %s = %s;", vp, val);
			cpp.addFormat('%|auto %s = %s.size();', vp_len, vp);
		}
		if (tmp.hasText) {
			cpp.addFormat('%|for (auto %s = 0u; %0 < %s; %0++) %{', vp_ind, vp_len);
			cpp.addBuffer(tmp);
			cpp.addFormat('%-}');
		}
		itemSize += cppDynSize_extraPerItem(itemType);
		if (itemSize > 0) cpp.addFormat('%|%s += %d * %s;', result, itemSize, vp_len);
		return 4;
	}
	override function usesGmkSpec(type:CppType):Bool {
		return true;
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