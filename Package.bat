@echo off
cd bin
echo Creating standalone command line executable...
nekotools boot GmlCppExtFuncs.n
cmd /C 7z a GmlCppExtFuncs.zip GmlCppExtFuncs.n GmlCppExtFuncs.exe
pause
