package proc;

import tools.CppBuf;
using StringTools;

class CppTypeProcCustom extends CppTypeProc {
	public var custom = new CppTypeProcCustomValues();
	public static var rxValue = ~/\$value\b/g;
	public static var rxDepth = ~/\$depth\b/g;
	public static var rxReturn = ~/^return\b\s*(.+?);?$/;
	
	static function patch(buf:CppBuf, snip:String, ?depth:Int, ?val:String) {
		if (snip == null) return null;
		if (val != null) snip = rxValue.replace(snip, val);
		if (depth != null) snip = rxDepth.replace(snip, "" + depth);
		
		if (buf != null) {
			var lines = snip.split("\n");
			var expr = lines.pop().trim();
			if (rxReturn.match(expr)) {
				expr = rxReturn.matched(1);
			}
			for (line in lines) buf.addFormat("%s%|", line);
			return expr;
		} else return snip;
	}
	
	override function gmlRead(gml:CppBuf, type:CppType, depth:Int):String {
		return patch(gml, custom.gmlRead, depth);
	}
	override function gmlWrite(gml:CppBuf, type:CppType, depth:Int, val:String) {
		if (custom.gmlWrite != null) {
			gml.addFormat("%|%s", patch(gml, custom.gmlWrite, depth, val));
		}
	}
	override function gmlCleanup(gml:CppBuf, type:CppType, depth:Int, val:String) {
		if (custom.gmlCleanup == null) return;
		gml.addFormat("%|%s", patch(gml, custom.gmlCleanup, depth, val));
	}
	
	override function cppRead(cpp:CppBuf, type:CppType, prefix:String):String {
		if (custom.cppRead != null) {
			return patch(cpp, custom.cppRead, null);
		} else {
			return super.cppRead(cpp, type, null);
		}
	}
	override function cppWrite(cpp:CppBuf, type:CppType, prefix:String, val:String) {
		if (custom.cppWrite != null) {
			cpp.addFormat("%|%s", patch(cpp, custom.cppWrite, null, val));
		} else {
			super.cppWrite(cpp, type, null, val);
		}
	}
	
	override function getSize(type:CppType):Int {
		if (custom.size != null) return custom.size;
		return super.getSize(type);
	}
	override function hasDynSize(type:CppType):Bool {
		return custom.dynSize != null;
	}
	override function cppDynSize(cpp:CppBuf, type:CppType, prefix:String, val:String, result:String):Int {
		if (custom.dynSize != null) {
			cpp.addFormat("%|%s", patch(null, custom.dynSize, null, val));
		}
		return getSize(type);
	}
	override function usesStructs(type:CppType):Bool {
		return custom.usesStructs;
	}
	
	override function useGmlArgument():Bool {
		return custom.useGmlArgument;
	}
	override function keepGmlArgVar(type):Bool {
		return custom.keepGmlArgVar;
	}
	
	public static function parse(snip:String) {
		static var rxStart = ~/^(\w+)[ \t]*\n(\s*)([\s\S]+)/;
		//trace('"' + snip + '"');
		if (!rxStart.match(snip)) {
			CppGen.warn("@dllg:type should start with typename");
			return;
		}
		var typename = rxStart.matched(1);
		var indent = rxStart.matched(2);
		snip = rxStart.matched(3);
		
		static var rxMeta = ~/^\s*@(\w+)\s*(.+)?/;
		var tp = new CppTypeProcCustom();
		var tc = tp.custom;
		var metaName:String = null;
		var metaLines = [];
		function flush() {
			if (metaName == null) return;
			var metaText = metaLines.join("\n");
			switch (metaName.toLowerCase()) {
				case "gmlread":  tc.gmlRead  = metaText;
				case "gmlwrite": tc.gmlWrite = metaText;
				case "gmlcleanup": tc.gmlCleanup = metaText;
				case "cppread":  tc.cppRead  = metaText;
				case "cppwrite": tc.cppWrite = metaText;
				//
				case "size": tc.size = Std.parseInt(metaText);
				case "dynsize": tc.dynSize = metaText;
				//
				case "struct": tc.usesStructs = true;
				case "gmlargvar": tc.keepGmlArgVar = true;
				//
				default: CppGen.warn('Unknown meta @${metaName} in type ${typename}');
			}
		}
		for (line in snip.split("\n")) {
			if (line.startsWith(indent)) line = line.substr(indent.length);
			
			if (rxMeta.match(line)) {
				flush();
				metaName = rxMeta.matched(1);
				metaLines = [];
				var first = rxMeta.matched(2);
				if (first != null) metaLines.push(first);
			} else metaLines.push(line);
		}
		flush();
		CppType.typedefs.remove(typename);
		CppTypeHelper.map[typename] = tp;
	}
}
class CppTypeProcCustomValues {
	public var gmlRead:String = null;
	public var gmlWrite:String = null;
	public var gmlCleanup:String = null;
	//
	public var cppRead:String = null;
	public var cppWrite:String = null;
	//
	public var size:Null<Int> = null;
	public var dynSize:String = null;
	public var usesStructs = false;
	public var useGmlArgument = true;
	public var keepGmlArgVar = false;
	//
	public function new() {}
}