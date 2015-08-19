;@echo off
;goto make

; Written by Four-F
; four-f@mail.ru

.386
.model flat, stdcall
option casemap:none

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                  I N C L U D E   F I L E S                                        
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

include \masm32\include\windows.inc
include \masm32\include\w2k\ntstatus.inc

include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comctl32.inc
include \masm32\include\advapi32.inc
include \masm32\include\w2k\ntdll.inc

include native.inc

includelib user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\w2k\ntdll.lib

include \masm32\Macros\Strings.mac
;include \masm32\mProgs\Macros\Macros.mac
include ReportLastError.asm

include cocomac\cocomac.mac
include cocomac\ListView.mac
include cocomac\Header.mac
include cocomac\TreeView.mac
include Macros.mac
include Center.asm
include memory.asm

include commctrlW.inc


;include \masm32\mProgs\vsd\vsd.inc
;includelib \masm32\mProgs\vsd\vsd.lib
;_DEBUG				equ TRUE

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                         F U N C T I O N S   P R O T O T Y P E S                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

wsprintfW PROTO C :DWORD, :VARARG

WinMain					proto :HINSTANCE, :HINSTANCE, :LPSTR, :UINT

;Splitter_OnLButtonDown	proto :HWND, :UINT, :WPARAM, :LPARAM
;Splitter_OnLButtonUp	proto :HWND, :UINT, :WPARAM, :LPARAM
;Splitter_OnMouseMove	proto :HWND, :UINT, :WPARAM, :LPARAM


cxSplitterIndentL				equ 80
cxSplitterIndentR				equ 80

xSplitterThickness				equ 2


IDD_PROPERTIES					equ 1000

IDC_TREEVIEW					equ 1010
IDC_LISTVIEW					equ	1011

IDC_STATUSBAR					equ	1007

IDI_ICON						equ	3000
IDI_UP							equ 3001
IDI_DOWN						equ 3002

;IDI_OBJECT_PROPERTIES			equ 3003

IDI_BITMAP						equ 3010

IDM_ABOUT						equ	2000

IDA_MAIN						equ 5000
IDM_HELP						equ 5001
IDM_REFRESH						equ 5002
IDM_EXIT						equ 5003

IDC_PROP_OBJ_NAME				equ 6001
IDS_PROP_OBJ_TYPE_NAME			equ 6002
IDS_PROP_OBJ_ATTR				equ 6003

IDS_PROP_REFERENCES				equ 6004
IDS_PROP_HANDLES				equ 6005

IDS_PROP_PAGED_QUOTA			equ 6006
IDS_PROP_NONPAGED_QUOTA			equ 6007

IDG_PROP_OBJ_SPECIFIC_DETAILS	equ 6008

IDS_PROP_CREATION_TIME_LABEL	equ 6009
IDS_PROP_CREATION_TIME			equ 6010

IDS_PROP_SPECIFIC_INFO1_LABEL	equ 6011
IDS_PROP_SPECIFIC_INFO1			equ 6012

;NUM_NRM_IMAGES		equ 17
;NUM_CHK_IMAGES		equ 2


CX_HEADERBITMAP					equ 9
CY_HEADERBITMAP					equ 5

SORT_NOT_YET					equ 0
SORT_ASCENDING					equ 1
SORT_DESCENDING					equ 2

; ListView Columns
LVCOL_NAME						equ	0
LVCOL_TYPE						equ	1
LVCOL_LINK						equ	2

comment ^
; W2000 - 27 Object types
Adapter			; 15h
Callback		; 0Bh
Controller		; 16h
Desktop			; 10h
Device			; 17h
Directory		; 2
Driver			; 18h
Event			; 8
EventPair		; 9
File			; 1Ah
IoCompletion	; 19h
Job				; 7
Key				; 12h
Mutant			; 0Ah
Port			; 13h
Process			; 5
Profile			; 0Eh
Section			; 11h
Semaphore		; 0Ch
SymbolicLink	; 3
Thread			; 6
Timer			; 0Dh
Token			; 4
Type			; 1
WaitablePort	; 14h
WindowStation	; 0Fh
WmiGuid			; 1Bh
^

comment ^
; WXP - 29 Object types (new:DebugObject, KeyedEvent)
Adapter			; 17h
Callback		; 0Ch
Controller		; 18h
DebugObject		; 8
Desktop			; 12h
Device			; 19h
Directory		; 2
Driver			; 1Ah
Event			; 9
EventPair		; 0Ah
File			; 1Ch
IoCompletion	; 1Bh
Job				; 7
Key				; 14h
KeyedEvent		; 10h
Mutant			; 0Bh
Port			; 15h
Process			; 5
Profile			; 0Fh
Section			; 13h
Semaphore		; 0Dh
SymbolicLink	; 3
Thread			; 6
Timer			; 0Eh
Token			; 4
Type			; 1
WaitablePort	; 16h
WindowStation	; 11h
WmiGuid			; 1Dh
^

IMG_ID_ADAPTER			equ 00
IMG_ID_CALLBACK			equ 01
IMG_ID_CONTROLLER		equ 02
IMG_ID_DEBUG_OBJECT		equ 03
IMG_ID_DESKTOP			equ 04
IMG_ID_DEVICE			equ 05
IMG_ID_DIRECTORY		equ 06
IMG_ID_DRIVER			equ 07
IMG_ID_EVENT			equ 08
IMG_ID_EVENT_PAIR		equ 09
IMG_ID_FILE				equ 10
IMG_ID_IO_COMPLETION	equ 11
IMG_ID_JOB				equ 12
IMG_ID_KEY				equ 13
IMG_ID_KEYED_EVENT		equ 14
IMG_ID_MUTANT			equ 15
IMG_ID_PORT				equ 16
;IMG_ID_PROCESS
IMG_ID_PROFILE			equ 17
IMG_ID_SECTION			equ 18
IMG_ID_SEMAPHORE		equ 19
IMG_ID_SYMBOLIC_LINK	equ 20
;IMG_ID_THREAD
IMG_ID_TIMER			equ 21
IMG_ID_TOKEN			equ 22
IMG_ID_TYPE				equ 23
IMG_ID_WAITABLE_PORT	equ 24
IMG_ID_WINDOW_STATION	equ 25
IMG_ID_WMI_GUID			equ 26
IMG_ID_DIRECTORY_OPN	equ 27
IMG_ID_MAX				equ 28


PFN_ID_ZwOpenDirectoryObject	equ 0
PFN_ID_ZwOpenEvent				equ 1
;PFN_ID_ZwOpenFile
PFN_ID_ZwOpenKey				equ 2
PFN_ID_ZwOpenMutant				equ 3
PFN_ID_ZwOpenSection			equ 4
PFN_ID_ZwOpenSemaphore			equ 5
PFN_ID_ZwOpenSymbolicLinkObject	equ 6
PFN_ID_ZwOpenTimer				equ 7
PFN_ID_MAX						equ 8

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                      U S E R   D E F I N E D   S T R U C T U R E S                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
comment ^
OBJECT_INFORMATION STRUCT
	Attributes					DWORD		?
	GrantedAccess				ACCESS_MASK	?
	HandleCount					DWORD		?
	PointerCount				DWORD		?
	PagedPoolUsage				DWORD		?
	NonPagedPoolUsage			DWORD		?
	Name						LPWSTR		?
	TypeName					LPWSTR		?
	Security					DWORD		?
	CreateTime					LARGE_INTEGER	<>
OBJECT_INFORMATION ENDS
POBJECT_INFORMATION typedef ptr OBJECT_INFORMATION
^

OBJECT_INFORMATION STRUCT
	BasicInformation		OBJECT_BASIC_INFORMATION	<>
	_Name					UNICODE_STRING				<>
	TypeName				UNICODE_STRING				<>
	ObjectTypeIndex			UINT						?
OBJECT_INFORMATION ENDS
POBJECT_INFORMATION typedef ptr OBJECT_INFORMATION

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                              I N I T I A L I Z E D  D A T A                                       
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.const
g_szAppName			db "Windows Object Explorer", 0

g_szAbout			db "About...", 0
g_szWrittenBy		db "Windows Object Explorer v1.0", 0Ah, 0Dh
					db "Compiled on "
					date
					db 0Ah, 0Dh, 0Ah, 0Dh
					db "Written by Four-F <four-f@mail.ru>", 0

CTW0 "\\", g_uszBackSlash, 4

g_szDecFmt			db "%d", 0


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                              I N I T I A L I Z E D  D A T A                                       
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

POINTERS SEGMENT READONLY PUBLIC USE32 'CONST'

; Object type names
; IMG_ID_XXX
g_apuszObjectTypeNames	label LPWSTR
LPWSTR	$CTW0("Adapter")
LPWSTR	$CTW0("Callback")
LPWSTR	$CTW0("Controller")
LPWSTR	$CTW0("DebugObject")
LPWSTR	$CTW0("Desktop")
LPWSTR	$CTW0("Device")
LPWSTR	$CTW0("Directory")
LPWSTR	$CTW0("Driver")
LPWSTR	$CTW0("Event")
LPWSTR	$CTW0("EventPair")
LPWSTR	$CTW0("File")
LPWSTR	$CTW0("IoCompletion")
LPWSTR	$CTW0("Job")
LPWSTR	$CTW0("Key")
LPWSTR	$CTW0("KeyedEvent")
LPWSTR	$CTW0("Mutant")
LPWSTR	$CTW0("Port")
;LPWSTR	$CTW0("Process")
LPWSTR	$CTW0("Profile")
LPWSTR	$CTW0("Section")
LPWSTR	$CTW0("Semaphore")
LPWSTR	$CTW0("SymbolicLink")
;LPWSTR	$CTW0("Thread")
LPWSTR	$CTW0("Timer")
LPWSTR	$CTW0("Token")
LPWSTR	$CTW0("Type")
LPWSTR	$CTW0("WaitablePort")
LPWSTR	$CTW0("WindowStation")
LPWSTR	$CTW0("WmiGuid")
g_cbObjectTypeNames	equ $-g_apuszObjectTypeNames
;LPWSTR	NULL
POINTERS ENDS

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                              U N I N I T I A L I Z E D  D A T A                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.data?
g_hInstance				HINSTANCE	?
g_pszCommandLine		LPSTR		?

g_nSplitterPosX			UINT		?		; init - 250
;g_nSplitterThickness	UINT		?		; init - 2

g_oldy					UINT		?		; init - -4
g_fMoved				BOOL		?		; init - FALSE
g_fDragMode				BOOL		?		; init - FALSE

