;@echo off
;goto make

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;
; RamDisk
;
; Written by Four-F (four-f@mail.ru)
;
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.386
.model flat, stdcall
option casemap:none

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                  I N C L U D E   F I L E S                                        
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

include \masm32\include\w2k\ntstatus.inc
include \masm32\include\w2k\ntddk.inc
include \masm32\include\winioctl.inc
include \masm32\include\w2k\ntoskrnl.inc

includelib \masm32\lib\w2k\ntoskrnl.lib

include \masm32\Macros\Strings.mac

include RamDisk.inc
include ..\common.inc

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     C O N S T A N T S                                             
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.const
CCOUNTED_UNICODE_STRING	"\\Device\\RamDisk0", g_usDeviceName, 4

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                I N I T I A L I Z E D  D A T A                                     
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.data?

COUNTED_UNICODE_STRING	"\\DosDevices\\?:", g_usSymbolicLinkName, 4

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                              U N I N I T I A L I Z E D  D A T A                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.data?
g_fRamDiskCreated		BOOL	?
g_fSymbolicLinkCreated	BOOL	?

g_pImage				PVOID	?
g_nOpenCount			DWORD	?

;g_nRootDirectoryEntries	DWORD	?
;g_nSectorsPerCluster	DWORD	?
;g_nDiskSize				DWORD	?

g_CreateParams			CREATE_PARAMS	<>

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                            N O N D I S C A R D A B L E   C O D E                                  
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.code

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     FormatBootSector                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

FormatBootSector proc uses edi

; Places an image of an empty FAT drive in the memory buffer containing the ramdisk.
; This is complicated somewhat by the fact that the FAT can have either 12 or 16 bit entries,
; based on the size of the drive.

local BootSector:PBOOT_SECTOR			; = (PBOOT_SECTOR) m_Image;
;local FatEntries:DWORD
local FatType:DWORD
local FatSectorCount:DWORD
local RootDir:PDIR_ENTRY				; Pointer to first entry in root dir    
local FirstFatSector:PUCHAR

local nSectors:DWORD

	.if g_pImage != NULL
		mov edi, g_pImage

		invoke memset, edi, 0, g_CreateParams.nDiskSize

		assume edi:ptr BOOT_SECTOR

		mov [edi].Jump[0], 0EBh
		mov [edi].Jump[1], 3Ch
		mov [edi].Jump[2], 90h

		invoke strncpy, addr [edi].OemName, $CTA0("Four-F  "), 8
		mov [edi].BytesPerSector, BYTES_PER_SECTOR
		mov [edi].ResSectors, 1
		mov [edi].FATs, 1

		mov eax, g_CreateParams.nRootDirectoryEntries
		mov [edi].RootDirEntries, ax

		; Calculate the number of sectors on the disk. If there are few enough
		; sectors to fit in a USHORT, it goes in bsSectors. Otherwise bsSectors
		; must be zero, and the number of sectors goes in bsHugeSectors. The cutoff
		; as far as disk size is around 32 Meg.

		mov eax, g_CreateParams.nDiskSize
		mov ecx, BYTES_PER_SECTOR
		xor edx, edx
		div ecx
		mov nSectors, eax
		.if eax > 0FFFFh
			; Too many sectors for bsSectors.  Use bsHugeSectors.
			and [edi].Sectors, 0
			mov [edi].HugeSectors, eax
		.else
			; Small number of sectors.  Use bsSectors.
			mov [edi].Sectors, ax
			and [edi].HugeSectors, 0
		.endif
	
		mov [edi].Media, RAMDISK_MEDIA_TYPE

		mov eax, g_CreateParams.nSectorsPerCluster
		mov [edi].SectorsPerCluster, al

		; Calculate number of sectors required for FAT

