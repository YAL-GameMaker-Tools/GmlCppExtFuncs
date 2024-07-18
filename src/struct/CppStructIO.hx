package struct;

import proc.CppTypeProc;
import tools.CppBuf;

class CppStructIO {
	public static function readFields(struct:CppStruct, cpp:CppBuf, vp:String) {
		for (i => fd in struct.fields) {
			for (i => n in fd.size) {
				cpp.addFormat("%|for (auto %s = 0u; %0 < %d; %0++) %{", vp + '_i' + i, n);
			}
			var val = fd.type.proc.cppRead(cpp, fd.type, vp + '_f_' + fd.name);
			cpp.addFormat('%|%s.%s', vp, fd.name);
			for (i in 0 ... fd.size.length) {
				cpp.addFormat('[%s]', vp + '_i' + i);
			}
			cpp.addFormat(' = %s;', val);
			for (_ in 0 ... fd.size.length) {
				cpp.addFormat("%-}");
			}
		}
	}
	public static function writeFields(struct:CppStruct, cpp:CppBuf, vp:String) {
		for (i => fd in struct.fields) {
			for (i => n in fd.size) {
				cpp.addFormat("%|for (auto %s = 0u; %0 < %d; %0++) %{", vp + '_i' + i, n);
			}
			//
			var val = vp + "." + fd.name;
			for (i in 0 ... fd.size.length) {
				val += "[" + vp + '_i' + i + "]";
			}
			//
			fd.type.proc.cppWrite(cpp, fd.type, vp + '_f_' + fd.name, val);
			//
			for (_ in 0 ... fd.size.length) {
				cpp.addFormat("%-}");
			}
		}
	}
}