g_cyXorBarIndentTop		UINT		?
g_cyXorBarIndentBot		UINT		?



g_hwndChild1			label DWORD
g_hwndTreeView			HWND		?

g_hwndChild2			label DWORD
g_hwndListView			HWND		?

g_hwndHeader			HWND		?
g_hWnd					HWND		?

g_hbmpHeaderArrowUp		HBITMAP		?
g_hbmpHeaderArrowDown	HBITMAP		?


g_hImageList			HANDLE		?



g_uPrevClickedColumn	UINT		?
g_uSortOrder			UINT		?
		
;g_hPopupMenu			HMENU		?

g_hwndStatusBar			HWND		?

g_acErrorDescription	CHAR	128 dup(?)


g_apfnZwOpenXxx			pproto03	PFN_ID_MAX dup(?)

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       C O D E                                                     
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.code

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

WinMain proc uses esi ebx hInst:HINSTANCE, hPrevInst:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:UINT

local wc:WNDCLASSEX
local msg:MSG
;local hwnd:HWND
local hAccel:HACCEL

	lea esi, wc
	assume esi:ptr WNDCLASSEX
	mov   [esi].cbSize, sizeof WNDCLASSEX
	mov   [esi].style, CS_HREDRAW + CS_VREDRAW
	mov   [esi].lpfnWndProc, offset WndProc
	push  g_hInstance
	pop   [esi].hInstance	
	mov   [esi].hbrBackground, COLOR_3DFACE + 1
	mov   [esi].lpszClassName, offset g_szAppName
	xor eax, eax
	mov   [esi].lpszMenuName, eax
	mov   [esi].cbClsExtra, eax
	mov   [esi].cbWndExtra, eax
	mov   [esi].hIcon, eax
	mov   [esi].hIconSm, eax
	mov   [esi].hCursor, $invoke(LoadCursor, NULL, IDC_SIZEWE)
	invoke RegisterClassEx, esi
	assume esi:nothing

	; Create the main window. This window will host two child controls.
	invoke CreateWindowEx, 0, addr g_szAppName, addr g_szAppName, \
           WS_OVERLAPPEDWINDOW+WS_CLIPCHILDREN, \
           CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, \
           NULL, NULL, hInst, NULL
	mov   ebx, eax
	
	invoke ShowWindow, ebx, nCmdShow
	invoke UpdateWindow, ebx

	mov hAccel, $invoke(LoadAccelerators, g_hInstance, IDA_MAIN)

	lea esi, msg
	.while TRUE
		invoke GetMessage, esi, NULL, 0, 0
		.break .if (!eax)
		invoke TranslateAccelerator, ebx, hAccel, esi
		.if eax == FALSE
			invoke TranslateMessage, esi
			invoke DispatchMessage, esi
		.endif
	.endw

	mov eax, (MSG PTR [esi]).wParam
	ret
	
WinMain endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     ErrorToStatusBar                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ErrorToStatusBar proc pError:LPSTR

; pError:
;	Pointer to message
;	NULL	- Grab error description from system
;	-1		- Clear Status Bar

local dwErrorId:DWORD

    pushfd
    pushad

	mov ebx, g_hwndStatusBar

	.if pError == NULL

    	invoke GetLastError
    	invoke FormatMessage, FORMAT_MESSAGE_FROM_SYSTEM, NULL,\
    				 eax, SUBLANG_DEFAULT SHL 10 + LANG_NEUTRAL, \
    				 offset g_acErrorDescription, sizeof g_acErrorDescription, NULL
	    .if eax != 0
			invoke SendMessage, ebx, SB_SETTEXT, 0, offset g_acErrorDescription
	    .else
			invoke SendMessage, ebx, SB_SETTEXT, 0, $CTA0("Error number not found.")
	    .endif

	.elseif pError == -1
		invoke SendMessage, ebx, SB_SETTEXT, 0, NULL
	.else
		invoke SendMessage, ebx, SB_SETTEXT, 0, pError
	.endif

    popad
    popfd
    
    ret

ErrorToStatusBar endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     LoadHeaderBitmap                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

LoadHeaderBitmap proc

	invoke LoadImage, g_hInstance, IDI_DOWN, IMAGE_BITMAP, \
										CX_HEADERBITMAP, CY_HEADERBITMAP, LR_LOADMAP3DCOLORS
	mov g_hbmpHeaderArrowDown, eax
	invoke LoadImage, g_hInstance, IDI_UP, IMAGE_BITMAP, \
										CX_HEADERBITMAP, CY_HEADERBITMAP, LR_LOADMAP3DCOLORS
	mov g_hbmpHeaderArrowUp, eax

    ret

LoadHeaderBitmap endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    DeleteHeaderBitmap                                             
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DeleteHeaderBitmap proc 

	invoke DeleteObject, g_hbmpHeaderArrowDown
	invoke DeleteObject, g_hbmpHeaderArrowUp

    ret

DeleteHeaderBitmap endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     ImageToHeaderItem                                             
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ImageToHeaderItem proc uses esi hwndHeader:HWND, uColumn:UINT, hbmp:HBITMAP

; hbmp == NULL: Remove bitmap

local hdi:HD_ITEM

	lea esi, hdi
	assume esi:ptr HD_ITEM
	mov [esi].imask, HDI_FORMAT

	Header_GetItem hwndHeader, uColumn, esi

	.if hbmp != NULL
		mov [esi].imask, HDI_FORMAT + HDI_BITMAP
		or [esi].fmt, HDF_BITMAP + HDF_BITMAP_ON_RIGHT
		mrm [esi].hbm, hbmp
	.else
		mov [esi].imask, HDI_FORMAT
		and [esi].fmt, not HDF_BITMAP
	.endif
	Header_SetItem hwndHeader, uColumn, esi

	assume esi:nothing
	ret

ImageToHeaderItem endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                            ltomonth                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

POINTERS SEGMENT
g_apszMonthNames	label LPSTR
LPSTR	$CTA0("Jan")
LPSTR	$CTA0("Feb")
LPSTR	$CTA0("Mar")
LPSTR	$CTA0("Apr")
LPSTR	$CTA0("May")
LPSTR	$CTA0("Jun")
LPSTR	$CTA0("Jul")
LPSTR	$CTA0("Aug")
LPSTR	$CTA0("Sep")
LPSTR	$CTA0("Oct")
LPSTR	$CTA0("Nov")
LPSTR	$CTA0("Dec")
g_cbMonthNames	equ $-g_apszMonthNames
POINTERS ENDS

.code

ltomonth proc uMonth:UINT, pacMonth:LPSTR

	mov eax, uMonth
	assume eax:SDWORD
	.if ( eax > 0 ) && ( eax <= 12 )
		dec eax						; make it zero based
		shl eax, 2					; * sizeof LPSTR
		invoke lstrcpy, pacMonth, g_apszMonthNames[eax]
	.endif
	assume eax:nothing

	ret

ltomonth endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                      PropertyDialogProc                                           
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

PropertyDialogProc proc uses esi edi ebx hDlg:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

;local as:ANSI_STRING
local buffer[512]:CHAR
local ft:FILETIME
local syst:SYSTEMTIME
local acMonth[8]:CHAR

local oa:OBJECT_ATTRIBUTES
local hSymbolicLink:HANDLE


	.if uMsg == WM_INITDIALOG
		mov eax, lParam				; -> PROPSHEETPAGE
		mov esi, (PROPSHEETPAGE PTR [eax]).lParam		; -> OBJECT_INFORMATION
		assume esi:ptr OBJECT_INFORMATION

comment ^
		lea edi, as
		assume edi:ptr ANSI_STRING
		and [edi]._Length, 0
		mov [edi].MaximumLength, sizeof buffer
		lea eax, buffer
		mov [edi].Buffer, eax

		invoke RtlUnicodeStringToAnsiString, edi, addr [esi]._Name, FALSE
;		invoke SetDlgItemText, ebx, IDC_PROP_OBJ_NAME, [edi].Buffer
^
		mov edi, [esi]._Name.Buffer
		invoke wcscmp, edi, addr g_uszBackSlash						; is it root directory ?
		.if eax != 0
			; Scan full object path name and find name
			.while TRUE
				invoke wcschr, edi, 05Ch							; find L"\"
				.break .if eax == NULL
				inc eax
				inc eax												; skeep L"\"
				mov edi, eax
			.endw		
		.endif

		mov ebx, hDlg
		; edi -> Object Name
		invoke SetDlgItemTextW, ebx, IDC_PROP_OBJ_NAME, edi