;	FatEntries =
;		(nSectors - [edi].ResSectors - [edi].RootDirEnts / DIR_ENTRIES_PER_SECTOR) / [edi].SecPerClus + 2

		movzx eax, [edi].RootDirEntries
		mov ecx, DIR_ENTRIES_PER_SECTOR
		xor edx, edx
		div ecx
		mov ecx, nSectors
		sub ecx, eax
		movzx eax, [edi].ResSectors
		sub ecx, eax
		mov eax, ecx
		xor ecx, ecx
		mov cl, [edi].SectorsPerCluster
		div ecx
		inc eax
		inc eax

		; Choose between 12 and 16 bit FAT based on number of clusters we need to map

		.if eax > 4087
			mov FatType, 16

			lea ecx, [eax+eax+511]
			shr ecx, 9					; (FatEntries * 2 + 511) / 512
			sub eax, ecx

			lea ecx, [eax+eax+511]
			shr ecx, 9					; (FatEntries * 2 + 511) / 512
		.else
			mov FatType, 12

			lea ecx, [eax+eax*2+1]
			shr ecx, 1
			add ecx, 511
			shr ecx, 9					; (((FatEntries * 3 + 1) / 2) + 511) / 512
			sub eax, ecx

			lea ecx, [eax+eax*2+1]
			shr ecx, 1
			add ecx, 511
			shr ecx, 9					; (((FatEntries * 3 + 1) / 2) + 511) / 512
		.endif

		mov FatSectorCount, ecx
		mov [edi].FatSectors, cx
		mov [edi].SectorsPerTrack, SECTORS_PER_TRACK
		mov [edi].Heads, TRACKS_PER_CYLINDER
		mov [edi].BootSignature, 29h
		mov [edi].VolumeID, 12345678h
		invoke strncpy, addr [edi]._Label, $CTA0("RamDisk    "), 11
		.if FatType == 12
			mov eax, $CTA0("FAT12   ")
		.elseif FatType == 16
			mov eax, $CTA0("FAT16   ")
		.endif
		invoke strncpy, addr [edi].FileSystemType, eax, 8
	
		mov [edi].Sig2[0], 055h
		mov [edi].Sig2[1], 0AAh

		assume edi:nothing

		; The FAT is located immediately following the boot sector.

		add edi, sizeof BOOT_SECTOR
		; edi -> FirstFatSector
		mov byte ptr [edi][0], RAMDISK_MEDIA_TYPE
		or byte ptr [edi][1], 0FFh
		or byte ptr [edi][2], 0FFh
		.if FatType == 16
			or byte ptr [edi][3], 0FFh
		.endif

		; The Root Directory follows the FAT

		mov eax, FatSectorCount
		inc eax
		shl eax, 9
		add eax, g_pImage
		mov edi, eax
		assume edi:ptr DIR_ENTRY
		invoke strcpy, addr [edi]._Name, $CTA0("RAM Disk")
;		invoke strcpy, addr [edi].Extension, $CTA0("   ")
		mov [edi].Attributes, DIR_ATTR_VOLUME
		assume edi:nothing

	.endif

	ret

FormatBootSector endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    DeleteSymbolicLink                                             
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DeleteSymbolicLink proc

	.if g_fSymbolicLinkCreated
		invoke IoDeleteSymbolicLink, addr g_usSymbolicLinkName
		and g_fSymbolicLinkCreated, FALSE
	.endif

	ret

DeleteSymbolicLink endp	

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       CreateRamDisk                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CreateRamDisk proc uses esi pDriverObject:PDRIVER_OBJECT

local status:NTSTATUS
local pDeviceObject:PDEVICE_OBJECT

	mov status, STATUS_DEVICE_CONFIGURATION_ERROR
	and pDeviceObject, NULL

	lea esi, g_CreateParams
	.if esi != NULL
		assume esi:ptr CREATE_PARAMS

		; Check params
		mov ecx, [esi].nSectorsPerCluster
		lea ecx, [ecx*4+ecx]			; *5
		Fix
		shl ecx, 0Ah					; *2*512
		mov eax, [esi].dwDriveLetter				
		.if (al < 'A') || (al > 'Z') || ([esi].nRootDirectoryEntries < 10) || ([esi].nSectorsPerCluster == 0) || ([esi].nDiskSize < ecx)
			mov status, STATUS_INVALID_PARAMETER
		.else

			invoke IoCreateDevice, pDriverObject, 0, addr g_usDeviceName, FILE_DEVICE_VIRTUAL_DISK, FILE_REMOVABLE_MEDIA, FALSE, addr pDeviceObject
			.if eax == STATUS_SUCCESS
