;@echo off
;goto make

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;
;  RamDisk GUI
;
;  Written by Four-F (four-f@mail.ru)
;
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

include \masm32\include\winioctl.inc
include \masm32\include\dbt.inc

include \masm32\Macros\Strings.mac

include ..\common.inc

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       Fix helper macro                                            
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Fix MACRO txt:=<Fix this later!!!!>
	local pos, spos

	pos = 0
	spos = 0

	% FORC chr, @FileCur		;; Don't display full path. Easier to read.
		pos = pos + 1
		IF "&chr" EQ 5Ch		;; "/"
			spos = pos
		ENDIF
	ENDM

	% ECHO @CatStr(<Fix: >, @SubStr(%@FileCur, spos+1,), <(%@Line) - txt>)
ENDM

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                  S T R U C T U R E S                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                      E Q U A T E S                                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;DBT_DEVICEARRIVAL           equ 8000	; system detected a new device
;DBT_DEVICEREMOVEPENDING     equ 8003	; about to remove, still avail.
;DBT_DEVICEREMOVECOMPLETE    equ 8004	; device is gone

IDD_MAIN					equ	1000

IDC_DRIVE_LETTER			equ 1001
IDC_DISK_SIZE				equ 1002
IDC_ROOT_DIRECTORY_ENTRIES	equ 1003
IDC_SECTORS_PER_CLUSTER		equ 1004
IDC_CREATE					equ 1005
IDC_REMOVE					equ 1006

IDI_ICON					equ 2000

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     C O N S T A N T S                                             
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.const

CTA0 "RamDisk.sys",	g_szDriverFileName
CTA0 "RamDisk",		g_szDriverName

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                              U N I N I T I A L I Z E D  D A T A                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.data?

g_hInstance					HINSTANCE	?
g_hDlg						HWND		?

g_hwndDriveLetters			HWND		?
g_hwndDiskSize				HWND		?
g_hwndRootDerectoryEntries	HWND		?
g_hwndSectorsPerCluster		HWND		?

g_hwndCreate				HWND		?
g_hwndRemove				HWND		?

g_hSCManager				HANDLE		?
g_hService					HANDLE		?
g_hDevice					HANDLE		?

g_fRamdiskMounted			BOOL		?

g_CreateParams				CREATE_PARAMS	<>

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       C O D E                                                     
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.code

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                             MyUnhandledExceptionFilter                                            
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

MyUnhandledExceptionFilter proc

; Just cleanup every possible thing
	
local _ss:SERVICE_STATUS
	
	invoke CloseHandle, g_hDevice
	invoke ControlService, g_hService, SERVICE_CONTROL_STOP, addr _ss
	invoke DeleteService, g_hService
	invoke CloseServiceHandle, g_hService
	invoke CloseServiceHandle, g_hSCManager

	mov eax, EXCEPTION_EXECUTE_HANDLER
	ret

MyUnhandledExceptionFilter endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    PutRamDiskParamsIntoRegistry                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

PutRamDiskParamsIntoRegistry proc uses esi

local fOk:BOOL
local hKey:HKEY

	mov fOk, TRUE

	lea esi, g_CreateParams
	assume esi:ptr CREATE_PARAMS

	invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE, $CTA0("SYSTEM\\CurrentControlSet\\Services\\RamDisk"), \
								0, KEY_CREATE_SUB_KEY + KEY_SET_VALUE, addr hKey

	.if eax == ERROR_SUCCESS

		invoke RegSetValueEx, hKey, $CTA0("DriveLetter"), NULL, REG_DWORD, addr [esi].dwDriveLetter, sizeof DWORD
		.if eax != ERROR_SUCCESS
			and fOk, FALSE
		.endif

		invoke RegSetValueEx, hKey, $CTA0("DiskSize"), NULL, REG_DWORD, addr [esi].nDiskSize, sizeof DWORD
		.if eax != ERROR_SUCCESS
			and fOk, FALSE
		.endif

		invoke RegSetValueEx, hKey, $CTA0("RootDirectoryEntries"), NULL, REG_DWORD, addr [esi].nRootDirectoryEntries, sizeof DWORD
		.if eax != ERROR_SUCCESS
			and fOk, FALSE
		.endif

		invoke RegSetValueEx, hKey, $CTA0("SectorsPerCluster"), NULL, REG_DWORD, addr [esi].nSectorsPerCluster, sizeof DWORD
		.if eax != ERROR_SUCCESS
			and fOk, FALSE
		.endif

		invoke RegCloseKey, hKey

	.endif

	assume esi:nothing

	mov eax, fOk
	ret

