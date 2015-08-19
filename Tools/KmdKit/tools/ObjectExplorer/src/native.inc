;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; NTSTATUS
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

NTSTATUS	typedef	SDWORD
PNTSTATUS	typedef	PTR SDWORD

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; Counted String
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

_STRING STRUCT
	_Length			WORD	?
	MaximumLength	WORD	?
	Buffer			DWORD	?	; PCHAR
_STRING ENDS
PSTRING typedef PTR _STRING

ANSI_STRING equ <_STRING>
PANSI_STRING typedef PTR _STRING

;typedef STRING ANSI_STRING;
;typedef PSTRING PANSI_STRING;

OEM_STRING equ <_STRING>
POEM_STRING typedef PTR _STRING

;typedef STRING OEM_STRING;
;typedef PSTRING POEM_STRING;

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; CONSTCounted String
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CSTRING STRUCT
	_Length		WORD	?
	MaximumLength	WORD	?
	Buffer			DWORD	?	; CONST char *
CSTRING ENDS
PCSTRING typedef PTR CSTRING

ANSI_NULL	equ 0
comment ^
typedef STRING CANSI_STRING;
typedef PSTRING PCANSI_STRING;
^
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; Unicode strings are counted 16-bit character strings. If they are
; NULL terminated, Length does not include trailing NULL.
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IFNDEF UNICODE_STRING
	UNICODE_STRING STRUCT
		_Length			WORD	?		; len of string in bytes (not chars)
		MaximumLength	WORD	?		; len of Buffer in bytes (not chars)
		Buffer			PWSTR	?		; pointer to string
	UNICODE_STRING ENDS
	PUNICODE_STRING	typedef	PTR UNICODE_STRING
ENDIF

UNICODE_NULL	equ 0

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; Valid values for the Attributes field
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

OBJ_INHERIT             equ 00000002h
OBJ_PERMANENT           equ 00000010h
OBJ_EXCLUSIVE           equ 00000020h
OBJ_CASE_INSENSITIVE    equ 00000040h
OBJ_OPENIF              equ 00000080h
OBJ_OPENLINK            equ 00000100h
OBJ_KERNEL_HANDLE       equ 00000200h
OBJ_VALID_ATTRIBUTES    equ 000003F2h

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; Object Attributes structure
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

OBJECT_ATTRIBUTES STRUCT		; sizeof = 18h
	dwLength					DWORD			? ; original name Length
	RootDirectory				HANDLE			?
	ObjectName					PUNICODE_STRING	?
	Attributes					DWORD			?
	SecurityDescriptor			PVOID			? ; Points to type SECURITY_DESCRIPTOR
	SecurityQualityOfService	PVOID			? ; Points to type SECURITY_QUALITY_OF_SERVICE
OBJECT_ATTRIBUTES ENDS
POBJECT_ATTRIBUTES typedef OBJECT_ATTRIBUTES

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; VOID
; InitializeObjectAttributes(
;     OUT POBJECT_ATTRIBUTES p,
;     IN PUNICODE_STRING n,
;     IN ULONG a,
;     IN HANDLE r,
;     IN PSECURITY_DESCRIPTOR s
;     )
;
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;#define InitializeObjectAttributes( p, n, a, r, s ) { \
;    (p)->Length = sizeof( OBJECT_ATTRIBUTES );          \
;    (p)->RootDirectory = r;                             \
;    (p)->Attributes = a;                                \
;    (p)->ObjectName = n;                                \
;    (p)->SecurityDescriptor = s;                        \
;    (p)->SecurityQualityOfService = NULL;               \
;    }

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        
$IsAddr2 MACRO Operand:REQ
	local a
	a = 0

	IF @SizeStr(<Operand>) GT 5		
		IFIDNI <addr >, @SubStr(<Operand>, 1 , 5)
			a = 1
		ENDIF
	ENDIF

	IF a
        EXITM <-1>
    ELSE
        EXITM <0>
    ENDIF
ENDM

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

InitializeObjectAttributes MACRO p:REQ, n:REQ, a:REQ, r:REQ, s:REQ

