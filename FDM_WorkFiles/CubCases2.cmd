@echo off
del CubCases2*.out for*.dat
.\DatcomModeler.exe -o CubCases2.ac CubCases2.dcm
Echo copying CubCases2.dcm to for005.dat 
copy CubCases2.dcm for005.dat
echo Run digital datcom
.\DATCOM.exe
ren for006.dat CubCases2.out
del for0*.dat
pause
