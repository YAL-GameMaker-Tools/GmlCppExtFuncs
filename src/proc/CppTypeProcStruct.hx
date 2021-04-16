package proc;
import proc.CppTypeProc;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcStruct extends CppTypeProc {
	public var struct:CppStruct;
	public function new(struct:CppStruct) {
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
			gml.addFormat("var %s = array_create(%d);", _arr, _len);
			gml.addFormat("%|for (var %s = 0; %s < %d; %s++) {%+", _ind, _ind, _len, _ind);
			var val = proc(gml, type, tp, z + 1, size, size_ind + 1);
			gml.addFormat("%s[%s] = %s;", _arr, _ind, val);
			gml.addFormat("%-}%|");
			return _arr;
		}
		gml.addFormat("var _struct_%d = /* %s */array_create(%d);%|", z, struct.name, struct.fields.length);
		var pos = 0;
		for (i => fd in struct.fields) {
			var tp = CppTypeHelper.find(fd.type);
			
			var align = tp.getAlignment();
			var pad = calcPadding(pos, align);
			if (pad > 0) {
				gml.addFormat("buffer_seek(_buf, buffer_seek_relative, %d); // align to %d (offset %d)%|", pad, align, pos+pad);
				pos += pad;
			}
			
			var val = proc(gml, fd.type, tp, z + 1, fd.size, 0);
			gml.addFormat("_struct_%d[%d/* %s */] = %s;%|", z, i, fd.name, val);
			
			var fdSize = tp.getSize();
			for (dim in fd.size) fdSize *= dim;
			pos += fdSize;
		}
		
		var align = getAlignment();
		var pad = calcPadding(pos, align);
		if (pad > 0) {
			gml.addFormat("buffer_seek(_buf, buffer_seek_relative, %d); // pad of %d to %d%|", pad, align, pos+pad);
			pos += pad;
		}
		
		return '_struct_' + z;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
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
			gml.addFormat("%|var %s = %s;", _arr, val);
			gml.addFormat("%|for (var %s = 0; %s < %d; %s++) %{", _ind, _ind, _len, _ind);
			proc(gml, type, tp, z, size, size_ind + 1, '$_arr[$_ind]');
			gml.addFormat("%-}");
		}
		gml.addFormat("%|var _struct_%d = /* %s */%s;", z, struct.name, val);
		var pos = 0;
		for (i => fd in struct.fields) {
			var tp = CppTypeHelper.find(fd.type);
			
			var pad = calcPadding(pos, tp.getAlignment());
			if (pad > 0) gml.addFormat("buffer_seek(_buf, buffer_seek_relative, %d);%|", pad);
			
			var val = CppBuf.fmt('_struct_%d[%d/* %s */]', z, i, fd.name);
			proc(gml, fd.type, tp, z + 1, fd.size, 0, val);
			
			var fdSize = tp.getSize();
			for (dim in fd.size) fdSize *= dim;
			pos += fdSize;
		}
		
		var pad = calcPadding(pos, getAlignment());
		if (pad > 0) gml.addFormat("buffer_seek(_buf, buffer_seek_relative, %d);%|", pad);
	}
	override public function getAlignment():Int {
		var align = 1;
		for (fd in struct.fields) {
			var fdAlign = fd.type.proc.getAlignment();
			if (fdAlign > align) align = fdAlign;
		}
		return align;
	}
	override public function getSize():Int {
		var size = 0;
		for (fd in struct.fields) {
			var fdTP = fd.type.proc;
			var fdSize = fdTP.getSize();
			size += calcPadding(size, fdTP.getAlignment());
			for (arrSize in fd.size) fdSize *= arrSize;
			size += fdSize;
		}
		//
		size += calcPadding(size, getAlignment());
		//
		return size;
	}
}