;; Be very carefull with this macro !!!
;; It can contain some hiden bugs !!!
;; In ambiguous cases fill OBJECT_ATTRIBUTES structure manually

	local adr, reax, reax
	reax = 0
	recx = 0

	IF (OPATTR (p)) AND 00010000y
		;; is a register value
		IFDIFI <p>, <ecx>		;; not ecx
			mov ecx, p
		ENDIF
	ELSE
		IF $IsAddr2(p)
			adr SUBSTR <p>, 6
			IF $IsStack(adr)			;; is relative to SS
				lea ecx, adr
				recx = 1				;; no more eax
			ELSE
				mov ecx, offset adr
			ENDIF
		ENDIF
	ENDIF

	PUSHCONTEXT ASSUMES
	assume ecx:ptr OBJECT_ATTRIBUTES
	mov [ecx].dwLength, sizeof OBJECT_ATTRIBUTES

	IF (OPATTR (r)) AND 00000010y
		;; is a memory variable or has a relocatable data label
		push r
		pop [ecx].RootDirectory
	ELSE
		IF r EQ 0
			and [ecx].RootDirectory, 0	;; NULL
		ELSE
			mov [ecx].RootDirectory, r
		ENDIF
	ENDIF

	IF (OPATTR (a)) AND 00000010y
		;; is a memory variable or has a relocatable data label
		push a
		pop [ecx].Attributes
	ELSE
		IF a EQ 0
			and [ecx].Attributes, 0
		ELSE
			mov [ecx].Attributes, a
		ENDIF
	ENDIF

	IF (OPATTR (n)) AND 00010000y
		;; is a register value
		;IFDIFI <n>, <eax>		;; not eax
			mov [ecx].ObjectName, n
		;ENDIF
	ELSE
		IF $IsAddr2(n)
			adr SUBSTR <n>, 6
			IF $IsStack(adr)			;; is relative to SS
				lea eax, adr
				mov [ecx].ObjectName, eax
				reax = 1				;; no more eax
			ELSE
				mov [ecx].ObjectName, offset adr
			ENDIF

		ELSEIF (OPATTR (n)) AND 00000010y
			;; is a memory variable or has a relocatable data label
			push n
			pop [ecx].ObjectName
		ENDIF
	ENDIF

	IF (OPATTR (s)) AND 00000010y
		;; is a memory variable or has a relocatable data label
		push s
		pop [ecx].SecurityDescriptor
	ELSE
		IF s EQ 0
			and [ecx].SecurityDescriptor, 0	;; NULL
		ELSE
			mov [ecx].SecurityDescriptor, s
		ENDIF
	ENDIF

	and [ecx].SecurityQualityOfService, 0	;; NULL
	assume ecx:nothing
	POPCONTEXT ASSUMES
ENDM


; Object Manager Object Type Specific Access Rights.

OBJECT_TYPE_CREATE		equ 0001

OBJECT_TYPE_ALL_ACCESS	equ (STANDARD_RIGHTS_REQUIRED or 1)

; Object Manager Directory Specific Access Rights.

DIRECTORY_QUERY                 equ 0001
DIRECTORY_TRAVERSE              equ 0002
DIRECTORY_CREATE_OBJECT         equ 0004
DIRECTORY_CREATE_SUBDIRECTORY   equ 0008

DIRECTORY_ALL_ACCESS			equ (STANDARD_RIGHTS_REQUIRED or 0Fh)

; Object Manager Symbolic Link Specific Access Rights.

SYMBOLIC_LINK_QUERY				equ 0001

SYMBOLIC_LINK_ALL_ACCESS		equ (STANDARD_RIGHTS_REQUIRED or 1)

DUPLICATE_CLOSE_SOURCE      equ 00000001  ; winnt
DUPLICATE_SAME_ACCESS       equ 00000002  ; winnt
DUPLICATE_SAME_ATTRIBUTES   equ 00000004

DIRECTORY_BASIC_INFORMATION STRUCT
	ObjectName		UNICODE_STRING <>
	ObjectTypeName	UNICODE_STRING	<>
DIRECTORY_BASIC_INFORMATION ENDS
PDIRECTORY_BASIC_INFORMATION typedef PTR DIRECTORY_BASIC_INFORMATION

; Define the base asynchronous I/O argument types

IO_STATUS_BLOCK STRUCT		; sizeof = 08h
	Status		SDWORD		?	; 0000h  NTSTATUS
	Information	DWORD		?	; 0004h