Fix
				lea ecx, g_usSymbolicLinkName
				movzx eax, (UNICODE_STRING PTR [ecx])._Length
				sub eax, 4
				add eax, (UNICODE_STRING PTR [ecx]).Buffer	; eax -> (WCHAR) '?'
				mov ecx, [esi].dwDriveLetter
				mov word ptr [eax], cx						; DriveLetter to g_usSymbolicLinkName

				invoke IoCreateSymbolicLink, addr g_usSymbolicLinkName, addr g_usDeviceName
				.if eax == STATUS_SUCCESS
					mov g_fSymbolicLinkCreated, TRUE

					mov eax, pDeviceObject
					mov (DEVICE_OBJECT PTR [eax]).AlignmentRequirement, FILE_WORD_ALIGNMENT
					or (DEVICE_OBJECT PTR [eax]).Flags, DO_DIRECT_IO

					; Round up number of root directories so it fills an even number of sectors
					mov eax, [esi].nRootDirectoryEntries
					add eax, DIR_ENTRIES_PER_SECTOR - 1
					mov ecx, DIR_ENTRIES_PER_SECTOR
					xor edx, edx
					div ecx
					mul ecx				; m_RootDirEntries = (nRootDirectoryEntries + DIR_ENTRIES_PER_SECTOR - 1) / DIR_ENTRIES_PER_SECTOR * DIR_ENTRIES_PER_SECTOR;
					mov [esi].nRootDirectoryEntries, eax

					invoke ExAllocatePoolWithTag, NonPagedPool, [esi].nDiskSize, 'DmaR'
					.if eax != NULL
						mov g_pImage, eax

						; Place an empty FAT file system on drive
						invoke FormatBootSector

						mov status, STATUS_SUCCESS
					.else
						invoke DbgPrint, $CTA0("RamDisk: Couldn't allocate memory for RamDisk\n")
					.endif
				.else
					invoke DbgPrint, $CTA0("RamDisk: Couldn't create symbolic link\n")
				.endif
			.else
				invoke DbgPrint, $CTA0("RamDisk: Couldn't create device\n")
			.endif
		.endif			; bad param passed
		assume esi:nothing
	.endif				; pCreateParams == NULL

	.if status != STATUS_SUCCESS
		; Cleanup un unsuccessful
		.if g_pImage != NULL
			invoke ExFreePool, g_pImage
			and g_pImage, NULL
		.endif
		invoke DeleteSymbolicLink
		.if pDeviceObject != NULL
			invoke IoDeleteDevice, pDeviceObject
		.endif
	.endif

	mov eax, status
	ret

CreateRamDisk endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                              QueryRamDiskParamsFromRegistry                                       
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

QueryRamDiskParamsFromRegistry proc pusRegistryPath:PUNICODE_STRING

