#pragma once
#define GDKEXTENSION_EXPORTS
#define __YYDEFINE_EXTENSION_FUNCTIONS__
#include "YYRunnerInterface.h"

const int VALUE_REAL = 0;		// Real value
const int VALUE_STRING = 1;		// String value
const int VALUE_ARRAY = 2;		// Array value
const int VALUE_OBJECT = 6;		// YYObjectBase* value 
const int VALUE_INT32 = 7;		// Int32 value
const int VALUE_UNDEFINED = 5;	// Undefined value
const int VALUE_PTR = 3;		// Ptr value
const int VALUE_VEC3 = 4;		// Deprecated : unused : Vec3 (x,y,z) value (within the RValue)
const int VALUE_VEC4 = 8;		// Deprecated : unused :Vec4 (x,y,z,w) value (allocated from pool)
const int VALUE_VEC44 = 9;		// Deprecated : unused :Vec44 (matrix) value (allocated from pool)
const int VALUE_INT64 = 10;		// Int64 value
const int VALUE_ACCESSOR = 11;	// Actually an accessor
const int VALUE_NULL = 12;		// JS Null
const int VALUE_BOOL = 13;		// Bool value
const int VALUE_ITERATOR = 14;	// JS For-in Iterator
const int VALUE_REF = 15;		// Reference value (uses the ptr to point at a RefBase structure)
#define MASK_KIND_RVALUE	0x0ffffff
const int VALUE_UNSET = MASK_KIND_RVALUE;

class CInstance;

struct RefString {
	const char* text;
	int refCount;
	int size;
};
struct RValue {
	union {
		int v32;
		int64_t v64;
		double val;
		RefString* str;
		void* ptr = 0;
	};
	uint32_t flags = 0;
	uint32_t kind = VALUE_REAL;

	inline bool needsFree() {
		const auto flagSet = (1 << VALUE_STRING) | (1 << VALUE_OBJECT) | (1 << VALUE_ARRAY);
		return ((1 << (kind & 31)) & flagSet) != 0;
	}
	inline void free() {
		if (needsFree()) FREE_RValue(this);
	}

	inline void setReal(double value) {
		free();
		kind = VALUE_REAL;
		val = value;
	}
	inline void setInt64(int64_t value) {
		free();
		kind = VALUE_INT64;
		v64 = value;
	}
	inline void setTo(RValue* value) {
		COPY_RValue(this, value);
	}
	
	/*
	note: for purposes of getting a number out of an RValue,
	it seems more appropriate to discard the metadata bits of a VALUE_REF
	*/
	
	inline int getInt32(int defValue = 0) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_REAL: case VALUE_BOOL: return (int)val;
			case VALUE_INT32: case VALUE_REF: return v32;
			case VALUE_INT64: return (int)v64;
			default: return defValue;
		}
	}
	inline int64_t getInt64(int64_t defValue = 0) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_REAL: case VALUE_BOOL: return (int64_t)val;
			case VALUE_INT32: case VALUE_REF: return v32;
			case VALUE_INT64: return v64;
			default: return defValue;
		}
	}
	inline const char* getString(const char* defValue = nullptr) {
		if ((kind & MASK_KIND_RVALUE) == VALUE_STRING) {
			return str->text;
		} else return defValue;
	}

	inline bool tryGetInt(int& result) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_REAL: case VALUE_BOOL: result = (int)val; return true;
			case VALUE_INT32: case VALUE_REF: result = v32; return true;
			case VALUE_INT64: result = (int)v64; return true;
			default: return false;
		}
	}
	inline bool tryGetInt64(int64_t& result) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_REAL: case VALUE_BOOL: result = (int64_t)val; return true;
			case VALUE_INT32: case VALUE_REF: result = v32; return true;
			case VALUE_INT64: result = v64; return true;
			default: return false;
		}
	}
	inline bool tryGetPtr(void*& result) {
		if ((kind & MASK_KIND_RVALUE) == VALUE_PTR) {
			result = ptr;
			return true;
		} else return false;
	}
	inline bool tryGetString(const char*& result) {
		if ((kind & MASK_KIND_RVALUE) == VALUE_STRING) {
			result = str->text;
			return true;
		} else return false;
	}
};

#define YYFuncArgs RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg
typedef void(*YYFunc) (YYFuncArgs);

using YYResult = RValue;
using YYSelf = CInstance*;
using YYOther = CInstance*;
struct YYRest {
	int length;
	RValue* items;
	inline RValue operator[] (int ind) const { return items[ind]; }
	inline RValue& operator[] (int ind) { return items[ind]; }
};

#define __YYArgCheck_any
#define __YYArgCheck(argCount)\
	if (argc != argCount) {\
		YYError(__YYFUNCNAME__ " :: argument count mismatch - want " #argCount ", have %d", argc);\
		return;\
	}
#define __YYArgCheck_range(minArgs, maxArgs)\
	if (argc < minArgs || argc > maxArgs) {\
		YYError(__YYFUNCNAME__ " :: argument count mismatch - want " #minArgs ".." #maxArgs ", have %d", argc);\
		return;\
	}
#define __YYArgCheck_rest(minArgs)\
	if (argc < minArgs) {\
		YYError(__YYFUNCNAME__ " :: argument count mismatch - want " #minArgs " or more, have %d", argc);\
		return;\
	}
#define __YYArgError(name, want, i) {\
	YYError(__YYFUNCNAME__ " :: argument type mismatch for \"" name "\" - want " want ", have %s", KIND_NAME_RValue(&arg[i]));\
	return;\
}


#define __YYArg_YYRest(name, v, i) v = { argc - i, arg + i };
#define __YYArg_RValue_ptr(name, v, i) v = &arg[i];
#define __YYArg_int(name, v, i) if (!arg[i].tryGetInt(v)) __YYArgError(name, "an int", i);
#define __YYArg_int64(name, v, i) if (!arg[i].tryGetInt64(v)) __YYArgError(name, "an int64", i);
#define __YYArg_void_ptr(name, v, i) if (!arg[i].tryGetPtr(v)) __YYArgError(name, "a pointer", i);
#define __YYArg_YYFunc(name, v, i) if (!arg[i].tryGetPtr(v)) __YYArgError(name, "a pointer", i);
#define __YYArg_const_char_ptr(name, v, i) if (!arg[i].tryGetString(v)) __YYArgError(name, "a string", i);


#define __YYResult_bool(v) result.kind = VALUE_BOOL; result.val = v;
#define __YYResult_int(v) result.kind = VALUE_REAL; result.val = v;
#define __YYResult_int64_t(v) result.kind = VALUE_INT64; result.v64 = v;
#define __YYResult_void_ptr(v) result.kind = VALUE_PTR; result.ptr = v;
#define __YYResult_const_char_ptr(v) YYCreateString(&result, v);


// TODO: add macros for project-specific types here
