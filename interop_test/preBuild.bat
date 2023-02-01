@echo off
set dllPath=%~1
set solutionDir=%~2
set projectDir=%~3
set arch=%~4
set config=%~5

echo Running pre-build for %config%

where /q GmlCppExtFuncs
if %ERRORLEVEL% EQU 0 (
	echo Running GmlCppExtFuncs...
	
	GmlCppExtFuncs ^
	--prefix itr_test^
	--cpp "%projectDir%autogen.cpp"^
	--gml "%solutionDir%interop_test_23/extensions/interop_test/autogen.gml"^
	--struct iq_use_structs^
	%projectDir%interop_test.cpp^
	%projectDir%interop_test_m.cpp
)