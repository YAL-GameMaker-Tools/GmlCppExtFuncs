package proc;
import CppConfig;
import tools.CppBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeProcCond {
	public static function run(
		gml:CppBuf,
		func:Void->Void,
		useStructs:Void->Bool,
		useGmkSpec:Void->Bool,
	) {
		var config = CppGen.config;
		var structMode = config.structMode;
		var structModeVal = config.structModeVal;
		var structModeCond = structMode != "auto";
		var gmkSpec = CppGen.hasGmkPath && useGmkSpec();
		var gmkBox = GmlBoxMode.BmGrid;
		inline function addElseGmk(elseif:Bool) {
			if (elseif) {
				gml.addFormat("%|//*/");
				gml.addFormat("%|/* GMS < 1:");
			} else gml.addFormat("%|/*/");
		}
		//
		function proc(ver:Int, sm:GmlStorageMode, bm:GmlBoxMode, vm:GmlVectorMode, gmk = false) {
			var _gmlVersion = config.gmlVersion;
			var _storageMode = config.storageMode;
			var _vectorMode = config.vectorMode;
			var _boxMode = config.boxMode;
			var _isGMK = config.isGMK;
			//
			config.gmlVersion = ver;
			config.storageMode = sm;
			config.vectorMode = vm;
			config.boxMode = bm;
			config.isGMK = gmk;
			//
			func();
			//
			config.gmlVersion = _gmlVersion;
			config.storageMode = _storageMode;
			config.vectorMode = _vectorMode;
			config.boxMode = _boxMode;
			config.isGMK = _isGMK;
		}
		inline function procGMS23() {
			proc(23, SmStruct, BmStruct, VmArray);
		}
		inline function procGMS1() {
			if (config.preferDS) {
				proc(14, SmMap, BmArray, VmList);
			} else {
				proc(14, SmArray, BmArray, VmArray);
			}
		}
		
		if (structModeVal != null) {
			// e.g. forced array mode for GMS 2.3
			if (gmkSpec) gml.addFormat("%|// GMS >= 1:");
			
			if (structModeVal) {
				procGMS23();
			} else procGMS1();
			
			if (gmkSpec) {
				addElseGmk(false);
				proc(8, structModeVal ? SmMap : SmList, gmkBox, VmList, true);
				gml.addFormat("%|//*/");
			}
			return;
		}
		
		if (!useStructs()) {
			// no structs, but don't get too excited
			if (gmkSpec) gml.addFormat("%|// GMS >= 1:");
			procGMS1();
			if (gmkSpec) {
				addElseGmk(false);
				proc(8, SmList, gmkBox, VmList, true);
				gml.addFormat("%|//*/");
			}
			return;
		}
		
		gml.addFormat("%|// GMS >= 2.3:");
		if (structModeCond) {
			gml.addFormat("%|if (%s) %{", structMode);
		}
		
		procGMS23();
		
		if (structModeCond) {
			gml.addFormat("%-} else //*/");
			gml.addFormat("%|%{");
			if (gmkSpec) {
				gml.addFormat("%|// GMS >= 1:");
			}
		} else if (!gmkSpec) {
			// >=2.3 / else
			gml.addFormat("%|/*/");
		} else {
			// >=2.3 / >=1 / gmk
			gml.addFormat("%|//*/");
			gml.addFormat("%|/* GMS >= 1 && GMS < 2.3:");
		}
		
		procGMS1();
		
		if (gmkSpec) {
			addElseGmk(true);
			if (structModeCond) {
				// a condition to select which of two workarounds you'd prefer?
				gml.addFormat("%|if (%s) %{", structMode);
				proc(8, SmMap, gmkBox, VmList, true);
				gml.addFormat("%-} else %{");
				proc(7, SmList, gmkBox, VmList, true); // so that it doesn't clash with above
				gml.addFormat("%-}");
			} else {
				// if you're going to have to free it anyway, might as well
				// make it something with readable keys, you know?
				proc(8, SmMap, gmkBox, VmList, true);
			}
		}
		
		if (structModeCond) {
			gml.addFormat("%-}");
		} else {
			gml.addFormat("%|//*/");
		}
	}
}