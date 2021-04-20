
# GmlCppExtFuncs (working title)
By default, GameMaker's extension interop has some limitations - since you can only pass around reals (64-bit floating point values) and pointers (to strings or binary buffers), many things are a bother to do - for example, if you want a function that computes a sum of int64 values in an array, you have to do
```cpp
dllexport double get_sum_raw(int64_t* values, double count) {
	int64_t sum = 0;
	for (int i = 0; i < count; i++) sum += values[i];
	values[0] = sum;
	return 1;
}
```
and then a wrapper GML script:
```gml
#define get_sum
/// get_sum(values:array<int>)->int
var b = global.reusable_grow_buffer;
buffer_seek(b, buffer_seek_start, 0);
var arr = argument0;
var len = array_length(arr);
for (var i = 0; i < len; i++) buffer_write(b, buffer_u64, arr[i]);
if (get_sum_raw(buffer_get_address(b), len)) {
	return buffer_peek(b, 0, buffer_u64);
} else {
	// extension failed to load
}
```
With help of this tool, however, you can write just
```cpp
dllg int64_t get_sum(vector<int64_t> values) {
	int64_t sum = 0;
	for each (auto val in arr) sum += val;
	return sum;
}
```
and the tool will generate the rest (a wrapper C++ function and a GML script that'll call it).

Combined with [GmxGen](https://github.com/YAL-GameMaker-Tools/GmxGen), this means that you can write your C++ functions like normal and have them become available in GM automatically.

## Compiling
```bat
haxe -cp src -neko GmlCppExtFuncs.n -main CppGen
nekotools boot GmlCppExtFuncs.n
```

## Setting up

* Add a new .cpp file to your C++ project
* Add [gml_ext.h](https://github.com/YAL-GameMaker-Tools/GmlCppExtFuncs/blob/master/interop_test/gml_ext.h) to your C++ project
* Add a blank GML file to your GameMaker extension (using GM IDE)
* Add [interop_test.gml](https://github.com/YAL-GameMaker-Tools/GmlCppExtFuncs/blob/master/interop_test_23/extensions/interop_test/interop_test.gml) to your GameMaker extension
* Prepend your C++ functions of interest with the macro (default: `dllg`)

## Using

The general syntax is as following:
```
GmlCppExtFuncs --cpp autogenerated_file.cpp --gml autogenerated_file.gml ...files [...options]
```

For a practical example, suppose you wanted to do this for the project in this repository.

You could do so by calling
```
GmlCppExtFuncs -cpp interop_test/autogen.cpp -gml interop_test_23/extensions/interop_test/autogen.gml --prefix itr_test interop_test/interop_test.cpp
```

When using Visual Studio, you can use Build Events -> Pre-Build Event to automatically run the command before you compile.

## Further reading

* [Command-line arguments](https://github.com/YAL-GameMaker-Tools/GmlCppExtFuncs/wiki/Command-line-arguments)
* [Supported types](https://github.com/YAL-GameMaker-Tools/GmlCppExtFuncs/wiki/Supported-types)
* [Documentation tags](https://github.com/YAL-GameMaker-Tools/GmlCppExtFuncs/wiki/Documentation-tags)

## TODOs

* Generate inline "serialization" code on C++ side as well so that data types can be nested arbitrarily
* Support returning pointers

## Limitations
* Since the tool relies on parsing C++ code, it may fail on code that looks deceptively (e.g. because it's full of C++ macros) - feel free to preprocess your files (via `-E` in GCC or `/P` in MSVC) before feeding the files to the tool if you rely heavily on generating functions through macros.
