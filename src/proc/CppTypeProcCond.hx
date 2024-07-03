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
		function proc(sm:GmlStorageMode, bm:GmlBoxMode, gmk = false) {
			config.storageMode = sm;
			config.boxMode = bm;
			config.isGMK = gmk;
			func();
		}
		
		if (structModeVal != null) {
			// e.g. forced array mode for GMS 2.3
			if (gmkSpec) gml.addFormat("%|// GMS >= 1:");
			
			if (structModeVal) {
				proc(SmStruct, BmStruct);
			} else {
				proc(SmArray, BmArray);
			}
			
			if (gmkSpec) {
				addElseGmk();
				proc(structModeVal ? SmMap : SmList, gmkBox, true);
				gml.addFormat("%|//*/");
			}
			return;
		}
		
		if (!useStructs()) {
			// no structs, but don't get too excited
			if (gmkSpec) gml.addFormat("%|// GMS >= 1:");
			proc(SmArray, BmArray);
			if (gmkSpec) {
				addElseGmk();
				proc(SmList, gmkBox, true);
				gml.addFormat("%|//*/");
			}
			return;
		}
		
		gml.addFormat("%|// GMS >= 2.3:");
		if (structModeCond) {
			gml.addFormat("%|if (%s) %{", structMode);
		}
		proc(SmStruct, BmStruct);
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
		
		proc(SmArray, BmArray);
		
		if (gmkSpec) {
			addElseGmk();
			if (structModeCond) {
				// a condition to select which of two workarounds you'd prefer?
				gml.addFormat("%|if (%s) %{", structMode);
				proc(SmMap, gmkBox);
				gml.addFormat("%-} else %{");
				proc(SmList, gmkBox);
				gml.addFormat("%-}");
			} else {
				// if you're going to have to free it anyway, might as well
				// make it something with readable keys, you know?
				proc(SmMap, gmkBox);
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