;		invoke SetDlgItemTextW, ebx, IDC_PROP_OBJ_NAME, [esi]._Name.Buffer
		invoke SetDlgItemTextW, ebx, IDS_PROP_OBJ_TYPE_NAME, [esi].TypeName.Buffer

		lea edi, buffer
		and dword ptr [edi], 0
		mov ebx, [esi].BasicInformation.Attributes
		.if ebx == 0
			mov byte ptr [edi], '-'
		.else
			.if ( ebx & HANDLE_FLAG_INHERIT )
				invoke lstrcpy, edi, $CTA0("  Inherited")
			.endif
			.if ( ebx & HANDLE_FLAG_PROTECT_FROM_CLOSE )
				invoke lstrcat, edi, $CTA0("  Protected from close")
			.endif
			.if ( ebx & PERMANENT )
				invoke lstrcat, edi, $CTA0("  Permanent")
			.endif
			.if ( ebx & EXCLUSIVE )
				invoke lstrcat, edi, $CTA0("  Exclusive")
			.endif
		.endif

		mov ebx, hDlg
		invoke SetDlgItemText, ebx, IDS_PROP_OBJ_ATTR, edi

		invoke wsprintf, edi, addr g_szDecFmt, [esi].BasicInformation.HandleCount
		invoke SetDlgItemText, ebx, IDS_PROP_HANDLES, edi

		invoke wsprintf, edi, addr g_szDecFmt, [esi].BasicInformation.PointerCount
		invoke SetDlgItemText, ebx, IDS_PROP_REFERENCES, edi

		invoke wsprintf, edi, addr g_szDecFmt, [esi].BasicInformation.PagedPoolUsage
		invoke SetDlgItemText, ebx, IDS_PROP_PAGED_QUOTA, edi

		invoke wsprintf, edi, addr g_szDecFmt, [esi].BasicInformation.NonPagedPoolUsage
		invoke SetDlgItemText, ebx, IDS_PROP_NONPAGED_QUOTA, edi

		; Show specific windows
		invoke SendDlgItemMessage, ebx, IDG_PROP_OBJ_SPECIFIC_DETAILS,	WM_SHOWWINDOW, TRUE, 0
		invoke SendDlgItemMessage, ebx, IDS_PROP_CREATION_TIME_LABEL,	WM_SHOWWINDOW, TRUE, 0
		invoke SendDlgItemMessage, ebx, IDS_PROP_CREATION_TIME,			WM_SHOWWINDOW, TRUE, 0
		invoke SendDlgItemMessage, ebx, IDS_PROP_SPECIFIC_INFO1_LABEL,	WM_SHOWWINDOW, TRUE, 0
		invoke SendDlgItemMessage, ebx, IDS_PROP_SPECIFIC_INFO1,		WM_SHOWWINDOW, TRUE, 0

		.if [esi].ObjectTypeIndex == IMG_ID_SYMBOLIC_LINK

			; Set group box caption
			invoke SetDlgItemText, ebx, IDG_PROP_OBJ_SPECIFIC_DETAILS, $CTA0("SymbolicLink Specific Details")

			; SymbolicLink creation time
			invoke FileTimeToLocalFileTime, addr [esi].BasicInformation.CreateTime, addr ft
			invoke FileTimeToSystemTime, addr ft, addr syst

			movzx eax, syst.wYear
			push eax

			movzx ecx, syst.wMonth
			invoke ltomonth, ecx, addr acMonth
			lea eax, acMonth
			push eax

			movzx eax, syst.wDay
			push eax

			movzx eax, syst.wSecond
			push eax

			movzx eax, syst.wMinute
			push eax

			movzx eax, syst.wHour
			push eax

			push  $CTA0("%d:%02d:%02d, %d %s %d")
			push edi
			call wsprintf
			add esp, 20h
			
			invoke SetDlgItemText, ebx, IDS_PROP_CREATION_TIME, edi

			; SymbolicLink links to
			Fix Get link more optimized way
			push esi
			lea ecx, oa
			lea edx, [esi]._Name
			InitializeObjectAttributes ecx, edx, OBJ_CASE_INSENSITIVE, NULL, NULL
			invoke ZwOpenSymbolicLinkObject, addr hSymbolicLink, SYMBOLIC_LINK_QUERY, addr oa
			.if eax == STATUS_SUCCESS
				invoke malloc, 1000h
				.if eax != NULL
					mov esi, eax
					assume esi:ptr UNICODE_STRING
					and [esi]._Length, 0
					mov [esi].MaximumLength, 1000h - sizeof UNICODE_STRING
					lea eax, [esi][sizeof UNICODE_STRING]
					mov [esi].Buffer, eax
					push ecx
					invoke ZwQuerySymbolicLinkObject, hSymbolicLink, esi, esp
					pop ecx
					.if eax == STATUS_SUCCESS
						invoke SetDlgItemText, ebx, IDS_PROP_SPECIFIC_INFO1_LABEL, $CTA0("Links to:")
						invoke SetDlgItemTextW, ebx, IDS_PROP_SPECIFIC_INFO1, [esi].Buffer
					.endif
					invoke free, esi
					assume esi:nothing
				.endif
				invoke ZwClose, hSymbolicLink
			.endif
			pop esi

		.else
			; No specific info for this object -> Hide specific windows
			invoke ShowWindow, $invoke(GetDlgItem, ebx, IDG_PROP_OBJ_SPECIFIC_DETAILS), SW_HIDE
			invoke ShowWindow, $invoke(GetDlgItem, ebx, IDS_PROP_CREATION_TIME_LABEL), SW_HIDE
			invoke ShowWindow, $invoke(GetDlgItem, ebx, IDS_PROP_CREATION_TIME), SW_HIDE
			invoke ShowWindow, $invoke(GetDlgItem, ebx, IDS_PROP_SPECIFIC_INFO1_LABEL), SW_HIDE
			invoke ShowWindow, $invoke(GetDlgItem, ebx, IDS_PROP_SPECIFIC_INFO1), SW_HIDE

;			invoke SendDlgItemMessage, ebx, IDG_PROP_OBJ_SPECIFIC_DETAILS,	WM_SHOWWINDOW, FALSE, 0
;			invoke SendDlgItemMessage, ebx, IDS_PROP_CREATION_TIME_LABEL,	WM_SHOWWINDOW, FALSE, 0
;			invoke SendDlgItemMessage, ebx, IDS_PROP_CREATION_TIME,			WM_SHOWWINDOW, FALSE, 0

		.endif

		assume esi:nothing

    .else 
		xor eax, eax
		ret
    .endif
   
	xor eax, eax
	inc eax
	ret

PropertyDialogProc endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                         OpenObject                                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

OpenObject proc uses esi edi ebx puszObjectPath:LPWSTR, uObjectTypeIndex:UINT

; Returns object handle or NULL on errors

local status:NTSTATUS
local oa:OBJECT_ATTRIBUTES
local us:UNICODE_STRING
local hObject:HANDLE
local awcMessage[512]:WCHAR
local iosb:IO_STATUS_BLOCK
local acFileName[MAX_PATH]:WCHAR

;	and hObject, NULL			; assume unsuccess

	invoke RtlInitUnicodeString, addr us, puszObjectPath
	lea esi, oa
	lea edx, us
	InitializeObjectAttributes esi, edx, OBJ_CASE_INSENSITIVE, NULL, NULL

	lea edi, hObject

	mov eax, uObjectTypeIndex
	.if eax == IMG_ID_DIRECTORY
		invoke ZwOpenDirectoryObject, edi, DIRECTORY_QUERY, esi
	.elseif eax == IMG_ID_EVENT
		invoke ZwOpenEvent, edi, EVENT_QUERY_STATE, esi				; EVENT_ALL_ACCESS
	.elseif eax == IMG_ID_FILE
		invoke ZwOpenFile, edi, FILE_READ_ACCESS, esi, addr iosb, FILE_SHARE_READ + FILE_SHARE_WRITE + FILE_SHARE_DELETE, 0
	.elseif eax == IMG_ID_KEY
		invoke ZwOpenKey, edi, KEY_QUERY_VALUE, esi					; KEY_ALL_ACCESS
	.elseif eax == IMG_ID_MUTANT
		invoke ZwOpenMutant, edi, MUTANT_QUERY_STATE, esi				; MUTANT_ALL_ACCESS
	.elseif eax == IMG_ID_SECTION
		invoke ZwOpenSection, edi, SECTION_QUERY, esi					; SECTION_ALL_ACCESS
	.elseif eax == IMG_ID_SEMAPHORE
		invoke ZwOpenSemaphore, edi, SEMAPHORE_QUERY_STATE, esi		; SEMAPHORE_ALL_ACCESS
	.elseif eax == IMG_ID_SYMBOLIC_LINK
		invoke ZwOpenSymbolicLinkObject, edi, SYMBOLIC_LINK_QUERY, esi	; SYMBOLIC_LINK_ALL_ACCESS
	.elseif eax == IMG_ID_TIMER
		invoke ZwOpenTimer, edi, TIMER_QUERY_STATE, esi				; TIMER_ALL_ACCESS
	.else
		mov eax, STATUS_UNSUCCESSFUL
	.endif

	.if eax != STATUS_SUCCESS	
		mov ebx, PFN_ID_MAX
		.while ebx
			dec ebx
			invoke pproto03 ptr g_apfnZwOpenXxx[ebx * sizeof LPVOID], edi, 1, esi				; XXX_QUERY_XXX
			.break .if eax == STATUS_SUCCESS
		.endw
		.if eax != STATUS_SUCCESS
			invoke ZwOpenFile, edi, FILE_READ_ACCESS, esi, addr iosb, FILE_SHARE_READ + FILE_SHARE_WRITE + FILE_SHARE_DELETE, 0
		.endif
		.if eax != STATUS_SUCCESS
			Fix \\\\\\\\.\\\\\\
			invoke wsprintfW, addr acFileName, $CTW0("\\\\.\\%s"), puszObjectPath
			invoke CreateFileW, addr acFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, NULL, NULL
			.if eax != INVALID_HANDLE_VALUE
				mov hObject, eax
				xor eax, eax			; STATUS_SUCCESS
			.endif
		.endif
	.endif

	.if eax == STATUS_SUCCESS
		mov eax, hObject
	.else
		invoke wsprintfW, addr awcMessage, $CTW0("Could't open %s object"), puszObjectPath
		invoke GetFocus
		push eax
;		invoke wcscpy, addr awcMessage, $CTW0("Couldn't open ")
;		invoke wcscat, addr awcMessage, puszObjectPath
;		invoke wcscat, addr awcMessage, $CTW0(" object.")
		invoke MessageBoxW, g_hWnd, addr awcMessage, NULL, MB_ICONERROR
		call SetFocus
		xor eax, eax			; Return NULL
	.endif

	ret

OpenObject endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     OpenSelectedObject                                            
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

OpenSelectedObject proc uses esi ebx

; If TreeView has focus fetches object path from associated tree view lParam
; If ListView has focus fetches object path from associated list view lParam
; and calls OpenObject to open it
; Returns object handle or NULL on errors

local tvi:TV_ITEM
local lvi:LV_ITEM
local iSelectedItem:UINT
local buffer[256]:CHAR

	invoke GetFocus
	.if eax == g_hwndListView
		lea esi, lvi
		assume esi:ptr LV_ITEM
		; Get object type
		mov [esi].imask, LVIF_TEXT
		ListView_GetNextItem g_hwndListView, -1, LVNI_SELECTED
		.if eax != -1
			mov iSelectedItem, eax
			mov [esi].iItem, eax
			mov [esi].iSubItem, 1
			lea eax, buffer
			mov [esi].pszText, eax
			mov [esi].cchTextMax, sizeof buffer
			invoke SendMessage, g_hwndListView, LVM_GETITEMW, 0, esi

			xor ebx, ebx			; undex
			.while TRUE
				; Which type ?