local status:NTSTATUS
local oa:OBJECT_ATTRIBUTES
local hKey:HANDLE
local kvpi:KEY_VALUE_PARTIAL_INFORMATION

	mov status, STATUS_SUCCESS

	lea ecx, oa
	InitializeObjectAttributes ecx, pusRegistryPath, 0, NULL, NULL

	invoke ZwOpenKey, addr hKey, KEY_READ, ecx
	.if eax == STATUS_SUCCESS

		push eax
		invoke ZwQueryValueKey, hKey, $CCOUNTED_UNICODE_STRING("DriveLetter", 4), \
								KeyValuePartialInformation, addr kvpi, sizeof kvpi, esp
		pop ecx
		.if ( eax != STATUS_OBJECT_NAME_NOT_FOUND ) && ( ecx != 0 )
			push dword ptr (KEY_VALUE_PARTIAL_INFORMATION PTR [kvpi]).Data
			pop g_CreateParams.dwDriveLetter
		.else
			mov status, STATUS_UNSUCCESSFUL
		.endif


		push eax
		invoke ZwQueryValueKey, hKey, $CCOUNTED_UNICODE_STRING("DiskSize", 4), \
								KeyValuePartialInformation, addr kvpi, sizeof kvpi, esp
		pop ecx
		.if ( eax != STATUS_OBJECT_NAME_NOT_FOUND ) && ( ecx != 0 )
			push dword ptr (KEY_VALUE_PARTIAL_INFORMATION PTR [kvpi]).Data
			pop g_CreateParams.nDiskSize
		.else
			mov status, STATUS_UNSUCCESSFUL
		.endif


		push eax
		invoke ZwQueryValueKey, hKey, $CCOUNTED_UNICODE_STRING("RootDirectoryEntries", 4), \
								KeyValuePartialInformation, addr kvpi, sizeof kvpi, esp
		pop ecx
		.if ( eax != STATUS_OBJECT_NAME_NOT_FOUND ) && ( ecx != 0 )
			push dword ptr (KEY_VALUE_PARTIAL_INFORMATION PTR [kvpi]).Data
			pop g_CreateParams.nRootDirectoryEntries
		.else
			mov status, STATUS_UNSUCCESSFUL
		.endif


		push eax
		invoke ZwQueryValueKey, hKey, $CCOUNTED_UNICODE_STRING("SectorsPerCluster", 4), \
								KeyValuePartialInformation, addr kvpi, sizeof kvpi, esp
		pop ecx
		.if ( eax != STATUS_OBJECT_NAME_NOT_FOUND ) && ( ecx != 0 )
			push dword ptr (KEY_VALUE_PARTIAL_INFORMATION PTR [kvpi]).Data
			pop g_CreateParams.nSectorsPerCluster
		.else
			mov status, STATUS_UNSUCCESSFUL
		.endif

		invoke ZwClose, hKey

	.else
		mov status, STATUS_UNSUCCESSFUL
	.endif

	mov eax, status
	ret

QueryRamDiskParamsFromRegistry endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     IsRamDiskOpened                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IsRamDiskOpened proc

	xor eax, eax
	.if g_nOpenCount != 0
		inc eax						; return TRUE
	.endif

	ret

IsRamDiskOpened endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     DispatchCreate                                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DispatchCreate proc pDeviceObject:PDEVICE_OBJECT, pIrp:PIRP

	.if g_fRamDiskCreated == TRUE
		inc g_nOpenCount
	.endif

	mov eax, pIrp
	mov (_IRP PTR [eax]).IoStatus.Status, STATUS_SUCCESS
	and (_IRP PTR [eax]).IoStatus.Information, 0

	fastcall IofCompleteRequest, pIrp, IO_NO_INCREMENT

	mov eax, STATUS_SUCCESS
	ret

DispatchCreate endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       DispatchClose                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DispatchClose proc pDeviceObject:PDEVICE_OBJECT, pIrp:PIRP

	.if (g_fRamDiskCreated == TRUE) && (g_nOpenCount != 0)
		dec g_nOpenCount
	.else
		invoke DbgPrint, $CTA0("RamDisk: An attempt to close device handle. But OpenCount = 0\n")
	.endif

	mov eax, pIrp
	mov (_IRP PTR [eax]).IoStatus.Status, STATUS_SUCCESS
	and (_IRP PTR [eax]).IoStatus.Information, 0

	fastcall IofCompleteRequest, pIrp, IO_NO_INCREMENT

	mov eax, STATUS_SUCCESS
	ret

DispatchClose endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                             MmGetSystemAddressForMdlSafe                                          
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

MmGetSystemAddressForMdlSafe proc pMdl:PMDL, Priority:DWORD

	mov eax, pMdl
	assume eax:ptr MDL
	.if [eax].MdlFlags & MDL_MAPPED_TO_SYSTEM_VA + MDL_SOURCE_IS_NONPAGED_POOL
		mov eax, [eax].MappedSystemVa
	.else
		invoke MmMapLockedPagesSpecifyCache, pMdl, KernelMode, MmCached, NULL, FALSE, Priority
	.endif
	assume eax:nothing
	ret

