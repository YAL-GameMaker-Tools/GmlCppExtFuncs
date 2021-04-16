@echo off
neko bin/GmlCppExtFuncs.n^
	--prefix itr_test^
	--cpp interop_test/autogen.cpp^
	--gml interop_test_23/extensions/interop_test/autogen.gml^
	interop_test/interop_test.cpp
pause
