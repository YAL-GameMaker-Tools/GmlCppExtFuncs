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
		var gmkBox = GmlBoxMode.BmList;
		var safeGmk = false;
		inline function addElseGmk() {
			if (safeGmk) {
				gml.addFormat("%|//*/");
				gml.addFormat("%|/* GMS < 1:");
			} else gml.addFormat("%|/*/");
		}
		//
		function proc(sm:GmlStorageMode, bm:GmlBoxMode, vm:GmlVectorMode, gmk = false) {
			config.storageMode = sm;
			config.vectorMode = vm;
			config.boxMode = bm;
			config.isGMK = gmk;
			func();
		}
		inline function procGMS23() {
			proc(SmStruct, BmStruct, VmArray);
		}
		inline function procGMS1() {
			if (config.preferDS) {
				proc(SmMap, BmArray, VmList);
			} else {
				proc(SmArray, BmArray, VmArray);
			}
		}
		
		if (structModeVal != null) {
			// e.g. forced array mode for GMS 2.3
			if (gmkSpec) gml.addFormat("%|// GMS >= 1:");
			
			if (structModeVal) {
				procGMS23();
			} else procGMS1();
			
			if (gmkSpec) {
				addElseGmk();
				proc(structModeVal ? SmMap : SmList, gmkBox, VmList, true);
				gml.addFormat("%|//*/");
			}
			return;
		}
		
		if (!useStructs()) {
			// no structs, but don't get too excited
			if (gmkSpec) gml.addFormat("%|// GMS >= 1:");
			procGMS1();
			if (gmkSpec) {
				addElseGmk();
				proc(SmList, gmkBox, VmList, true);
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
			gml.addFormat("%|/* GMS >= 1:");
		}
		
		procGMS1();
		
		if (gmkSpec) {
			addElseGmk();
			if (structModeCond) {
				// a condition to select which of two workarounds you'd prefer?
				gml.addFormat("%|if (%s) %{", structMode);
				proc(SmMap, gmkBox, VmList);
				gml.addFormat("%-} else %{");
				proc(SmList, gmkBox, VmList);
				gml.addFormat("%-}");
			} else {
				// if you're going to have to free it anyway, might as well
				// make it something with readable keys, you know?
				proc(SmMap, gmkBox, VmList);
			}
			gml.addFormat("%|//*/");
		}
		
		if (structModeCond) {
			gml.addFormat("%-}");
		} else {
			gml.addFormat("%|//*/");
		}
	}
}