@echo off
cd i386\i386
move *.* ..
cd ..
cd ..
rmdir i386\i386

del /q objchk_wxp_x86\i386\*.*
del /q objchk_wxp_x86\*.*
rmdir objchk_wxp_x86\i386
rmdir objchk_wxp_x86

del /q buildchk_wxp_x86.err
del /q buildchk_wxp_x86.log