;				invoke wcscmp, addr buffer, g_apuszObjectTypeNames[ebx]
				invoke _wcsicmp, addr buffer, g_apuszObjectTypeNames[ebx]
				.if eax == 0
					shr ebx, 2				; / sizeof LPWSTR = object type index
					.break
				.endif
				add ebx, sizeof LPWSTR	; next type name
				.break .if ebx > g_cbObjectTypeNames		; break if end of array
			.endw

			; Get selected list view item (object name)
			mov [esi].imask, LVIF_PARAM
			m2m [esi].iItem, iSelectedItem
			and [esi].iSubItem, 0
			ListView_GetItem g_hwndListView, esi
			mov eax, [esi].lParam
			assume esi:nothing
		.else
			xor eax, eax
		.endif
	.else
		; Get selected tree view item (directory path)
		lea esi, tvi
		assume esi:ptr TV_ITEM
		mov [esi]._mask, TVIF_PARAM
		TreeView_GetSelection g_hwndTreeView		; our tree view has always something selected, but...
		mov [esi].hItem, eax
		; Each tree view item contains associated string with directory path in lParam
		TreeView_GetItem g_hwndTreeView, esi
		mov eax, [esi].lParam
		mov ebx, IMG_ID_DIRECTORY
		assume edi:nothing
	.endif

	; eax -> object path (unicode) or NULL
	; ecx = object type
	.if eax != NULL
		invoke OpenObject, eax, ebx
	.endif

	ret

OpenSelectedObject endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                  GetSelectedObjectTypeIndex                                       
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

GetSelectedObjectTypeIndex proc uses esi ebx

; Returns object type index or -1 on errors

local tvi:TV_ITEM
local lvi:LV_ITEM
local buffer[256]:CHAR

	invoke GetFocus
	.if eax == g_hwndListView
		lea esi, lvi
		assume esi:ptr LV_ITEM
		; Get object type
		mov [esi].imask, LVIF_TEXT
		ListView_GetNextItem g_hwndListView, -1, LVNI_SELECTED
		.if eax != -1
			mov [esi].iItem, eax
			mov [esi].iSubItem, 1
			lea eax, buffer
			mov [esi].pszText, eax
			mov [esi].cchTextMax, sizeof buffer
			invoke SendMessage, g_hwndListView, LVM_GETITEMW, 0, esi

			xor ebx, ebx			; undex
			.while TRUE
				; Which type ?
;				invoke wcscmp, addr buffer, g_apuszObjectTypeNames[ebx]
				invoke _wcsicmp, addr buffer, g_apuszObjectTypeNames[ebx]
				.if eax == 0
					shr ebx, 2				; / sizeof LPWSTR = object type index
					.break
				.endif
				add ebx, sizeof LPWSTR	; next type name
				.break .if ebx > g_cbObjectTypeNames		; break if end of array
			.endw

		.else
			xor eax, eax
		.endif
	.elseif eax == g_hwndTreeView
		mov ebx, IMG_ID_DIRECTORY
	.endif

	mov eax, ebx
	ret

GetSelectedObjectTypeIndex endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     ShowObjectProperties                                          
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ShowObjectProperties proc uses esi edi

local hObject:HANDLE
local psp:PROPSHEETPAGE
local psh:PROPSHEETHEADER
;local obi:OBJECT_BASIC_INFORMATION
local dwLenghtReturned:DWORD

local oi:OBJECT_INFORMATION
local poni:POBJECT_NAME_INFORMATION
local poti:POBJECT_TYPE_INFORMATION 

	invoke OpenSelectedObject
	.if eax != NULL
		mov hObject, eax

		lea esi, oi
		assume esi:ptr OBJECT_INFORMATION
		invoke ZwQueryObject, hObject, ObjectBasicInformation, addr [esi].BasicInformation, sizeof OBJECT_BASIC_INFORMATION, addr dwLenghtReturned
		.if eax == STATUS_SUCCESS

			dec [esi].BasicInformation.HandleCount			; correct count of handles
			dec [esi].BasicInformation.PointerCount			; the ref count is also one more

Fix Add error checking

			invoke malloc, 1000h
			mov poni, eax
			invoke ZwQueryObject, hObject, ObjectNameInformation, poni, 1000h, addr dwLenghtReturned

			; If object is file QueryDirectoryObject tells that it's 'Device'
			; but ZwQueryObject,, ObjectTypeInformation, tells that it's 'File'
			invoke malloc, 1000h
			mov poti, eax
			invoke ZwQueryObject, hObject, ObjectTypeInformation, poti, 1000h, addr dwLenghtReturned

			invoke ZwClose, hObject
			and hObject, NULL

			invoke memcpy, addr [esi]._Name, poni, sizeof UNICODE_STRING
			invoke memcpy, addr [esi].TypeName, poti, sizeof UNICODE_STRING

			invoke GetSelectedObjectTypeIndex
			mov [esi].ObjectTypeIndex, eax

			lea edi, psp
			assume edi:ptr PROPSHEETPAGE
			mov [edi].dwSize, sizeof PROPSHEETPAGE
			mov [edi].dwFlags, PSP_USEICONID + PSP_USETITLE
			m2m [edi].hInstance, g_hInstance
			mov [edi].pszTemplate, IDD_PROPERTIES
			and [edi].pszIcon, NULL
			mov [edi].pfnDlgProc, offset PropertyDialogProc
			mov [edi].pszTitle, $CTA0("Object Info")
			mov [edi].lParam, esi
			and [edi].pfnCallback, NULL

			lea edi, psh
			assume edi:ptr PROPSHEETHEADER
			mov [edi].dwSize, sizeof PROPSHEETHEADER
			mov [edi].dwFlags, PSH_USEICONID + PSH_PROPSHEETPAGE
			m2m [edi].hwndParent, g_hWnd
			m2m [edi].hInstance, g_hInstance
			and [edi].pszIcon, NULL
			mov [edi].pszCaption, $CTA0("Properties")
			mov [edi].nPages, 1					; sizeof psp / sizeof PROPSHEETPAGE
			and [edi].nStartPage, 0
			lea eax, psp
			mov [edi].ppsp, eax
			and [edi].pfnCallback, NULL
			assume edi:nothing
			invoke PropertySheet, edi

			invoke free, poni
			invoke free, poti

		.else
			invoke GetFocus
			push eax
			invoke MessageBox, g_hWnd, $CTA0("Couldn't query object info."), NULL, MB_ICONERROR
			call SetFocus
		.endif
		assume esi:nothing
		.if hObject != NULL
			invoke ZwClose, hObject
		.endif
	.endif

	ret

ShowObjectProperties endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    QueryDirectoryObject                                           
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

QueryDirectoryObject proc uses esi ebx puszDirectoryPath:LPWSTR

; Returns - pointer to array of DIRECTORY_BASIC_INFORMATION
;           NULL if unsuccesseful

local status:NTSTATUS
local oa:OBJECT_ATTRIBUTES
local us:UNICODE_STRING
local hDirectory:HANDLE

;local cb:UINT
local dwLenghtReturned:DWORD
local Context:LPVOID

	xor esi, esi			; assume unsuccess

	invoke RtlInitUnicodeString, addr us, puszDirectoryPath
	lea ecx, oa
	lea edx, us
	InitializeObjectAttributes ecx, edx, OBJ_CASE_INSENSITIVE, NULL, NULL
	invoke ZwOpenDirectoryObject, addr hDirectory, DIRECTORY_QUERY, addr oa
	.if eax == STATUS_SUCCESS

		mov ebx, 800h
		.while TRUE
			invoke malloc, ebx
			.break .if eax == NULL
			mov esi, eax
			invoke ZwQueryDirectoryObject, hDirectory, esi, ebx, FALSE, TRUE, addr Context, addr dwLenghtReturned
			.if eax == STATUS_SUCCESS
				.break
			.elseif ( eax == STATUS_NO_MORE_ENTRIES ) || ( eax == STATUS_ACCESS_DENIED )
				; directory is empty or access denied
				invoke free, esi
				xor esi, esi
				.break
			.elseif ( eax == STATUS_MORE_ENTRIES ) || ( eax == STATUS_BUFFER_TOO_SMALL )
				invoke free, esi		; Try again
				xor esi, esi
				shl ebx, 1				; Ask twice more memory
				.if ebx > 1000h * 100	; 400k
					.break				; We need to big buffer -> something went wrong
										; Better go away from here
				.endif
			.else

			.endif
		.endw
		invoke ZwClose, hDirectory
	.endif

	mov eax, esi
	ret

QueryDirectoryObject endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    QuerySymbolicLinkObject                                        
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

QuerySymbolicLinkObject proc uses esi ebx puszSymbolicLinkPath:LPWSTR

; Allocates memory from process heap
; Retrieves name of the object symbolic link links to
; Stores retrieved UNICODE_STRING and name into allocated memory

; Returns - pointer to UNICODE_STRING
;           NULL if unsuccesseful

local status:NTSTATUS
local oa:OBJECT_ATTRIBUTES
local us:UNICODE_STRING
local hSymbolicLink:HANDLE

;local cb:UINT
local dwLenghtReturned:DWORD
local Context:LPVOID

	xor esi, esi			; assume unsuccess

	invoke RtlInitUnicodeString, addr us, puszSymbolicLinkPath
	lea ecx, oa
	lea edx, us
	InitializeObjectAttributes ecx, edx, OBJ_CASE_INSENSITIVE, NULL, NULL
	invoke ZwOpenSymbolicLinkObject, addr hSymbolicLink, SYMBOLIC_LINK_QUERY, addr oa
	.if eax == STATUS_SUCCESS

		mov ebx, 800h
		.while TRUE
			invoke malloc, ebx
			.break .if eax == NULL
			mov esi, eax
			assume esi:ptr UNICODE_STRING
			and [esi]._Length, 0
			mov eax, ebx
			sub eax, sizeof UNICODE_STRING
			mov [esi].MaximumLength, ax
			lea eax, [esi][sizeof UNICODE_STRING]
			mov [esi].Buffer, eax
			assume esi:nothing
			invoke ZwQuerySymbolicLinkObject, hSymbolicLink, esi, addr dwLenghtReturned
			.if eax == STATUS_SUCCESS
				.break
			.elseif eax == STATUS_ACCESS_DENIED
				; directory is empty or access denied
				invoke free, esi
				xor esi, esi
				.break
			.elseif ( eax == STATUS_BUFFER_TOO_SMALL )
				invoke free, esi		; Try again
				xor esi, esi
				shl ebx, 1				; Ask twice more memory
				.if ebx > 1000h * 10	; 40k is enough for symbolic link object
					.break				; We need to big buffer -> something went wrong
										; Better go away from here
				.endif
			.else

			.endif
		.endw
		invoke ZwClose, hSymbolicLink
	.endif

	mov eax, esi
	ret

QuerySymbolicLinkObject endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                         MakeFullPath                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

MakeFullPath proc uses esi edi puszDirectoryPath:LPWSTR, pusObjectName:PTR UNICODE_STRING

