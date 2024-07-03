package proc;
import proc.CppTypeProc;
import struct.CppStruct;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcStruct extends CppTypeProc {
	public var struct:struct.CppStruct;
	public function new(struct:struct.CppStruct) {
		super();
		this.struct = struct;
	}
	static function calcPadding(pos:Int, align:Int):Int {
		var mod = pos % align;
		if (mod != 0) {
			return align - mod;
		} else return 0;
	}
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		var mode = CppGen.config.storageMode;
		function proc(gml:CppBuf, type:CppType, tp:CppTypeProc, z:Int, size:Array<Int>, size_ind:Int) {
			if (size_ind >= size.length) {
				return tp.gmlRead(gml, type, z + 1);
			}
			if (size_ind == size.length - 1 && type.name == "char") {
				var fn = CppGen.config.helperPrefix + "_read_chars";
				return '$fn(_buf, ${size[size_ind]})';
			}
			var _arr = '_arr_$z';
			var _ind = '_ind_$z';
			var _len = size[size_ind];
			var isGMK = CppGen.config.isGMK;
			gml.addFormat("%|%vdp = ", _arr);
			if (isGMK) {
				gml.addFormat("ds_list_create()");
			} else {
				gml.addFormat("array_create(%d);", _len);
			}
			gml.addFormat("%|for (%vdb; ", _ind, "0");
			gml.addFormat("%s < %d", _ind, "0", _ind, _len);
			gml.addFormat("; %s += 1) {%+", _ind);
			var val = proc(gml, type, tp, z + 1, size, size_ind + 1);
			if (isGMK) {
				gml.addFormat("ds_list_add(%s, %s", _arr, val);
			} else {
				gml.addFormat("%s[%s] = %s;", _arr, _ind, val);
			}
			gml.addFormat("%-}");
			return _arr;
		}
		gml.addFormat("%|%vdp = ", "_struct_" + z);
		switch (mode) {
			case SmStruct:
				gml.addFormat("{}; // %s", struct.name);
			case SmArray:
				gml.addFormat("array_create(%d); // %s", struct.fields.length, struct.name);
			case SmMap:
				gml.addFormat("ds_map_create(); // %s", struct.name);
			case SmList:
				gml.addFormat("ds_list_create(); // %s", struct.name);
		}
		var pos = 0;
		for (i => fd in struct.fields) {
			var tp = CppTypeHelper.find(fd.type);
			
			var align = fd.type.getAlignment();
			var pad = calcPadding(pos, align);
			if (pad > 0) {
				gml.addFormat("buffer_seek(_buf, buffer_seek_relative, %d); // align to %d (offset %d)%|", pad, align, pos+pad);
				pos += pad;
			}
			
			var val = proc(gml, fd.type, tp, z + 1, fd.size, 0);
			switch (mode) {
				case SmStruct:
					gml.addFormat("%|_struct_%d.%s = %s;", z, fd.name, val);
				case SmArray:
					gml.addFormat("%|_struct_%d[%d] = %s; // %s", z, i, val, fd.name);
				case SmMap:
					gml.addFormat('%|ds_map_add(_struct_%d, "%s", %s);', z, fd.name, val);
				case SmList:
					gml.addFormat('%|ds_list_add(_struct_%d, %s); // %s', z, val, fd.name);
			}
			
			var fdSize = fd.type.getSize();
			for (dim in fd.size) fdSize *= dim;
			pos += fdSize;
		}
		
		var align = getAlignment(type);
		var pad = calcPadding(pos, align);
		if (pad > 0) {
			gml.addFormat("%|buffer_seek(_buf, buffer_seek_relative, %d); // pad of %d to %d", pad, align, pos+pad);
			pos += pad;
		}
		
		return '_struct_' + z;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		var mode = CppGen.config.storageMode;
		function proc(gml:CppBuf, type:CppType, tp:CppTypeProc, z:Int, size:Array<Int>, size_ind:Int, val:String) {
			if (size_ind >= size.length) {
				tp.gmlWrite(gml, type, z + 1, val);
				return;
			}
			if (size_ind == size.length - 1 && type.name == "char") {
				var fn = CppGen.config.helperPrefix + "_write_chars";
				gml.addFormat('%s(_buf, %s, %d)', fn, val, size[size_ind]);
				return;
			}
			var _arr = '_arr_$z';
			var _ind = '_ind_$z';
			var _len = size[size_ind];
			gml.addFormat("%|%vdp = %s;", _arr, val);
			gml.addFormat("%|for (%vdb;", _ind, "0");
			gml.addFormat(" %s < %d;", _ind, _len);
			gml.addFormat(" %s += 1) %{", _ind);
			proc(gml, type, tp, z, size, size_ind + 1, '$_arr[$_ind]');
			gml.addFormat("%-}");
		}
		var structVar = "_struct_" + z;
		gml.addFormat("%|%vdp = %s; // %s", structVar, val, struct.name);
		var pos = 0;
		for (i => fd in struct.fields) {
			var tp = fd.type.proc;
			
			var pad = calcPadding(pos, tp.getAlignment(fd.type));
			if (pad > 0) gml.addFormat("%|buffer_seek(_buf, buffer_seek_relative, %d);", pad);
			
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
			proc(gml, fd.type, tp, z + 1, fd.size, 0, val);
			if (note) gml.addFormat(" // %s", fd.name);
			
			var fdSize = tp.getSize(fd.type);
			for (dim in fd.size) fdSize *= dim;
			pos += fdSize;
		}
		
		var pad = calcPadding(pos, getAlignment(type));
		if (pad > 0) gml.addFormat("%|buffer_seek(_buf, buffer_seek_relative, %d);", pad);
	}
	override public function getAlignment(type:CppType):Int {
		var align = 1;
		for (fd in struct.fields) {
			var fdAlign = fd.type.getAlignment();
			if (fdAlign > align) align = fdAlign;
		}
		return align;
	}
	override public function getSize(type:CppType):Int {
		var size = 0;
		for (fd in struct.fields) {
			var fdTP = fd.type.proc;
			var fdSize = fdTP.getSize(fd.type);
			size += calcPadding(size, fdTP.getAlignment(fd.type));
			for (arrSize in fd.size) fdSize *= arrSize;
			size += fdSize;
		}
		//
		size += calcPadding(size, getAlignment(type));
		//
		return size;
	}
	override public function usesStructs(type:CppType):Bool {
		return true;
	}
	override public function usesGmkSpec(type:CppType):Bool {
		return true;
	}
}