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
	
	static function gmlRead_impl(gml:CppBuf, type:CppType, tp:CppTypeProc, z:Int, size:Array<Int>, size_ind:Int) {
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
		var val = gmlRead_impl(gml, type, tp, z + 1, size, size_ind + 1);
		gml.addFormat("%s[%s] = %s;", _arr, _ind, val);
		gml.addFormat("%-}%|");
		return _arr;
	}
	static function gmlWrite_impl(gml:CppBuf, type:CppType, tp:CppTypeProc, z:Int, size:Array<Int>, size_ind:Int, val:String) {
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
		gmlWrite_impl(gml, type, tp, z, size, size_ind + 1, '$_arr[$_ind]');
		gml.addFormat("%-}");
	}
	
	override public function gmlRead(gml:CppBuf, type:CppType, z:Int):String {
		gml.addFormat("var _struct_%d = /* %s */array_create(%d);%|", z, struct.name, struct.fields.length);
		for (i => fd in struct.fields) {
			var tp = CppTypeHelper.find(fd.type);
			var val = gmlRead_impl(gml, fd.type, tp, z + 1, fd.size, 0);
			gml.addFormat("_struct_%d[%d/* %s */] = %s;%|", z, i, fd.name, val);
		}
		return '_struct_' + z;
	}
	override public function gmlWrite(gml:CppBuf, type:CppType, z:Int, val:String):Void {
		gml.addFormat("%|var _struct_%d = /* %s */%s;", z, struct.name, val);
		for (i => fd in struct.fields) {
			var tp = CppTypeHelper.find(fd.type);
			var val = CppBuf.fmt('_struct_%d[%d/* %s */]', z, i, fd.name);
			gmlWrite_impl(gml, fd.type, tp, z + 1, fd.size, 0, val);
		}
	}
	override public function getSize():Int {
		var size = 0;
		for (fd in struct.fields) {
			var fdSize = fd.type.proc.getSize();
			for (arrSize in fd.size) fdSize *= arrSize;
			size += fdSize;
		}
		return size;
	}
}