PutRamDiskParamsIntoRegistry endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                         LoadDriver                                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

LoadDriver proc

local hSCManager:HANDLE
local hService:HANDLE
local acModulePath[MAX_PATH]:CHAR
local fOk:BOOL

	and fOk, FALSE

	invoke OpenSCManager, NULL, NULL, SC_MANAGER_ALL_ACCESS	;SC_MANAGER_CONNECT + SC_MANAGER_CREATE_SERVICE
	.if eax != NULL
		mov hSCManager, eax

		push eax
		invoke GetFullPathName, addr g_szDriverFileName, sizeof acModulePath, addr acModulePath, esp
    	pop eax

		invoke CreateService, hSCManager, addr g_szDriverName, $CTA0("Virtual Disk Drive"), \
			SERVICE_START + DELETE, SERVICE_KERNEL_DRIVER, SERVICE_DEMAND_START, \
			SERVICE_ERROR_IGNORE, addr acModulePath, NULL, NULL, NULL, NULL, NULL
		.if eax != NULL
			mov hService, eax

			invoke PutRamDiskParamsIntoRegistry
			.if eax == TRUE
				invoke StartService, hService, 0, NULL
				.if eax != 0
					mov fOk, TRUE
				.endif
			.endif

			.if fOk == FALSE
				invoke DeleteService, hService
			.endif

			invoke CloseServiceHandle, hService
		.endif
		invoke CloseServiceHandle, hSCManager
	.endif

	mov eax, fOk
	ret

LoadDriver endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       UnloadDriver                                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

UnloadDriver proc

local fOk:BOOL

local hSCManager:HANDLE
local hService:HANDLE
local _ss:SERVICE_STATUS

	and fOk, FALSE				; assume error

	invoke CloseHandle, g_hDevice

	invoke OpenSCManager, NULL, NULL, SC_MANAGER_ALL_ACCESS
	.if eax != NULL
		mov hSCManager, eax

		invoke OpenService, hSCManager, addr g_szDriverName, SERVICE_STOP + DELETE
		.if eax != NULL
			mov hService, eax
			invoke ControlService, hService, SERVICE_CONTROL_STOP, addr _ss

			.if eax != 0
				mov fOk, TRUE
			.endif
			invoke DeleteService, hService
			invoke CloseServiceHandle, hService
		.endif
		invoke CloseServiceHandle, hSCManager
	.endif

	mov eax, fOk
	ret

UnloadDriver endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                               BroadcastDeviceMessage                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

BroadcastDeviceMessage proc dwDriveLetter:DWORD, uMsg:UINT

local dbv:DEV_BROADCAST_VOLUME

Fix DEV_BROADCAST_VOLUME defined since win2000
Fix dbcv_flags is defined as WORD. Check structure size

	mov dbv.dbcv_size, sizeof dbv
	mov dbv.dbcv_devicetype, DBT_DEVTYP_VOLUME		; Logical volume
	and dbv.dbcv_reserved, 0
	mov ecx, dwDriveLetter
	sub ecx, 'A'
	xor eax, eax
	inc eax
	shl eax, cl
	mov dbv.dbcv_unitmask, eax						; Each bit in the mask corresponds to one logical drive
	mov dbv.dbcv_flags, DBTF_MEDIA					; Change affects media in drive

	invoke BroadcastSystemMessage, BSF_NOHANG + BSF_POSTMESSAGE, NULL, WM_DEVICECHANGE, uMsg, addr dbv
	.if ( eax != 0 ) && ( eax != -1 )
		mov eax, TRUE
	.else
		and eax, FALSE
	.endif

	ret

BroadcastDeviceMessage endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    MountRamdisk                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

MountRamdisk proc

	invoke LoadDriver
	.if eax == TRUE
		invoke BroadcastDeviceMessage, g_CreateParams.dwDriveLetter, DBT_DEVICEARRIVAL
	.endif

	ret

MountRamdisk endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                   UnmountRamdisk                                                  
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

UnmountRamdisk proc