; Makes full path to object from directory path and object name
; Allocates buffer from process heap and stores created full path into it
; Returns pointer to allocated memory with full path or NULL if unsuccessful

	invoke wcslen, puszDirectoryPath
	shl eax, 1									; * sizeof WCHAR = len in bytes (not including terminated zero)

	mov esi, pusObjectName
	add ax, (UNICODE_STRING PTR [esi])._Length	; + srtlen(ObjectName). Hope len of path never grows above FFFFh
	add eax, 4									; take into account separating '\' and terminating zero

	invoke malloc, eax
	.if eax != NULL
		mov edi, eax
		invoke wcscpy, edi, puszDirectoryPath

		invoke wcscmp, puszDirectoryPath, offset g_uszBackSlash
		; If it not the root directory add backslash
		.if eax
			invoke wcscat, edi, offset g_uszBackSlash
		.endif
		invoke wcscat, edi, (UNICODE_STRING PTR [esi]).Buffer
	.else
		xor edi, edi
	.endif

	mov eax, edi
	ret

MakeFullPath endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     FillTreeViewNode                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

FillTreeViewNode proc uses esi edi ebx hTvUpperNode:HTREEITEM, puszDirectoryPath:LPWSTR

local status:NTSTATUS
local oa:OBJECT_ATTRIBUTES
local us:UNICODE_STRING
local hDirectory:HANDLE
;local pdbi:PDIRECTORY_BASIC_INFORMATION
local cb:UINT
local dwLenghtReturned:DWORD
local Context:LPVOID

local tvins:TV_INSERTSTRUCTW
local hTvNode:HTREEITEM

	invoke QueryDirectoryObject, puszDirectoryPath

	.if eax != NULL
		mov esi, eax			; -> array of DIRECTORY_BASIC_INFORMATION

		push esi				; save for invoke free, esi
		assume esi:ptr DIRECTORY_BASIC_INFORMATION

		; Create TreeView Node
		lea edi, tvins
		assume edi:ptr TV_INSERTSTRUCTW
		mrm [edi].hParent, hTvUpperNode
		mov [edi].hInsertAfter, TVI_LAST
		mov [edi].item._mask, TVIF_TEXT + TVIF_SELECTEDIMAGE + TVIF_IMAGE + TVIF_PARAM
		mov [edi].item.iImage, IMG_ID_DIRECTORY
		mov [edi].item.iSelectedImage, IMG_ID_DIRECTORY_OPN

		; The array is terminated with zeroed DIRECTORY_BASIC_INFORMATION structure
		; But we check only first two dwords. It's enough.
		.while (dword ptr [esi] != 0) && (dword ptr [esi][4] != 0)
			mov eax, [esi].ObjectTypeName.Buffer

;			invoke wcscmp, eax, $CTW0("Directory")
			invoke _wcsicmp, eax, $CTW0("Directory")
			; Only objects of type "Directory" is of interest for us
			.if eax == 0

				; Make full path to object and associate it with tree view item
				; Later we have manually free this memory
				invoke MakeFullPath, puszDirectoryPath, addr [esi].ObjectName
				mov [edi].item.lParam, eax
				mrm [edi].item.pszText, [esi].ObjectName.Buffer
				;TreeView_InsertItem g_hwndTreeView, edi
				invoke SendMessage, g_hwndTreeView, TVM_INSERTITEMW, 0, edi
				; If current directory contains other directories fill it recursivelly
				invoke FillTreeViewNode, eax, [edi].item.lParam

			.endif

			add esi, sizeof DIRECTORY_BASIC_INFORMATION
		.endw
		assume edi:nothing
		pop esi
		invoke free, esi
		assume esi:nothing
	.endif

	ret

FillTreeViewNode endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                      DeleteListView                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DeleteListView proc uses esi ebx

; Frees all memory associated with each list view item and deletes all items

local lvi:LV_ITEM

	ListView_GetItemCount g_hwndListView
	.if eax != 0
		mov ebx, eax

		lea esi, lvi
		assume esi:ptr LV_ITEM
		mov lvi.imask, LVIF_PARAM

		.while ebx
			dec ebx					; make it zero based
			mov [esi].iItem, ebx
			ListView_GetItem g_hwndListView, esi
			.if eax == TRUE
				.if [esi].lParam != NULL
					invoke free, [esi].lParam
				.endif			
			.endif
		.endw

		assume esi:nothing
		ListView_DeleteAllItems g_hwndListView
	.endif

	ret

DeleteListView endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                         FillListView                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

FillListView proc uses esi edi ebx

local hSelectedTreeItem:HTREEITEM
local tvi:TV_ITEM
local lvi:LV_ITEMW
local puszSelectedDirectoryPath:LPWSTR

;	invoke DeleteListView
	ListView_DeleteAllItems g_hwndListView

	; Remove up/down arrow image from list view header
	invoke ImageToHeaderItem, g_hwndHeader, g_uPrevClickedColumn, NULL
	or g_uPrevClickedColumn, -1
	mov g_uSortOrder, SORT_NOT_YET

	; Get selected tree view node
	TreeView_GetSelection g_hwndTreeView
	.if eax == 0
		TreeView_GetRoot g_hwndTreeView
		push eax
		TreeView_SelectItem g_hwndTreeView, eax
		pop eax
	.endif

	lea edi, tvi
	assume edi:ptr TV_ITEM
	mov [edi]._mask, TVIF_PARAM
	mov [edi].hItem, eax
	; Each tree view item contains associated string with directory path in lParam
	TreeView_GetItem g_hwndTreeView, edi
	m2m puszSelectedDirectoryPath, [edi].lParam
	assume edi:nothing
	.if eax == TRUE

		invoke QueryDirectoryObject, puszSelectedDirectoryPath
		.if eax != NULL
			mov esi, eax			; -> array of DIRECTORY_BASIC_INFORMATION

			push esi				; for call free
			assume esi:ptr DIRECTORY_BASIC_INFORMATION

			lea edi, lvi
			assume edi:ptr LV_ITEMW
			or [edi].iItem, -1

			; Fill ListView

			; The array is terminated with zeroed DIRECTORY_BASIC_INFORMATION structure
			; But we check only first two dwords. It's enough.
			.while (dword ptr [esi] != 0) && (dword ptr [esi][4] != 0)

				mov [edi]._mask, LVIF_TEXT + LVIF_IMAGE + LVIF_PARAM
				inc [edi].iItem					; next list view item

				xor ebx, ebx			; undex
				.while TRUE
;					invoke wcscmp, [esi].ObjectTypeName.Buffer, g_apuszObjectTypeNames[ebx]
					invoke _wcsicmp, [esi].ObjectTypeName.Buffer, g_apuszObjectTypeNames[ebx]
					.if eax == 0
						shr ebx, 2				; / sizeof LPWSTR = image index
						mov [edi].iImage, ebx
						.break
					.endif
					add ebx, sizeof LPWSTR	; next type name
					.break .if ebx > g_cbObjectTypeNames		; break if end of array
				.endw

				and [edi].iSubItem, 0
				mrm [edi].pszText, [esi].ObjectName.Buffer
				; Make full path to object and associate it with list view item
				; Later we have manually free this memory
				invoke MakeFullPath, puszSelectedDirectoryPath, addr [esi].ObjectName
				mov [edi].lParam, eax				; pointer to unicode string with full path or NULL
				invoke SendMessage, g_hwndListView, LVM_INSERTITEMW, 0, edi

				and [edi]._mask, not (LVIF_PARAM + LVIF_IMAGE)
				inc [edi].iSubItem
				mrm [edi].pszText, [esi].ObjectTypeName.Buffer
				invoke SendMessage, g_hwndListView, LVM_SETITEMW, 0, edi

				invoke wcscmp, [esi].ObjectTypeName.Buffer, g_apuszObjectTypeNames[IMG_ID_SYMBOLIC_LINK * sizeof LPWSTR];$CTW0("SymbolicLink")
				.if eax == 0
					mov eax, [edi].lParam
					.if eax != NULL
						invoke QuerySymbolicLinkObject, eax
						.if eax != NULL
							push eax				; for free
							inc [edi].iSubItem
							mrm [edi].pszText, (UNICODE_STRING PTR [eax]).Buffer
							invoke SendMessage, g_hwndListView, LVM_SETITEMW, 0, edi					
							call free
						.endif
					.endif
				.endif

				add esi, sizeof DIRECTORY_BASIC_INFORMATION
			.endw
			assume edi:nothing
			assume esi:nothing
			call free				; pointer to memory is on stack
		.endif

	.else
		Fix
		invoke ErrorToStatusBar, NULL
	.endif

	ret

FillListView endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    FreeTreeViewParam                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

FreeTreeViewParam proc uses esi ebx hTvItem:HTREEITEM

; recursively frees memory associated with each tree view item

local tvi:TV_ITEM
Fix Check this proc out
	mov ebx, hTvItem
	.if ebx != NULL			; tree view may be not yet created

		lea esi, tvi
		assume esi:ptr TV_ITEM
		mov [esi]._mask, TVIF_PARAM
		mov [esi].hItem, ebx
		; Each tree view item contains associated string with directory path in lParam
		TreeView_GetItem g_hwndTreeView, esi
		.if eax == TRUE
			.if [esi].lParam != NULL
				invoke free, [esi].lParam
;				and [esi].lParam, NULL
;				TreeView_SetItem g_hwndTreeView, esi
			.endif
		.endif
		assume esi:nothing

		TreeView_GetChild g_hwndTreeView, ebx
		.if eax != NULL
			mov ebx, eax
			invoke FreeTreeViewParam, ebx
			.while TRUE
				TreeView_GetNextSibling g_hwndTreeView, ebx
				.break .if eax == NULL
				mov ebx, eax
				invoke FreeTreeViewParam, ebx
			.endw
		.endif
	.endif

	ret

FreeTreeViewParam endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                      DeleteTreeView                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DeleteTreeView proc

; Frees all memory associated with each tree view item and deletes all items

	TreeView_GetRoot g_hwndTreeView
	.if eax != NULL			; tree view may be not yet created
		invoke FreeTreeViewParam, eax
	.endif
	TreeView_DeleteAllItems g_hwndTreeView
	ret

DeleteTreeView endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                         Refresh                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Refresh proc uses esi ebx