IO_STATUS_BLOCK ENDS
PIO_STATUS_BLOCK typedef PTR IO_STATUS_BLOCK

;/ Event Specific Access Rights.

EVENT_QUERY_STATE       equ 0001
EVENT_MODIFY_STATE      equ 0002  ; winnt
EVENT_ALL_ACCESS		equ (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or 3) ; winnt

; Semaphore Specific Access Rights.

SEMAPHORE_QUERY_STATE       equ 0001
SEMAPHORE_MODIFY_STATE      equ 0002  ; winnt

SEMAPHORE_ALL_ACCESS		equ (STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or 3) ; winnt

; Define the access check value for any access
;
; The FILE_READ_ACCESS and FILE_WRITE_ACCESS constants are also defined in
; ntioapi.h as FILE_READ_DATA and FILE_WRITE_DATA. The values for these
; constants *MUST* always be in sync.
;
; FILE_SPECIAL_ACCESS is checked by the NT I/O system the same as FILE_ANY_ACCESS.
; The file systems, however, may add additional access checks for I/O and FS controls
; that use this value.

FILE_ANY_ACCESS			equ 0
FILE_SPECIAL_ACCESS		equ FILE_ANY_ACCESS
FILE_READ_ACCESS		equ 1	; file & pipe
FILE_WRITE_ACCESS		equ 2	; file & pipe

;typedef enum _OBJECT_INFORMATION_CLASS {
ObjectBasicInformation			equ 0	; Y N
ObjectNameInformation			equ 1	; Y N
ObjectTypeInformation			equ 2	; Y N
ObjectAllTypesInformation		equ 3	; Y N
ObjectHandleInformation			equ 4	; Y Y

OBJECT_BASIC_INFORMATION STRUCT			; Information Class 0
	Attributes					DWORD		?
	GrantedAccess				ACCESS_MASK	?
	HandleCount					DWORD		?
	PointerCount				DWORD		?
	PagedPoolUsage				DWORD		?
	NonPagedPoolUsage			DWORD		?
	Reserved					DWORD 3 dup(?)
	NameInformationLength		DWORD		?
	TypeInformationLength		DWORD		?
	SecurityDescriptorLength	DWORD		?
	CreateTime					LARGE_INTEGER	<>
OBJECT_BASIC_INFORMATION ENDS
POBJECT_BASIC_INFORMATION typedef ptr OBJECT_BASIC_INFORMATION

HANDLE_FLAG_INHERIT				equ 1
HANDLE_FLAG_PROTECT_FROM_CLOSE	equ 2
PERMANENT						equ 10h
EXCLUSIVE						equ 20h		; different encoding than in SYSTEM_OBJECT_INFORMATION

OBJECT_NAME_INFORMATION STRUCT			; Information Class 1
	_Name					UNICODE_STRING	<>
OBJECT_NAME_INFORMATION ENDS
POBJECT_NAME_INFORMATION typedef ptr OBJECT_NAME_INFORMATION

OBJECT_TYPE_INFORMATION STRUCT			; Information Class 2 (sizeof = 60h)
	_Name					UNICODE_STRING	<>
	ObjectCount				DWORD		?		; 008h
	HandleCount				DWORD		?		; 00Ch
	Reserved1				DWORD 4 dup(?)		; 010h
	PeakObjectCount			DWORD		?		; 020h
	PeakHandleCount			DWORD		?		; 024h
	Reserved2				DWORD 4 dup(?)		; 034h
	InvalidAttributes		DWORD		?		; 038h
	GenericMapping			GENERIC_MAPPING	<>	; 03Ch
	ValidAccess				DWORD		?		; 04Ch
	Unknown					BYTE		?		; 050h
	MaintainHandleDatabase	BYTE	?			; BOOLEAN
							db 2 dup(?)			; padding
	PoolType				DWORD	?			; 054h POOL_TYPE
	PagedPoolUsage			DWORD	?			; 058h
	NonPagedPoolUsage		DWORD	?			; 05Ch
OBJECT_TYPE_INFORMATION ENDS
POBJECT_TYPE_INFORMATION typedef ptr OBJECT_TYPE_INFORMATION


