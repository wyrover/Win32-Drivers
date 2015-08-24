#  Win32-Drivers

Dance with NT Kernel !!!

------------------------------------------
With some essential feeling of the Intel 32-bit Assembly language,
Let us look at the reality --  Windows NT-based Operating system.


# Folder arrangement
1. "00000_Manual"  Shows some doc that is helpful to program
2. "00000_TestBench"  has both C/C++ & Assembly compilation Platform.
3. "00000_Useful" make it possible to collect some useful codes that could be reusable.
4. "Review_Ideas"   Some basic ideas to be reviewed


# !!! Remember !!!
The Device/Symbolic Name represented by UNICODE_STRING type variable,
 the characters inside it must remain in PAGEDCODE rather than INITCODE memory,
 or might cause BSOD while unloading the driver. 

# >>> FAQ <<<
- Why I uses the Win32 Driver instead of Win32 App ?
- Win32 Driver runs on Privilege Ring 0, shares the same level as Kernel's.