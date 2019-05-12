@echo off
del CubCases*.out for*.dat
.\DatcomModeler.exe -o CubCases.ac CubCases.dcm
Echo copying CubCases.dcm to for005.dat 
copy CubCases.dcm for005.dat
echo Run digital datcom
.\DATCOM.exe
ren for006.dat CubCases.out
del for0*.dat
pause