MmGetSystemAddressForMdlSafe endp
			
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                    DispatchReadWrite                                              
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DispatchReadWrite proc uses esi edi pDeviceObject:PDEVICE_OBJECT, pIrp:PIRP

local p:PVOID

	mov esi, pIrp
	assume esi:ptr _IRP

	mov [esi].IoStatus.Status, STATUS_UNSUCCESSFUL
	and [esi].IoStatus.Information, 0

	IoGetCurrentIrpStackLocation esi
	mov edi, eax
	assume edi:ptr IO_STACK_LOCATION

	; Check for invalid parameters.  It is an error for the starting offset
	; + length to go past the end of the buffer, or for the length to
	; not be a proper multiple of the sector size.

	; IO_STACK_LOCATION.Parameters.Read and IO_STACK_LOCATION.Parameters.Write
	; are absolutely the same, so we use Read for both

	mov eax, [edi].Parameters.Read.ByteOffset.LowPart
	add eax, [edi].Parameters.Read._Length
	mov ecx, [edi].Parameters.Read._Length
	and ecx, BYTES_PER_SECTOR - 1
	.if ( eax <= g_CreateParams.nDiskSize ) && ( ecx == 0 )

		; Get a system-space pointer to the user's buffer
		.if [esi].MdlAddress != NULL

			invoke MmGetSystemAddressForMdlSafe, [esi].MdlAddress, NormalPagePriority
			.if eax != NULL
				mov p, eax

				mov eax, [edi].Parameters.Read._Length
				mov [esi].IoStatus.Information, eax

				mov eax, g_pImage
				add eax, [edi].Parameters.Read.ByteOffset.LowPart
				.if [edi].MajorFunction == IRP_MJ_READ
					invoke memcpy, p, eax, [esi].IoStatus.Information
				.elseif [edi].MajorFunction == IRP_MJ_WRITE
					invoke memcpy, eax, p, [esi].IoStatus.Information				
				.endif

				mov [esi].IoStatus.Status, STATUS_SUCCESS
			.else
				mov [esi].IoStatus.Status, STATUS_INSUFFICIENT_RESOURCES
				invoke DbgPrint, $CTA0("RamDisk: Couldn't get the system-space virtual address\n")
        	.endif
		.endif
	.else
		mov [esi].IoStatus.Status, STATUS_INVALID_PARAMETER
		invoke DbgPrint, $CTA0("RamDisk: Invalid Read or Write request\n")
	.endif

	assume edi:nothing

	fastcall IofCompleteRequest, esi, IO_NO_INCREMENT

	mov eax, [esi].IoStatus.Status
	assume esi:nothing

	ret

DispatchReadWrite endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                     DispatchControl                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DispatchControl proc uses esi edi pDeviceObject:PDEVICE_OBJECT, pIrp:PIRP

local status:NTSTATUS
local dwContext:DWORD

