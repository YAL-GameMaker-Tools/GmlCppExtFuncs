package proc;

import struct.GmlStructIO;
import tools.CppBuf;

class CppTypeProcGmlInOutVector extends CppTypeProcVector {
	static function unpack(type:CppType) {
		var t = type.params[0];
		return {
			type: t,
			proc: t.proc,
			sp: (t.proc is CppTypeProcStruct) ? (cast t.proc : CppTypeProcStruct) : null,
		};
	}
	override function gmlWrite_item(gml:CppBuf, type:CppType, z:Int, v_arr:String, v_ind:String) {
		var inf = unpack(type);
		if (inf.sp == null) {
			super.gmlWrite_item(gml, type, z, v_arr, v_ind);
			return;
		}
		var v_item = '_val_$z';
		
		gml.addFormat("%|%vdp = ", v_item);
		switch (CppGen.config.vectorMode) {
			case VmArray:
				gml.addFormat("%s[%s]", v_arr, v_ind);
			case VmList:
				gml.addFormat("ds_list_find_value(%s, %s)", v_arr, v_ind);
		}
		gml.addFormat(";");
		
		gml.addFormat("%|if (");
		switch (CppGen.config.storageMode) {
			case SmStruct:
				gml.addFormat("%s != undefined && variable_struct_names_count(%0) != 0", v_item);
			case SmArray:
				gml.addFormat("%s != undefined && array_length_1d(%0) != 0", v_item);
			case SmMap, SmList:
				if (!CppGen.config.isGMK) {
					gml.addFormat("%s != undefined && ", v_item);
				}
				gml.addFormat("%s != -1", v_item);
		}
		gml.addFormat(") %{");
			gml.addFormat("%|buffer_write(_buf, buffer_bool, true);");
			GmlStructIO.writeFields(inf.sp.struct, gml, z + 1, v_item);
		gml.addFormat("%-} else buffer_write(_buf, buffer_bool, false);");
	}
	override function gmlReadOut(gml:CppBuf, type:CppType, depth:Int, out:String) {
		var vp_arr = '_arr_$depth';
		var vp_ind = '_ind_$depth';
		var vp_len = '_len_$depth';
		var vp_item = '_val_$depth';
		var inf = unpack(type);
		var isGMK = CppGen.config.isGMK;
		gml.addFormat("%|%vdp = %s;", vp_arr, out);
		gml.addFormat("%|%vdp = buffer_read(_buf, buffer_u32);", vp_len);
		var isArray = switch (CppGen.config.vectorMode) {
			case VmArray: true;
			case VmList: false;
		}
		var storageMode = CppGen.config.storageMode;
		if (isArray) {
			if (storageMode == SmStruct) {
				gml.addFormat("%|if (array_length(%s) != %s) array_resize(%0, %1);", vp_arr, vp_len);
			} else {
				gml.addFormat("%|var %s = array_length_1d(%s);", vp_ind, vp_arr);
				gml.addFormat("%|if (%s >= %s) %{", vp_ind, vp_len);
					gml.addFormat("%|while (--%s >= %s) %s[%0] = undefined;", vp_ind, vp_len, vp_arr);
				gml.addFormat("%-} else %s[@%s - 1] = 0;", vp_arr, vp_len);
			}
		} else {
			gml.addFormat("%|var %s = ds_list_size(%s);", vp_ind, vp_arr);
			gml.addFormat("%|if (%s > %s) %{", vp_ind, vp_len);
				gml.addFormat("%|while (--%s >= %s) ds_list_delete(%s, %0);", vp_ind, vp_len, vp_arr);
			var defValue = isGMK ? "0" : "undefined";
			gml.addFormat("%-} else repeat (%s - %s) ds_list_add(%s, %s);", vp_len, vp_ind, vp_arr, defValue);
		}
		//
		gml.addFormat("%|for (var %s = 0; %0 < %s; %0 += 1) %{", vp_ind, vp_len);
		if (inf.sp != null) {
			if (isArray) {
				gml.addFormat("%|%vdp = %s[%s];", vp_item, vp_arr, vp_ind);
			} else {
				gml.addFormat("%|%vdp = ds_list_find_value(%s, %s);", vp_item, vp_arr, vp_ind);
			}
			var struct = inf.sp.struct;
			switch (storageMode) {
				case SmStruct, SmArray:
					gml.addFormat("%|if (%s == undefined) %{", vp_item);
					gml.addFormat("%|%s = %s;", vp_item, storageMode == SmStruct ? "{}" : "[]");
					gml.addFormat("%|%s[@%s] = %s;", vp_arr, vp_ind, vp_item);
					gml.addFormat("%-}");
				case SmMap, SmList:
					//
					inline function fillList() {
						gml.addFormat("%|repeat (%d) ", struct.fields.length);
						gml.addFormat("ds_list_add(%s, %s);", vp_item, isGMK ? "0" : "undefined");
					}
					
					gml.addFormat("%|if (");
					if (!isGMK) gml.addFormat("%s == undefined || ", vp_item);
					gml.addFormat("%s == -1) %{", vp_item);
					
					// create
					if (storageMode == SmList) {
						gml.addFormat("%|%s = ds_list_create();", vp_item);
						fillList();
					} else gml.addFormat("%|%s = ds_map_create();", vp_item);
					
					// store
					if (isArray) {
						gml.addFormat("%|%s[@%s] = %s;", vp_arr, vp_ind, vp_item);
					} else {
						gml.addFormat("%|ds_list_replace(%s, %s, %s);", vp_arr, vp_ind, vp_item);
					}
					
					gml.addFormat("%-} else %{");
					// clear
					if (storageMode == SmList) {
						gml.addFormat("%|ds_list_clear(%s);", vp_item);
						fillList();
					} else gml.addFormat("%|ds_map_clear(%s);", vp_item);
					gml.addFormat("%-}");
			}
			GmlStructIO.readFields(inf.sp.struct, gml, depth + 1, vp_item, true);
		} else {
			if (isArray) {
				inf.type.gmlReadOut(gml, depth + 1, '$vp_arr[@$vp_ind]');
			} else if (!isGMK) {
				inf.type.gmlReadOut(gml, depth + 1, '$vp_arr[|$vp_ind]');
			} else {
				gml.addFormat("%|var %s;", vp_item);
				inf.type.gmlReadOut(gml, depth + 1, vp_item);
				gml.addFormat("%|ds_list_replace(%s, %s, %s);", vp_arr, vp_ind, vp_item);
			}
		}
		gml.addFormat("%-}");
		//super.gmlReadOut(gml, type, depth, out);
	}
	override function cppDynSize_extraPerItem(type:CppType):Int {
		if (type.proc is CppTypeProcStruct) return 1;
		return 0;
	}
	override function usesStructs(type:CppType):Bool {
		return true;
	}
	override function isOut():Bool {
		return true;
	}
	override function isList(type:CppType):Bool {
		return CppGen.config.vectorMode == VmList;
	}
}