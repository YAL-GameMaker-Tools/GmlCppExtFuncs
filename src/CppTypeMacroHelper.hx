package ;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * ...
 * @author YellowAfterlife
 */
class CppTypeMacroHelper {
	public static function fromComplexType(t:ComplexType):CppType {
		if (t == null) return null;
		var r:CppType;
		switch (t) {
			case TPath(p):
				if (p.pack.length == 0) {
					switch (p.name) {
						case "Int": return new CppType("int");
						case "Float": return new CppType("double");
						case "Void": return new CppType("void");
						case "String":
							r = new CppType("char");
							r.isConst = true;
							r.ptrCount = 1;
							return r;
					}
				}
				switch (p.name) {
					case "Int8": return new CppType("int8_t");
					case "Int16": return new CppType("int16_t");
					case "Int32": return new CppType("int32_t");
					case "Int64": return new CppType("int64_t");
					case "UInt8": return new CppType("uint8_t");
					case "UInt16": return new CppType("uint16_t");
					case "UInt32": return new CppType("uint32_t");
					case "UInt64": return new CppType("uint64_t");
					case "Pointer":
						r = switch (p.params[0]) {
							case TPType(_ct): fromComplexType(_ct);
							default: return null;
						}
						r.ptrCount++;
						return r;
				}
			default:
		}
		trace(t);
		return null;
	}
}