local dwBytesReturned:DWORD
local fOk:BOOL
local hDevice:HANDLE
local buffer[256]:CHAR

	and fOk, FALSE

	; RamDisk is no longer available for use. Applications should prepare for the removal of the device
	invoke BroadcastDeviceMessage, g_CreateParams.dwDriveLetter, DBT_DEVICEREMOVEPENDING

	invoke wsprintf, addr buffer, $CTA0("\\\\.\\%c:"), g_CreateParams.dwDriveLetter
	invoke CreateFile, addr buffer, GENERIC_READ + GENERIC_WRITE, FILE_SHARE_READ + FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL
	.if eax != INVALID_HANDLE_VALUE

		mov hDevice, eax

		; Lock volume to prepare for unmount
		invoke DeviceIoControl, hDevice, FSCTL_LOCK_VOLUME, NULL,0, NULL, 0, addr dwBytesReturned, NULL
		.if eax != 0

			; Unmount volumes
			invoke DeviceIoControl, hDevice, FSCTL_DISMOUNT_VOLUME, NULL, 0, NULL, 0, addr dwBytesReturned, NULL
			.if eax != 0

				; Delete drive letter
				invoke DeviceIoControl, hDevice, IOCTL_REMOVE, NULL,0, NULL, 0, addr dwBytesReturned, NULL
				.if eax != 0
					; Link to RamDisk has been removed
					invoke BroadcastDeviceMessage, g_CreateParams.dwDriveLetter, DBT_DEVICEREMOVECOMPLETE
					mov fOk, TRUE
				.else
					invoke MessageBox, g_hDlg, $CTA0("Couldn't remove drive letter"), NULL, MB_ICONEXCLAMATION
				.endif

			.else
				invoke MessageBox, g_hDlg, $CTA0("Couldn't unmount ram disk"), NULL, MB_ICONEXCLAMATION
			.endif
			; Unlock volume
			invoke DeviceIoControl, hDevice, FSCTL_UNLOCK_VOLUME, NULL, 0, NULL, 0, addr dwBytesReturned, NULL

		.else

			CTA "Couldn't lock drive %c: in preperation for unmount.\n", g_szLockDriveError
			CTA0 "Ensure that there are no open files on the drive."

			invoke wsprintf, addr buffer, addr g_szLockDriveError, g_CreateParams.dwDriveLetter
			Fix Add error description
			invoke MessageBox, g_hDlg, addr buffer, NULL, MB_ICONEXCLAMATION
		.endif
		invoke CloseHandle, hDevice

	.else
		invoke wsprintf, addr buffer, $CTA0("Couldn't open drive %c: for unmount"), g_CreateParams.dwDriveLetter
		Fix Add error description
		invoke MessageBox, g_hDlg, addr buffer, NULL, MB_ICONEXCLAMATION
	.endif

	mov eax, fOk
	.if eax == TRUE
		; Delete RamDisk device and unload driver
		invoke UnloadDriver
	.endif

	ret

UnmountRamdisk endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                               D I A L O G     P R O C E D U R E                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DlgProc proc uses esi edi hDlg:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

local buffer[16]:CHAR
local fOk:BOOL

	mov eax, uMsg
	.if eax == WM_INITDIALOG

		push hDlg
		pop g_hDlg

		invoke LoadIcon, g_hInstance, IDI_ICON
		invoke SendMessage, hDlg, WM_SETICON, ICON_BIG, eax


		invoke GetDlgItem, hDlg, IDC_DRIVE_LETTER
		mov g_hwndDriveLetters, eax
		invoke GetDlgItem, hDlg, IDC_DISK_SIZE
		mov g_hwndDiskSize, eax
		invoke GetDlgItem, hDlg, IDC_ROOT_DIRECTORY_ENTRIES
		mov g_hwndRootDerectoryEntries, eax
		invoke GetDlgItem, hDlg, IDC_SECTORS_PER_CLUSTER
		mov g_hwndSectorsPerCluster, eax
		invoke GetDlgItem, hDlg, IDC_CREATE
		mov g_hwndCreate, eax
		invoke GetDlgItem, hDlg, IDC_REMOVE
		mov g_hwndRemove, eax


		; Fill combo with available drive letters
		invoke GetLogicalDrives
		mov edi, eax
		shr edi, 3			; skip 'A', 'B', 'C'
		mov esi, 'D'
		.while esi <= 'Z'
			shr edi, 1
			.if !CARRY?
				invoke wsprintf, addr buffer, $CTA0("%c:"), esi
				invoke SendMessage, g_hwndDriveLetters, CB_ADDSTRING, 0, addr buffer
			.endif
			inc esi
		.endw
		invoke SendMessage, g_hwndDriveLetters, CB_SETCURSEL, 0, 0

		invoke SetDlgItemInt, hDlg, IDC_DISK_SIZE, 1024, FALSE
		invoke SetDlgItemInt, hDlg, IDC_ROOT_DIRECTORY_ENTRIES, 512, FALSE
		invoke SetDlgItemInt, hDlg, IDC_SECTORS_PER_CLUSTER, 1, FALSE

	.elseif eax == WM_COMMAND

		mov eax, wParam
		and eax, 0FFFFh