;	invoke DbgPrint, $CTA0("RamDisk: Entering DispatchControl\n")
Fix ADD LOCK
	mov esi, pIrp
	assume esi:ptr _IRP

	mov [esi].IoStatus.Status, STATUS_UNSUCCESSFUL
	and [esi].IoStatus.Information, 0

	IoGetCurrentIrpStackLocation esi
	mov edi, eax
	assume edi:ptr IO_STACK_LOCATION

	.if [edi].Parameters.DeviceIoControl.IoControlCode == IOCTL_REMOVE

		; Remove the drive letter associated with the ram disk.
		; This prevents new references to it from being established,
		; in preperation for deletion.

		invoke IsRamDiskOpened
		.if eax == FALSE
			; Delete the symbolic link created by the constructor
			invoke DeleteSymbolicLink
			mov [esi].IoStatus.Status, STATUS_SUCCESS
		.else
			mov [esi].IoStatus.Status, STATUS_DEVICE_BUSY
		.endif

	.elseif ([edi].Parameters.DeviceIoControl.IoControlCode == IOCTL_DISK_GET_MEDIA_TYPES) || ([edi].Parameters.DeviceIoControl.IoControlCode == IOCTL_DISK_GET_DRIVE_GEOMETRY)
		.if [edi].Parameters.DeviceIoControl.OutputBufferLength >= sizeof DISK_GEOMETRY

			; request information about the disk geometry

			mov edi, [esi].AssociatedIrp.SystemBuffer
			assume edi:ptr DISK_GEOMETRY

			mov [edi].MediaType, RemovableMedia
			mov eax, g_CreateParams.nDiskSize
			shr eax, 0Fh			; / BYTES_PER_SECTOR * SECTORS_PER_TRACK * TRACKS_PER_CYLINDER = 512*32*2
			mov [edi].Cylinders.LowPart, eax
			and [edi].Cylinders.HighPart, 0
			mov [edi].TracksPerCylinder, TRACKS_PER_CYLINDER
			mov [edi].SectorsPerTrack, SECTORS_PER_TRACK
			mov [edi].BytesPerSector, BYTES_PER_SECTOR

			mov [esi].IoStatus.Status, STATUS_SUCCESS
			mov [esi].IoStatus.Information, sizeof DISK_GEOMETRY

			assume edi:nothing
		.else
			mov [esi].IoStatus.Status, STATUS_INVALID_PARAMETER
		.endif

	assume edi:ptr IO_STACK_LOCATION
	.elseif [edi].Parameters.DeviceIoControl.IoControlCode == IOCTL_DISK_GET_PARTITION_INFO
		.if [edi].Parameters.DeviceIoControl.OutputBufferLength >= sizeof PARTITION_INFORMATION

			mov edi, [esi].AssociatedIrp.SystemBuffer
			assume edi:ptr PARTITION_INFORMATION

			; The offset in bytes on drive where the partition begins
			and [edi].StartingOffset.LowPart, 0
			and [edi].StartingOffset.HighPart, 0

			; The length in bytes of the partition
			mov eax, g_CreateParams.nDiskSize
			mov [edi].PartitionLength.LowPart, eax
			and [edi].PartitionLength.HighPart, 0

			; The number of hidden sectors
			mov [edi].HiddenSectors, 1

			; Specifies the number of the partition
			or [edi].PartitionNumber, -1

			; Indicates the system-defined MBR partition type
			mov eax, g_pImage
			mov al, (BOOT_SECTOR PTR [eax]).FileSystemType[4]
			.if al == '2'
				; a partition with 12-bit FAT entries
				mov [edi].PartitionType, PARTITION_FAT_12
			.else
				; a partition with 16-bit FAT entries
				mov [edi].PartitionType, PARTITION_FAT_16
			.endif

			; FALSE indicates that this partition is not bootable
			and [edi].BootIndicator, FALSE

			; TRUE indicates that the system recognized the type of the partition
			mov [edi].RecognizedPartition, TRUE

			; FALSE indicates that the partition information has not changed
			and [edi].RewritePartition, FALSE

			mov [esi].IoStatus.Status, STATUS_SUCCESS
			mov [esi].IoStatus.Information, sizeof PARTITION_INFORMATION

			assume edi:nothing
		.else
			mov [esi].IoStatus.Status, STATUS_INVALID_PARAMETER
		.endif

	assume edi:ptr IO_STACK_LOCATION
	.elseif [edi].Parameters.DeviceIoControl.IoControlCode == IOCTL_DISK_CHECK_VERIFY

		mov [esi].IoStatus.Status, STATUS_SUCCESS
		and [esi].IoStatus.Information, 0


	.elseif [edi].Parameters.DeviceIoControl.IoControlCode == IOCTL_DISK_IS_WRITABLE

		mov [esi].IoStatus.Status, STATUS_SUCCESS
		and [esi].IoStatus.Information, 0

	.else
		mov [esi].IoStatus.Status, STATUS_INVALID_DEVICE_REQUEST
	.endif

	assume edi:nothing

	fastcall IofCompleteRequest, esi, IO_NO_INCREMENT

