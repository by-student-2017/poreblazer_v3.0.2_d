# poreblazer_v3.0.2_d


-----
# Windows 10


1. cd WinXP
2. cd HKUST1
3. run.bat
4. (wait a few minutes)
5. (you can get results.txt and psd.txt)
6. (double click) plot.gpl (need gnuplot)


-----
# (cif -> xyz) VESTA (need check carefully) 


1. Edit > Bonds ... > Do not search atoms beyond the boundary (of all atoms) (on Boundary mode)  > OK
2. Objects > Boundary... > x(max) = y(max) = z(max) = 0.9999
3. File > Export Data... > XYZ file (*.xyz)
4. Do you want to save hidden atoms too? (no)


-----
# (cif -> xyz) Aten-2.1.9.exe (Win32) (Windows installer) (https://www.projectaten.com/aten)


1. Open > Filter (cif) > HKUST1.cif > Open
2. Save As > HKUST1.xyz > Save


-----
# (cif -> xyz) cif2cell (GitHub - by-student-2017/cif2cell-informal)


1. cif2cell -p xyz -f HKUST1.cif