local tvins:TV_INSERTSTRUCTW
local hRoot:HTREEITEM

	Fix Damn. windows.inc has no usable support of UNICODE. Try to fix this later.

	invoke DeleteTreeView

	; Create TreeView Root
	lea esi, tvins
	assume esi:ptr TV_INSERTSTRUCTW
	mov [esi].hParent, NULL
	mov [esi].hInsertAfter, TVI_ROOT
	mov [esi].item._mask, TVIF_TEXT + TVIF_SELECTEDIMAGE + TVIF_IMAGE + TVIF_PARAM
	mov [esi].item.pszText, offset g_uszBackSlash
	mov [esi].item.iImage, IMG_ID_DIRECTORY
	mov [esi].item.iSelectedImage, IMG_ID_DIRECTORY_OPN
	invoke malloc, sizeof g_uszBackSlash + sizeof WCHAR
	mov ebx, eax
	.if eax != NULL
		invoke wcscpy, ebx, offset g_uszBackSlash
	.endif
	mov [esi].item.lParam, ebx
	assume esi:nothing
	;TreeView_InsertItem g_hwndTreeView, edi
	invoke SendMessage, g_hwndTreeView, TVM_INSERTITEMW, 0, esi

	mov hRoot, eax


	; Start traveling through the Object Directory
	invoke FillTreeViewNode, hRoot, offset g_uszBackSlash

	TreeView_Expand g_hwndTreeView, hRoot, TVE_EXPAND

;	TreeView_Select g_hwndTreeView, hRoot, TVGN_CARET + TVGN_FIRSTVISIBLE
	TreeView_SelectItem g_hwndTreeView, hRoot

;	invoke FillListView

	ret

Refresh endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                        CompareFunc                                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CompareFunc proc uses esi lParam1:DWORD, lParam2:DWORD, uClickedColumn:UINT

; Case insensitive sort

local buffer[256]:CHAR
local buffer1[256]:CHAR
local lvi:LV_ITEM

	lea esi, lvi
	assume esi:ptr LV_ITEM
	mov [esi].imask, LVIF_TEXT
	lea eax,buffer
	mov [esi].pszText, eax
	mov [esi].cchTextMax, sizeof buffer
	m2m [esi].iSubItem, uClickedColumn
	assume esi:nothing

	invoke SendMessage, g_hwndListView, LVM_GETITEMTEXT, lParam1, esi
	invoke lstrcpy, addr buffer1, addr buffer
	invoke SendMessage, g_hwndListView, LVM_GETITEMTEXT, lParam2, esi

	.if g_uSortOrder == SORT_ASCENDING
		invoke lstrcmpi, addr buffer1, addr buffer		
	.else
		invoke lstrcmpi, addr buffer, addr buffer1
	.endif

	ret

CompareFunc endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     ListViewInsertColumn                                          
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ListViewInsertColumn proc uses esi

local lvc:LV_COLUMN

	lea esi, lvc
	assume esi:ptr LV_COLUMN

	mov [esi].imask, LVCF_TEXT + LVCF_WIDTH 
	mov [esi].pszText, $CTA0("Object Name")
	mov [esi].lx, 280
	ListView_InsertColumn g_hwndListView, LVCOL_NAME, esi

	mov [esi].pszText, $CTA0("Object Type Name")
	mov [esi].lx, 108
	ListView_InsertColumn g_hwndListView, LVCOL_TYPE, esi

	mov [esi].pszText, $CTA0("Symbolic Link")
	mov [esi].lx, 180
	ListView_InsertColumn g_hwndListView, LVCOL_LINK, esi

	assume esi:nothing
	ret

ListViewInsertColumn endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DrawXorBar proc hdc:HDC, x1:UINT, y1:UINT, uWidth:UINT, uHeight:UINT

local hbm:HBITMAP
local hbr:HBRUSH
local hbrushOld:HBRUSH

	.data
	align DWORD
	dotPattern dw	0AAAAh, 5555h, 0AAAAh, 5555h, 0AAAAh, 5555h, 0AAAAh, 5555h

	.code
	mov hbm, $invoke(CreateBitmap, 8, 8, 1, 1, addr dotPattern)
	mov hbr, $invoke(CreatePatternBrush, hbm)

;	mov eax, y1
;	add eax, g_cyXorBarIndentTop

	invoke SetBrushOrgEx, hdc, x1, y1, NULL
	mov hbrushOld, $invoke(SelectObject, hdc, hbr)

	mov eax, y1
	add eax, g_cyXorBarIndentTop

	mov ecx, uHeight
	sub ecx, g_cyXorBarIndentTop
	sub ecx, g_cyXorBarIndentBot

	invoke PatBlt, hdc, x1, eax, uWidth, ecx, PATINVERT
	invoke SelectObject, hdc, hbrushOld

	invoke DeleteObject, hbr
	invoke DeleteObject, hbm

	ret

DrawXorBar endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Splitter_OnLButtonDown proc hWnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

local pt:POINT
local hdc:HDC
local rect:RECT

	mov pt.x, $LOWORD(lParam)			; horizontal position of cursor 
	mov pt.y, $HIWORD(lParam)

	invoke GetWindowRect, hWnd, addr rect

	; convert the mouse coordinates relative to the top-left of the window
	invoke ClientToScreen, hWnd, addr pt

	mov eax, rect.left
	sub pt.x, eax					; pt.x -= rect.left

	mov eax, rect.top
	sub pt.y, eax					; pt.y -= rect.top

	; same for the window coordinates - make them relative to 0,0
	not rect.left
	inc rect.left					; -rect.left
	not rect.top
	inc rect.top					; -rect.top
	invoke OffsetRect, addr rect, rect.left, rect.top

	.if pt.x < cxSplitterIndentL
		mov pt.x, cxSplitterIndentL
	.endif
;
	mov eax, rect.right
	sub eax, cxSplitterIndentR
	.if pt.x > eax
		mov pt.x, eax
	.endif

	mov g_fDragMode, TRUE

	invoke SetCapture, hWnd

	mov hdc, $invoke(GetWindowDC, hWnd)

	mov ecx, pt.x
	sub ecx, 2
	mov eax, rect.bottom
	sub eax, 8
	invoke DrawXorBar, hdc, ecx, 4, 4, eax

	invoke ReleaseDC, hWnd, hdc

	m2m g_oldy, pt.x

	xor eax, eax
	ret

Splitter_OnLButtonDown endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Splitter_OnLButtonUp proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

local pt:POINT
local hdc:HDC
local rect:RECT

	.if g_fDragMode != FALSE

		mov pt.x, $LOWORD(lParam)			; horizontal position of cursor
		mov pt.y, $HIWORD(lParam)

		invoke GetWindowRect, hWnd, addr rect

		; convert the mouse coordinates relative to the top-left of the window
		invoke ClientToScreen, hWnd, addr pt

		mov eax, rect.left
		sub pt.x, eax					; pt.x -= rect.left

		mov eax, rect.top
		sub pt.y, eax					; pt.y -= rect.top

		; same for the window coordinates - make them relative to 0,0
		not rect.left
		inc rect.left					; -rect.left
		not rect.top
		inc rect.top					; -rect.top
		invoke OffsetRect, addr rect, rect.left, rect.top

		mov eax, pt.x
		test ax, ax
		.if SIGN?
			mov pt.x, cxSplitterIndentL
		.else
			.if ax < cxSplitterIndentL
				mov pt.x, cxSplitterIndentL
			.endif
		.endif

		mov eax, rect.right
		sub eax, cxSplitterIndentR
		.if pt.x > eax
			mov pt.x, eax
		.endif

		mov hdc, $invoke(GetWindowDC, hWnd)

		mov ecx, g_oldy
		sub ecx, 2
		mov eax, rect.bottom
		sub eax, 8
		invoke DrawXorBar, hdc, ecx, 4, 4, eax
		invoke ReleaseDC, hWnd, hdc

		m2m g_oldy, pt.x

		and g_fDragMode, FALSE

		; convert the splitter position back to screen coords.
		invoke GetWindowRect, hWnd, addr rect

		mov eax, rect.left
		add pt.x, eax				; pt.x += rect.left

		mov eax, rect.top
		add pt.y, eax				; pt.y += rect.top

		; now convert into CLIENT coordinates
		invoke ScreenToClient, hWnd, addr pt
		invoke GetClientRect, hWnd, addr rect
		m2m g_nSplitterPosX, pt.x

		; position the child controls
		mov eax, rect.bottom
		shl eax, 16
		or eax, rect.right
		invoke SendMessage, hWnd, WM_SIZE, 0, eax

		invoke ReleaseCapture
	.endif

	xor eax, eax
	ret

Splitter_OnLButtonUp endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Splitter_OnMouseMove proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

local pt:POINT
local hdc:HDC
local rect:RECT

	.if g_fDragMode != FALSE

		mov pt.x, $LOWORD(lParam)			; horizontal position of cursor 
		mov pt.y, $HIWORD(lParam)

		invoke GetWindowRect, hWnd, addr rect

		; convert the mouse coordinates relative to the top-left of the window
		invoke ClientToScreen, hWnd, addr pt

		mov eax, rect.left
		sub pt.x, eax					; pt.x -= rect.left

		mov eax, rect.top
		sub pt.y, eax					; pt.y -= rect.top

		; same for the window coordinates - make them relative to 0,0
		not rect.left
		inc rect.left					; -rect.left
		not rect.top
		inc rect.top					; -rect.top
		invoke OffsetRect, addr rect, rect.left, rect.top

		mov eax, pt.x
		and eax, 0FFFFh
		test ax, ax
		.if SIGN?
			mov pt.x, cxSplitterIndentL
		.else
			sub eax, cxSplitterIndentL
			.if SIGN?
				mov pt.x, cxSplitterIndentL
			.endif
		.endif

comment ^
		mov eax, pt.x
		and eax, 0FFFh
		sub eax, cxSplitterIndentL
		.if SIGN?
			mov pt.x, cxSplitterIndentL
		.endif
^
		mov eax, rect.right
		sub eax, cxSplitterIndentR
		.if pt.x > eax
			mov pt.x, eax
		.endif

		mov eax, g_oldy
		.if ( pt.x != eax ) && ( wParam & MK_LBUTTON )
			mov hdc, $invoke(GetWindowDC, hWnd)

			mov ecx, g_oldy
			sub ecx, 2
			mov eax, rect.bottom
			sub eax, 8
			invoke DrawXorBar, hdc, ecx, 4, 4, eax

			mov ecx, pt.x
			sub ecx, 2
			mov eax, rect.bottom
			sub eax, 8
			invoke DrawXorBar, hdc, ecx, 4, 4, eax

			invoke ReleaseDC, hWnd, hdc
			m2m g_oldy, pt.x
		.endif
	.endif

	xor eax, eax
	ret