;	invoke DbgPrint, $CTA0("RamDisk: Leaving DispatchControl\n")

	mov eax, [esi].IoStatus.Status
	assume esi:nothing

	ret

DispatchControl endp


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       RemoveRamDisk                                               
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

RemoveRamDisk proc uses esi pDeviceObject:PDEVICE_OBJECT

local status:NTSTATUS

	mov status, STATUS_UNSUCCESSFUL

	.if g_fRamDiskCreated == TRUE

		invoke IsRamDiskOpened
		.if eax == FALSE

			.if g_pImage != NULL
	
				invoke ExFreePool, g_pImage

				and g_pImage, NULL

				; Normaly the symbolic link should have been deleted.
				invoke DeleteSymbolicLink
				invoke IoDeleteDevice, pDeviceObject

				and g_fRamDiskCreated, FALSE

				mov status, STATUS_SUCCESS

			.else
				invoke DbgPrint, $CTA0("RamDisk: BAD. Disk image pointer = NULL\n")
			.endif
		.else
			invoke DbgPrint, $CTA0("RamDisk: An attempt to remove RamDisk but disk is opened\n")
		.endif
	.else
		invoke DbgPrint, $CTA0("RamDisk: BAD. Disk doesn't exist\n")
	.endif

	mov eax, status
	ret

RemoveRamDisk endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       DriverUnload                                                
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DriverUnload proc pDriverObject:PDRIVER_OBJECT

	mov eax, pDriverObject
	invoke RemoveRamDisk, (DRIVER_OBJECT PTR [eax]).DeviceObject
	ret

DriverUnload endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                              D I S C A R D A B L E   C O D E                                      
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

.code INIT

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                       DriverEntry                                                 
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DriverEntry proc pDriverObject:PDRIVER_OBJECT, pusRegistryPath:PUNICODE_STRING

local status:NTSTATUS
;local pDeviceObject:PDEVICE_OBJECT

	mov status, STATUS_DEVICE_CONFIGURATION_ERROR

	; Explicity initialize global variables
	xor eax, eax
	and g_fRamDiskCreated,		eax
	and g_fSymbolicLinkCreated,	eax
	and g_pImage,				eax
	and g_nOpenCount,			eax

	invoke QueryRamDiskParamsFromRegistry, pusRegistryPath
	.if eax == STATUS_SUCCESS
	
		invoke CreateRamDisk, pDriverObject
		.if eax == STATUS_SUCCESS
			mov g_fRamDiskCreated, TRUE

			mov eax, pDriverObject
			assume eax:ptr DRIVER_OBJECT
			mov [eax].MajorFunction[IRP_MJ_CREATE*(sizeof PVOID)],			offset DispatchCreate
			mov [eax].MajorFunction[IRP_MJ_CLOSE*(sizeof PVOID)],			offset DispatchClose
			mov [eax].MajorFunction[IRP_MJ_READ*(sizeof PVOID)],			offset DispatchReadWrite
			mov [eax].MajorFunction[IRP_MJ_WRITE*(sizeof PVOID)],			offset DispatchReadWrite
			mov [eax].MajorFunction[IRP_MJ_DEVICE_CONTROL*(sizeof PVOID)],	offset DispatchControl
			mov [eax].DriverUnload,											offset DriverUnload
			assume eax:nothing

			mov status, STATUS_SUCCESS

		.endif
	.else
		invoke DbgPrint, $CTA0("RamDisk: Couldn't get RamDisk parameters from the registry.\n")
	.endif

	mov eax, status
	ret

DriverEntry endp

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                                                                                   
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

end DriverEntry

:make

set drv=RamDisk

\masm32\bin\ml /nologo /c /coff %drv%.bat
\masm32\bin\link /nologo /driver /base:0x10000 /align:32 /out:%drv%.sys /subsystem:native /ignore:4078 %drv%.obj

del %drv%.obj
move %drv%.sys ..

echo.
pause