;		.if eax == IDCANCEL
;			invoke EndDialog, hDlg, 0
;			invoke PostMessage, hDlg, WM_CLOSE, 0, 0

		.if eax == IDC_CREATE

			invoke SendMessage, g_hwndDriveLetters, CB_GETCURSEL, 0, 0
			.if eax != CB_ERR
				lea ecx, buffer
				invoke SendMessage, g_hwndDriveLetters, CB_GETLBTEXT, eax, ecx
				xor eax, eax
				mov al, buffer
				.if ( al >= 'D' ) && ( al <= 'Z' )
					mov g_CreateParams.dwDriveLetter, eax

					xor edi, edi
					inc edi						; TRUE
					invoke GetDlgItemInt, hDlg, IDC_DISK_SIZE, addr fOk, FALSE
					shl eax, 0Ah					; * Kb
					mov g_CreateParams.nDiskSize, eax
					and edi, fOk

					invoke GetDlgItemInt, hDlg, IDC_ROOT_DIRECTORY_ENTRIES, addr fOk, FALSE
					mov g_CreateParams.nRootDirectoryEntries, eax
					and edi, fOk

					invoke GetDlgItemInt, hDlg, IDC_SECTORS_PER_CLUSTER, addr fOk, FALSE
					mov g_CreateParams.nSectorsPerCluster, eax
					and edi, fOk

					.if ( edi == TRUE ) && ( g_fRamdiskMounted == FALSE )

						invoke MountRamdisk
						.if eax == TRUE
							mov g_fRamdiskMounted, TRUE

							invoke EnableWindow, g_hwndDriveLetters, FALSE
							invoke EnableWindow, g_hwndDiskSize, FALSE
							invoke EnableWindow, g_hwndRootDerectoryEntries, FALSE
							invoke EnableWindow, g_hwndSectorsPerCluster, FALSE
							invoke EnableWindow, g_hwndCreate, FALSE
							invoke EnableWindow, g_hwndRemove, TRUE
						.else
							invoke MessageBox, hDlg, $CTA0("Could't mount RamDisk."), NULL, MB_ICONERROR
						.endif

					.else
						invoke MessageBox, hDlg, $CTA0("Invalid parameter value."), NULL, MB_ICONERROR
					.endif
				.else
					invoke MessageBox, hDlg, $CTA0("Invalid drive letter."), NULL, MB_ICONERROR
				.endif
			.endif

		.elseif eax == IDC_REMOVE

			.if g_fRamdiskMounted == TRUE
				invoke UnmountRamdisk
				.if eax == TRUE
					and g_fRamdiskMounted, FALSE

					invoke EnableWindow, g_hwndDriveLetters, TRUE
					invoke EnableWindow, g_hwndDiskSize, TRUE
					invoke EnableWindow, g_hwndRootDerectoryEntries, TRUE
					invoke EnableWindow, g_hwndSectorsPerCluster, TRUE
					invoke EnableWindow, g_hwndCreate, TRUE
					invoke EnableWindow, g_hwndRemove, FALSE
				.else
					invoke MessageBox, hDlg, $CTA0("Could't unmount RamDisk."), NULL, MB_ICONERROR
				.endif
			.endif
		.endif



	.elseif eax == WM_CLOSE

		.if g_fRamdiskMounted
			invoke MessageBox, hDlg, $CTA0("Unmount RamDisk first\:"), NULL, MB_ICONASTERISK
		.else
			invoke EndDialog, hDlg, 0
		.endif

;	.elseif eax == WM_DESTROY


	.else

		xor eax, eax
		ret
	
	.endif

	xor eax, eax
	inc eax
	ret
    
DlgProc endp


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       start                                                       
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

start proc uses esi edi

	invoke GetModuleHandle, NULL
	mov g_hInstance, eax
	invoke DialogBoxParam, g_hInstance, IDD_MAIN, NULL, addr DlgProc, 0
	invoke ExitProcess, 0

start endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

end start

:make

set exe=RamDisk

if exist ..\%scp%.exe del ..\%scp%.exe

if exist rsrc.obj goto final
	\masm32\bin\rc /v rsrc.rc
	\masm32\bin\cvtres /machine:ix86 rsrc.res
	if errorlevel 0 goto final
		pause
		exit

:final
if exist rsrc.res del rsrc.res

\masm32\bin\ml /nologo /c /coff %exe%.bat
\masm32\bin\link /nologo /subsystem:windows %exe%.obj rsrc.obj

del %exe%.obj
move %exe%.exe ..
if exist %exe%.exe del %exe%.exe

echo.
pause