Splitter_OnMouseMove endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                  SelectedItemToStatusBar                                          
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SelectedItemToStatusBar proc uses esi

local lvi:LV_ITEM
local tvi:TV_ITEM

	invoke GetFocus
	.if eax == g_hwndListView
		; Get selected list view item (object path)
		lea esi, lvi
		assume esi:ptr LV_ITEM
		mov [esi].imask, LVIF_PARAM
		ListView_GetNextItem g_hwndListView, -1, LVNI_SELECTED
		.if eax != -1				; nothing selected
			mov [esi].iItem, eax
			ListView_GetItem g_hwndListView, esi
			mov ecx, [esi].lParam
		.else
			mov ecx, $CTW0()		; empty string
		.endif
		assume esi:nothing
	.else
		; Get selected tree view item (directory path)
		lea esi, tvi
		assume esi:ptr TV_ITEM
		mov [esi]._mask, TVIF_PARAM
		TreeView_GetSelection g_hwndTreeView		; our tree view has always something selected, but...
		mov [esi].hItem, eax
		TreeView_GetItem g_hwndTreeView, esi
		mov ecx, [esi].lParam
		assume esi:nothing
	.endif

	invoke SendMessageW, g_hwndStatusBar, SB_SETTEXTW, 0, ecx

	ret

SelectedItemToStatusBar endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    IfItemIsDirectoryOpen                                          
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IfItemIsDirectoryOpen proc uses esi edi ebx

; If dbl-click or enter hit was over directory in the list view step into it and expand tree
; Return TRUE if done or FALSE otherwise

local lvi:LV_ITEM
local tvi:TV_ITEM
local uLvIndex:UINT
;local hTvItem:HTREEITEM
local achLvText[256]:CHAR
local achTvText[256]:CHAR

	xor ebx, ebx				; assume its not directory

	lea esi, lvi
	assume esi:ptr LV_ITEM
	mov [esi].imask, LVIF_PARAM
	ListView_GetNextItem g_hwndListView, -1, LVNI_SELECTED
	.if eax != -1				; nothing selected
		mov uLvIndex, eax
		Fix Avoid to use ListView_GetItemText twice
		ListView_GetItemText g_hwndListView, uLvIndex, 1, addr achLvText, sizeof achLvText
		invoke lstrcmp, addr achLvText, $CTA0("Directory")
		.if eax == 0
			ListView_GetItemText g_hwndListView, uLvIndex, 0, addr achLvText, sizeof achLvText
			TreeView_GetSelection g_hwndTreeView		; our tree view has always something selected, but...
			TreeView_GetChild g_hwndTreeView, eax
			mov edi, eax
;			assume eax:error							; don't touch eax
			; Enum all childs of selected tree view item
			; And find among them corresponding to the selected list view item
			lea esi, tvi
			assume esi:ptr TV_ITEM
			mov [esi]._mask, TVIF_TEXT
			lea ecx, achTvText
			mov [esi].pszText, ecx
			mov [esi].cchTextMax, sizeof achTvText
;			assume eax:nothing
			.while edi != NULL				; break if no more childs
				mov [esi].hItem, edi
				TreeView_GetItem g_hwndTreeView, esi
				.if eax == TRUE
					invoke lstrcmp, addr achLvText, addr achTvText
					.if eax == 0
						; found
						TreeView_Expand g_hwndTreeView, edi, TVE_EXPAND
						TreeView_SelectItem g_hwndTreeView, edi
						inc ebx				; set flag
						.break
					.endif
				.endif
				TreeView_GetNextSibling g_hwndTreeView, edi
				mov edi, eax
			.endw
		.endif
	.endif
	assume esi:nothing

	mov eax, ebx
	ret

IfItemIsDirectoryOpen endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       Wnd_OnNotify                                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnNotify proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	mov edi, lParam
	mov eax, (NMHDR PTR [edi]).hwndFrom
	.if eax == g_hwndListView
		; Notify message from List
		.if [NMHDR PTR [edi]].code == LVN_COLUMNCLICK

			assume edi:ptr NM_LISTVIEW
			mov eax, g_uPrevClickedColumn
			.if [edi].iSubItem != eax
				; Remove bitmap from prev header column
				invoke ImageToHeaderItem, g_hwndHeader, g_uPrevClickedColumn, NULL
				mov g_uSortOrder, SORT_NOT_YET
				mrm g_uPrevClickedColumn, [edi].iSubItem
			.endif

			.if ( g_uSortOrder == SORT_NOT_YET ) || ( g_uSortOrder == SORT_DESCENDING )
				mov g_uSortOrder, SORT_ASCENDING
				invoke ImageToHeaderItem, g_hwndHeader, [edi].iSubItem, g_hbmpHeaderArrowDown
			.else
				mov g_uSortOrder, SORT_DESCENDING
				invoke ImageToHeaderItem, g_hwndHeader, [edi].iSubItem, g_hbmpHeaderArrowUp
			.endif
			ListView_SortItemsEx g_hwndListView, offset CompareFunc, [edi].iSubItem
			assume edi:nothing

		.elseif [NMHDR PTR [edi]].code == NM_DBLCLK

			invoke IfItemIsDirectoryOpen
			.if eax == FALSE
				invoke ShowObjectProperties
			.endif

		.elseif [NMHDR PTR [edi]].code == LVN_KEYDOWN
			mov eax, lParam
			.if [LV_KEYDOWN PTR [eax]].wVKey == VK_RETURN
				ListView_GetSelectedCount g_hwndListView
				.if eax != 0
					invoke IfItemIsDirectoryOpen
					.if eax == FALSE
						invoke ShowObjectProperties
					.endif
				.endif
			.elseif [LV_KEYDOWN PTR [eax]].wVKey == VK_TAB
				invoke SetFocus, g_hwndTreeView
			.endif

		.elseif [NMHDR PTR [edi]].code == LVN_ITEMCHANGED
			invoke SelectedItemToStatusBar
		.elseif [NMHDR PTR [edi]].code == NM_SETFOCUS
			invoke SelectedItemToStatusBar
		.endif

	.elseif eax == g_hwndTreeView
		; Notify message from Tree
		.if [NMHDR PTR [edi]].code == TVN_SELCHANGED
			invoke FillListView
			invoke SelectedItemToStatusBar

		.elseif [NMHDR PTR [edi]].code == TVN_KEYDOWN
			mov eax, lParam
			.if [TV_KEYDOWN PTR [eax]].wVKey == VK_RETURN
				invoke ShowObjectProperties
			.elseif [TV_KEYDOWN PTR [eax]].wVKey == VK_TAB
				invoke SetFocus, g_hwndListView
			.endif

		.elseif [NMHDR PTR [edi]].code == NM_SETFOCUS
				invoke SelectedItemToStatusBar
		.endif

	.endif

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnNotify endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnMouseMove proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	invoke Splitter_OnMouseMove, hWnd, uMsg, wParam, lParam

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnMouseMove endp


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnSizing proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)

	mov ecx, lParam
	mov eax, (RECT PTR [ecx]).right
	sub eax, (RECT PTR [ecx]).left		; main window wide
	sub eax, cxSplitterIndentR
	.if eax < g_nSplitterPosX
		mov g_nSplitterPosX, eax
	.endif

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnSizing endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnSize proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
WND_PROC_LOCAL rect:RECT

	mov ecx, $HIWORD(lParam)
	invoke MoveWindow, g_hwndStatusBar, 0, ecx, $LOWORD(lParam), ecx, TRUE

	invoke GetClientRect, g_hwndStatusBar, addr rect



	mov edx, $HIWORD(lParam)
	sub edx, rect.bottom	
	invoke MoveWindow, g_hwndChild1, 0, 0, g_nSplitterPosX, edx, TRUE

	mov edx, $HIWORD(lParam)
	sub edx, rect.bottom	

	mov ecx, g_nSplitterPosX
	add ecx, xSplitterThickness

	mov eax, $LOWORD(lParam)
	sub eax, g_nSplitterPosX
	sub eax, xSplitterThickness		; nMainWidth - nSplitterPosX - xSplitterThickness
	invoke MoveWindow, g_hwndChild2, ecx, 0, eax, edx, TRUE

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnSize endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnLButtonDown proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	invoke Splitter_OnLButtonDown, hWnd, uMsg, wParam, lParam

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnLButtonDown endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnLButtonUp proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	invoke Splitter_OnLButtonUp, hWnd, uMsg, wParam, lParam

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnLButtonUp endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnClose proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	invoke DestroyWindow, hWnd

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnClose endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                   Wnd_OnSysColorChange                                            
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnSysColorChange proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	invoke DeleteHeaderBitmap
	invoke LoadHeaderBitmap

	mov ebx, $invoke(GetSysColor, COLOR_WINDOW)
	invoke ImageList_SetBkColor, g_hImageList, ebx
	TreeView_SetBkColor g_hwndTreeView, ebx

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnSysColorChange endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    Wnd_OnGetMinMaxInfo                                            
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnGetMinMaxInfo proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	mov ecx, lParam
	mov (MINMAXINFO PTR [ecx]).ptMinTrackSize.x, 350
	mov (MINMAXINFO PTR [ecx]).ptMinTrackSize.y, 153

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnGetMinMaxInfo endp

comment ^
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                   Wnd_OnContextMenu                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnContextMenu proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	.elseif eax == WM_CONTEXTMENU

		mov eax, lParam
		mov ecx, eax
		and eax, 0FFFFh
		shr ecx, 16
		invoke TrackPopupMenu, g_hPopupMenu, TPM_LEFTALIGN, eax, ecx, NULL, hWnd, NULL

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnContextMenu endp
^
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     Wnd_OnCreate                                                  
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnCreate proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD
;WND_PROC_LOCAL rect:RECT

	mov g_nSplitterPosX, 160
	mov g_oldy, -4
	and g_fMoved, FALSE
	and g_fDragMode, FALSE

	mrm g_hWnd, hWnd

	or g_uPrevClickedColumn, -1
	mov g_uSortOrder, SORT_NOT_YET

	; Set Icon
	invoke LoadIcon, g_hInstance, IDI_ICON
	invoke SendMessage, hWnd, WM_SETICON, ICON_BIG, eax

