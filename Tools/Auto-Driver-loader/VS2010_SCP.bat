;@echo off
;goto make

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.386
.model flat, stdcall
option casemap:none

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                  I N C L U D E   F I L E S                                        
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\advapi32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\advapi32.lib

include \masm32\Macros\Strings.mac

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                         C O D E                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.code

start proc

local hSCManager:HANDLE
local hService:HANDLE
local acDriverPath[MAX_PATH]:CHAR

	; Open a handle to the SC Manager database
	invoke OpenSCManager, NULL, NULL, SC_MANAGER_CREATE_SERVICE
	.if eax != NULL
		mov hSCManager, eax

		push eax
		invoke GetFullPathName, $CTA0("VS2010.sys"), sizeof acDriverPath, addr acDriverPath, esp
    	pop eax

		; Register driver in SCM active database
		invoke CreateService, hSCManager, $CTA0("VS2010"), $CTA0("VS2010.SYS TEST"), \
				SERVICE_START + DELETE, SERVICE_KERNEL_DRIVER, SERVICE_DEMAND_START, \
				SERVICE_ERROR_IGNORE, addr acDriverPath, NULL, NULL, NULL, NULL, NULL
		.if eax != NULL
			mov hService, eax
			invoke StartService, hService, 0, NULL
			
			invoke MessageBox, NULL, $CTA0("Driver is running...Within 5 seconds."), NULL, MB_OK
			; Here driver VS2010.sys RUNNING...
			
			; GO THERE, DELAYING
			invoke   Sleep, 5000   ;; Do delay, 5000 MiliSeconds

			; Remove driver from SCM database
			invoke DeleteService, hService
			invoke CloseServiceHandle, hService
		.else
			invoke MessageBox, NULL, $CTA0("Can't register driver."), NULL, MB_ICONSTOP
		.endif
		invoke CloseServiceHandle, hSCManager
	.else
		invoke MessageBox, NULL, $CTA0("Can't connect to Service Control Manager."), \
							NULL, MB_ICONSTOP
	.endif

	invoke ExitProcess, 0

start endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

end start

:make

\masm32\bin\ml /nologo /c /coff VS2010_SCP.bat
\masm32\bin\link /nologo /subsystem:windows VS2010_SCP.obj

del VS2010_SCP.obj

echo.
pause
