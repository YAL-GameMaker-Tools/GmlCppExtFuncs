package tools;

/**
 * ...
 * @author YellowAfterlife
 */
abstract CharCode(Int) from Int to Int {
	public function isSpace():Bool {
		var c = this;
		return c == " ".code || c == "\t".code || c == "\r".code || c == "\n".code;
	}
	public function isLineSpace():Bool {
		var c = this;
		return c == " ".code || c == "\t".code;
	}
	public function isIdent0():Bool {
		var c = this;
		return (c == "_".code
			|| c >= "a".code && c <= "z".code
			|| c >= "A".code && c <= "Z".code
		);
	}
	public function isIdent1():Bool {
		var c = this;
		return (c == "_".code
			|| c >= "a".code && c <= "z".code
			|| c >= "A".code && c <= "Z".code
			|| c >= "0".code && c <= "9".code
		);
	}
	public function isDigit():Bool {
		var c = this;
		return (c >= "0".code && c <= "9".code);
	}
}