;	invoke SetWindowText, hWnd, $CTA0("Object Explorer")

	; Add "About..." to sys menu
	invoke GetSystemMenu, hWnd, FALSE
	mov esi, eax
	invoke InsertMenu, esi, -1, MF_BYPOSITION + MF_SEPARATOR, 0, 0
	invoke InsertMenu, esi, -1, MF_BYPOSITION + MF_STRING, IDM_ABOUT, offset g_szAbout


	; Create Tree View
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("SysTreeView32"), NULL, \
				WS_CHILD + WS_VISIBLE + WS_BORDER + TVS_HASLINES + TVS_HASBUTTONS + TVS_LINESATROOT, \
				0, 0, 0, 0, hWnd, 0, g_hInstance, 0
	mov g_hwndTreeView, eax

	invoke SetFocus, g_hwndTreeView


	; Create List View
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("SysListView32"), NULL, \
				WS_CHILD + WS_VISIBLE + WS_BORDER + LVS_REPORT + LVS_SINGLESEL + LVS_SHOWSELALWAYS, \
				0, 0, 0, 0, hWnd, 0, g_hInstance, 0
	mov g_hwndListView, eax

	; Change ListView style
	ListView_SetExtendedListViewStyle g_hwndListView, LVS_EX_GRIDLINES + LVS_EX_FULLROWSELECT


	; Get List View Header
	mov g_hwndHeader, $invoke(SendMessage, g_hwndListView, LVM_GETHEADER, 0, 0)

	invoke GetWindowLong, g_hwndHeader, GWL_STYLE
	or eax, HDS_HOTTRACK
	invoke SetWindowLong, g_hwndHeader, GWL_STYLE, eax


	; Create Image List
	mov g_hImageList, $invoke(ImageList_Create, 16, 16, ILC_COLOR24 + ILC_MASK, IMG_ID_MAX, 0)
	invoke LoadBitmap, g_hInstance, IDI_BITMAP
	push eax				; for DeleteObject
	invoke ImageList_AddMasked, g_hImageList, eax, Magenta
	call DeleteObject

	TreeView_SetImageList g_hwndTreeView, g_hImageList, TVSIL_NORMAL
	ListView_SetImageList g_hwndListView, g_hImageList, LVSIL_SMALL


comment ^
	; Create popup menu
	invoke CreatePopupMenu
	mov g_hPopupMenu,eax

	invoke AppendMenu, g_hPopupMenu, MF_STRING, IDM_REFRESH, $CTA0("Refresh")
^

	; Create status bar
	mov g_hwndStatusBar, $invoke(CreateStatusWindow, WS_CHILD + WS_VISIBLE + SBS_SIZEGRIP, NULL, hWnd, IDC_STATUSBAR)



	invoke GetSystemMetrics, SM_CYCAPTION
	add eax, 2									; looks better
	mov g_cyXorBarIndentTop, eax

	sub esp, sizeof RECT
	invoke GetClientRect, g_hwndStatusBar, esp
	mov eax, (RECT PTR [esp]).bottom			; status bar height
	add eax, 2									; looks better
	mov g_cyXorBarIndentBot, eax
	add esp, sizeof RECT

	; Load up/down arrows
	invoke LoadHeaderBitmap

	invoke ListViewInsertColumn

	invoke Refresh

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnCreate endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnDestroy proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD
Fix
	invoke DeleteListView
	invoke DeleteTreeView

	invoke DeleteHeaderBitmap
;	invoke DestroyMenu, g_hPopupMenu

	invoke ImageList_Destroy, g_hImageList

	invoke DestroyWindow, g_hwndChild1
	invoke DestroyWindow, g_hwndChild2

	invoke PostQuitMessage, 0

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnDestroy endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       Wnd_OnCommand                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnCommand proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	mov eax, $LOWORD(wParam)
	.if eax == IDM_HELP
;		invoke MessageBox, hWnd, $CTA0("Not so easy ;-\}"), $CTA0("Need help?"), MB_ICONINFORMATION
		CTA  "Hit ENTER or double click on object to see its properties.\n", g_szHelpMessage
		CTA  "Hit TAB to toggle focus between the spans.\n"
		CTA0 "Hit ESC to exit.\n"
		invoke GetFocus
		push eax
		invoke MessageBox, hWnd, offset g_szHelpMessage, $CTA0("Need help?"), MB_ICONINFORMATION
		call SetFocus
	.elseif eax == IDM_REFRESH
		invoke Refresh
	.elseif eax == IDM_EXIT
		; ask only if user hit Esc key
		invoke GetFocus
		push eax
		invoke MessageBox, hWnd, $CTA0("Sure want to exit?"), $CTA0("Exit Confirmation."), MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON1
		.if eax == IDYES
			invoke SendMessage, hWnd, WM_SYSCOMMAND, SC_CLOSE, NULL
		.endif
		call SetFocus
	.endif

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnCommand endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Wnd_OnSysCommand proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	.if wParam == IDM_ABOUT
		invoke GetFocus
		push eax
		invoke MessageBox, hWnd, addr g_szWrittenBy, addr g_szAbout, MB_OK + MB_ICONINFORMATION
		call SetFocus
	.else
		jmp _DefWindowProc
	.endif

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

Wnd_OnSysCommand endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
comment ^
OnXXX proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

option PROLOGUE:NONE
option EPILOGUE:NONE

; Add locals here (only one WND_PROC_LOCAL)
;WND_PROC_LOCAL dwLocal1:DWORD, dwLocal2:DWORD

	; Add code here

	pop eax
	jmp eax							; jmp LeaveWndProc0

option PROLOGUE:PROLOGUEDEF
option EPILOGUE:EPILOGUEDEF

OnXXX endp
^
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

WndProc proc uses esi edi ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

WND_PROC_LOCAL

	push LeaveWndProc0
	mov eax, uMsg
	IF_MSG	WM_MOUSEMOVE,		Wnd_OnMouseMove
	IF_MSG	WM_SIZING,			Wnd_OnSizing
	IF_MSG	WM_SIZE,			Wnd_OnSize
	IF_MSG	WM_LBUTTONDOWN,		Wnd_OnLButtonDown
	IF_MSG	WM_LBUTTONUP,		Wnd_OnLButtonUp
	IF_MSG	WM_CLOSE,			Wnd_OnClose
	IF_MSG	WM_DESTROY,			Wnd_OnDestroy
	IF_MSG	WM_CREATE,			Wnd_OnCreate
	IF_MSG	WM_NOTIFY,			Wnd_OnNotify
	IF_MSG	WM_COMMAND,			Wnd_OnCommand
	IF_MSG	WM_SYSCOMMAND,		Wnd_OnSysCommand
	IF_MSG	WM_SYSCOLORCHANGE,	Wnd_OnSysColorChange
	IF_MSG	WM_GETMINMAXINFO, 	Wnd_OnGetMinMaxInfo
;	IF_MSG	WM_CONTEXTMENU, 	Wnd_OnContextMenu

	_DefWindowProc::
	pop eax					; remove offset LeaveWndProc0 from stack
	invoke DefWindowProc, hWnd, uMsg, wParam, lParam		
	ret

	LeaveWndProc0::
	xor eax, eax				; return FALSE
	LeaveWndProc::
	ret

WndProc endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     EnablePrivilege                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

EnablePrivilege proc pszPrivilegeName:LPSTR

local fOk:BOOL
local hProcessToken:HANDLE
local tp:TOKEN_PRIVILEGES

	and fOk, FALSE

	invoke GetCurrentProcess
	push eax
	invoke OpenProcessToken, eax, TOKEN_QUERY + TOKEN_ADJUST_PRIVILEGES, esp
	pop hProcessToken
	.if eax != 0
		invoke LookupPrivilegeValue, NULL, pszPrivilegeName, addr tp.Privileges.Luid
		.if eax != 0

			mov tp.PrivilegeCount, 1
			mov tp.Privileges.Attributes, SE_PRIVILEGE_ENABLED
			invoke AdjustTokenPrivileges, hProcessToken, FALSE, addr tp, 0, NULL, NULL
			.if eax != 0
				inc fOk
			.endif
		.endif
		invoke CloseHandle, hProcessToken
	.endif

	mov eax, fOk

	ret

EnablePrivilege endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

start:

	mov g_hInstance, $invoke(GetModuleHandle, NULL)
	mov g_pszCommandLine, $invoke(GetCommandLine)

	lea ecx, g_apfnZwOpenXxx
	mov eax, ZwOpenDirectoryObject
	mov eax, [eax+2]
	m2m [ecx][PFN_ID_ZwOpenDirectoryObject * sizeof LPVOID], [eax]

	mov eax, ZwOpenEvent
	mov eax, [eax+2]
	m2m [ecx][PFN_ID_ZwOpenEvent * sizeof LPVOID], [eax]

	mov eax, ZwOpenKey
	mov eax, [eax+2]
	m2m [ecx][PFN_ID_ZwOpenKey * sizeof LPVOID], [eax]

	mov eax, ZwOpenMutant
	mov eax, [eax+2]
	m2m [ecx][PFN_ID_ZwOpenMutant * sizeof LPVOID], [eax]

	mov eax, ZwOpenSection
	mov eax, [eax+2]
	m2m [ecx][PFN_ID_ZwOpenSection * sizeof LPVOID], [eax]

	mov eax, ZwOpenSemaphore
	mov eax, [eax+2]
	m2m [ecx][PFN_ID_ZwOpenSemaphore * sizeof LPVOID], [eax]	

	mov eax, ZwOpenSymbolicLinkObject
	mov eax, [eax+2]
	m2m [ecx][PFN_ID_ZwOpenSymbolicLinkObject * sizeof LPVOID], [eax]

	mov eax, ZwOpenTimer
	mov eax, [eax+2]
	m2m [ecx][PFN_ID_ZwOpenTimer * sizeof LPVOID], [eax]

	invoke EnablePrivilege, $CTA0("SeSecurityPrivilege")
	invoke EnablePrivilege, $CTA0("SeTakeOwnershipPrivilege")

	invoke WinMain, g_hInstance, NULL, g_pszCommandLine, SW_SHOWDEFAULT
	invoke ExitProcess, 0
	invoke InitCommonControls

end start

:make

set exe=ObjExp

if exist %exe%.exe del %exe%.exe

if exist rsrc.obj goto final
	\masm32\bin\rc /v rsrc.rc
	\masm32\bin\cvtres /machine:ix86 rsrc.res
	if errorlevel 0 goto final
		pause
		exit

:final
if exist rsrc.res del rsrc.res

\masm32\bin\ml /nologo /c /coff %exe%.bat
\masm32\bin\link /nologo /subsystem:windows /merge:POINTERS=.rdata %exe%.obj rsrc.obj
rem \masm32\bin\link /nologo /subsystem:windows /ignore:4078 

del %exe%.obj

echo.
pause
