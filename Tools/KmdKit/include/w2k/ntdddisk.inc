comment ^
Module Name:
    ntdddisk.inc

Abstract:
    This is the include file that defines all constants and types for
    accessing the Disk device.

Author:
    Four-F (four-f@mail.ru)

Last updated:
	26-November-2003
	
Comments:
    Some fields name have been changed because of collision with masm reserved words.
    All such words are prefixed with underscore ('_') symbol.
^

IFNDEF CTL_CODE
CTL_CODE MACRO DeviceType:=<0>, Function:=<0>, Method:=<0>, Access:=<0>
	EXITM %(((DeviceType) SHL 16) OR ((Access) SHL 14) OR ((Function) SHL 2) OR (Method))
ENDM
ENDIF

; IoControlCode values for disk devices.

IOCTL_DISK_BASE                 equ FILE_DEVICE_DISK
IOCTL_DISK_GET_DRIVE_GEOMETRY   equ CTL_CODE(IOCTL_DISK_BASE, 0000, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_GET_PARTITION_INFO   equ CTL_CODE(IOCTL_DISK_BASE, 0001, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_SET_PARTITION_INFO   equ CTL_CODE(IOCTL_DISK_BASE, 0002, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)
IOCTL_DISK_GET_DRIVE_LAYOUT     equ CTL_CODE(IOCTL_DISK_BASE, 0003, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_SET_DRIVE_LAYOUT     equ CTL_CODE(IOCTL_DISK_BASE, 0004, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)
IOCTL_DISK_VERIFY               equ CTL_CODE(IOCTL_DISK_BASE, 0005, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_FORMAT_TRACKS        equ CTL_CODE(IOCTL_DISK_BASE, 0006, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)
IOCTL_DISK_REASSIGN_BLOCKS      equ CTL_CODE(IOCTL_DISK_BASE, 0007, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)
IOCTL_DISK_PERFORMANCE          equ CTL_CODE(IOCTL_DISK_BASE, 0008, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_IS_WRITABLE          equ CTL_CODE(IOCTL_DISK_BASE, 0009, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_LOGGING              equ CTL_CODE(IOCTL_DISK_BASE, 000ah, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_FORMAT_TRACKS_EX     equ CTL_CODE(IOCTL_DISK_BASE, 000bh, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)
IOCTL_DISK_HISTOGRAM_STRUCTURE  equ CTL_CODE(IOCTL_DISK_BASE, 000ch, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_HISTOGRAM_DATA       equ CTL_CODE(IOCTL_DISK_BASE, 000dh, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_HISTOGRAM_RESET      equ CTL_CODE(IOCTL_DISK_BASE, 000eh, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_REQUEST_STRUCTURE    equ CTL_CODE(IOCTL_DISK_BASE, 000fh, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_DISK_REQUEST_DATA         equ CTL_CODE(IOCTL_DISK_BASE, 0010h, METHOD_BUFFERED, FILE_ANY_ACCESS)


;#if(_WIN32_WINNT >= 0x0400)
IOCTL_DISK_CONTROLLER_NUMBER    equ CTL_CODE(IOCTL_DISK_BASE, 0011h, METHOD_BUFFERED, FILE_ANY_ACCESS)

; IOCTL support for SMART drive fault prediction.

SMART_GET_VERSION               equ CTL_CODE(IOCTL_DISK_BASE, 0020h, METHOD_BUFFERED, FILE_READ_ACCESS)
SMART_SEND_DRIVE_COMMAND        equ CTL_CODE(IOCTL_DISK_BASE, 0021h, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)
SMART_RCV_DRIVE_DATA            equ CTL_CODE(IOCTL_DISK_BASE, 0022h, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)

;#endif /* _WIN32_WINNT >= 0x0400 */

;#if(_WIN32_WINNT >= 0x0500)
IOCTL_DISK_UPDATE_DRIVE_SIZE    equ CTL_CODE(IOCTL_DISK_BASE, 0032h, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)
IOCTL_DISK_GROW_PARTITION       equ CTL_CODE(IOCTL_DISK_BASE, 0034h, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)

IOCTL_DISK_GET_CACHE_INFORMATION equ CTL_CODE(IOCTL_DISK_BASE, 0035h, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_SET_CACHE_INFORMATION equ CTL_CODE(IOCTL_DISK_BASE, 0036h, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)

IOCTL_DISK_DELETE_DRIVE_LAYOUT  equ CTL_CODE(IOCTL_DISK_BASE, 0040h, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)

;  Special IOCTLs needed to support PC-98 machines in Japan

IOCTL_DISK_FORMAT_DRIVE         equ CTL_CODE(IOCTL_DISK_BASE, 00f3h, METHOD_BUFFERED, FILE_READ_ACCESS + FILE_WRITE_ACCESS)
IOCTL_DISK_SENSE_DEVICE         equ CTL_CODE(IOCTL_DISK_BASE, 00f8h, METHOD_BUFFERED, FILE_ANY_ACCESS)

;#endif /* _WIN32_WINNT >= 0x0500 */

; Internal disk driver device controls to maintain the verify status bit
; for the device object.

IOCTL_DISK_INTERNAL_SET_VERIFY   equ CTL_CODE(IOCTL_DISK_BASE, 0100h, METHOD_NEITHER, FILE_ANY_ACCESS)
IOCTL_DISK_INTERNAL_CLEAR_VERIFY equ CTL_CODE(IOCTL_DISK_BASE, 0101h, METHOD_NEITHER, FILE_ANY_ACCESS)

; Internal disk driver device control to set notification routine for
; the device object. Used in DiskPerf.

IOCTL_DISK_INTERNAL_SET_NOTIFY   equ CTL_CODE(IOCTL_DISK_BASE, 0102h, METHOD_BUFFERED, FILE_ANY_ACCESS)

; +
; The following device control codes are common for all class drivers.  The
; functions codes defined here must match all of the other class drivers.
;
; Warning: these codes will be replaced in the future by equivalent
; IOCTL_STORAGE codes
; -

IOCTL_DISK_CHECK_VERIFY     equ CTL_CODE(IOCTL_DISK_BASE, 0200h, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_MEDIA_REMOVAL    equ CTL_CODE(IOCTL_DISK_BASE, 0201h, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_EJECT_MEDIA      equ CTL_CODE(IOCTL_DISK_BASE, 0202h, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_LOAD_MEDIA       equ CTL_CODE(IOCTL_DISK_BASE, 0203h, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_RESERVE          equ CTL_CODE(IOCTL_DISK_BASE, 0204h, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_RELEASE          equ CTL_CODE(IOCTL_DISK_BASE, 0205h, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_FIND_NEW_DEVICES equ CTL_CODE(IOCTL_DISK_BASE, 0206h, METHOD_BUFFERED, FILE_READ_ACCESS)
IOCTL_DISK_GET_MEDIA_TYPES  equ CTL_CODE(IOCTL_DISK_BASE, 0300h, METHOD_BUFFERED, FILE_ANY_ACCESS)

; The following file contains the IOCTL_STORAGE class ioctls

include ntddstor.inc

; Define the partition types returnable by known disk drivers.

PARTITION_ENTRY_UNUSED          equ 00      ; Entry unused
PARTITION_FAT_12                equ 01      ; 12-bit FAT entries
PARTITION_XENIX_1               equ 02      ; Xenix
PARTITION_XENIX_2               equ 03      ; Xenix
PARTITION_FAT_16                equ 04      ; 16-bit FAT entries
PARTITION_EXTENDED              equ 05      ; Extended partition entry
PARTITION_HUGE                  equ 06      ; Huge partition MS-DOS V4
PARTITION_IFS                   equ 07      ; IFS Partition
PARTITION_OS2BOOTMGR            equ 0Ah      ; OS/2 Boot Manager/OPUS/Coherent swap
PARTITION_FAT32                 equ 0Bh      ; FAT32
PARTITION_FAT32_XINT13          equ 0Ch      ; FAT32 using extended int13 services
PARTITION_XINT13                equ 0Eh      ; Win95 partition using extended int13 services
PARTITION_XINT13_EXTENDED       equ 0Fh      ; Same as type 5 but uses extended int13 services
PARTITION_PREP                  equ 41h      ; PowerPC Reference Platform (PReP) Boot Partition
PARTITION_LDM                   equ 42h      ; Logical Disk Manager partition
PARTITION_UNIX                  equ 63h      ; Unix

VALID_NTFT                      equ C0h      ; NTFT uses high order bits

; The high bit of the partition type code indicates that a partition
; is part of an NTFT mirror or striped array.

PARTITION_NTFT                  equ 80h     ; NTFT partition

; Define the media types supported by the driver.

;typedef enum _MEDIA_TYPE {
    Unknown			equ 0	; Format is unknown
    F5_1Pt2_512		equ 1	; 5.25", 1.2MB,  512 bytes/sector
    F3_1Pt44_512	equ 2	; 3.5",  1.44MB, 512 bytes/sector
    F3_2Pt88_512	equ 3	; 3.5",  2.88MB, 512 bytes/sector
    F3_20Pt8_512	equ 4	; 3.5",  20.8MB, 512 bytes/sector
    F3_720_512		equ 5	; 3.5",  720KB,  512 bytes/sector
    F5_360_512		equ 6	; 5.25", 360KB,  512 bytes/sector
    F5_320_512		equ 7	; 5.25", 320KB,  512 bytes/sector
    F5_320_1024		equ 8	; 5.25", 320KB,  1024 bytes/sector
    F5_180_512		equ 9	; 5.25", 180KB,  512 bytes/sector
    F5_160_512		equ 10	; 5.25", 160KB,  512 bytes/sector
    RemovableMedia	equ 11	; Removable media other than floppy
    FixedMedia		equ 12	; Fixed hard disk media
    F3_120M_512		equ 13	; 3.5", 120M Floppy
    F3_640_512		equ 14	; 3.5" ,  640KB,  512 bytes/sector
    F5_640_512		equ 15	; 5.25",  640KB,  512 bytes/sector
    F5_720_512		equ 16	; 5.25",  720KB,  512 bytes/sector
    F3_1Pt2_512		equ 17	; 3.5" ,  1.2Mb,  512 bytes/sector
    F3_1Pt23_1024	equ 18	; 3.5" ,  1.23Mb, 1024 bytes/sector
    F5_1Pt23_1024	equ 19	; 5.25",  1.23MB, 1024 bytes/sector
    F3_128Mb_512	equ 20	; 3.5" MO 128Mb   512 bytes/sector
    F3_230Mb_512	equ 21	; 3.5" MO 230Mb   512 bytes/sector
    F8_256_128		equ 22	; 8",     256KB,  128 bytes/sector

; Define the input buffer structure for the driver, when
; it is called with IOCTL_DISK_FORMAT_TRACKS.

FORMAT_PARAMETERS STRUCT
	MediaType			DWORD	?	; MEDIA_TYPE
	StartCylinderNumber	DWORD	?
	EndCylinderNumber	DWORD	?
	StartHeadNumber		DWORD	?
	EndHeadNumber		DWORD	?
FORMAT_PARAMETERS ENDS
PFORMAT_PARAMETERS typedef ptr FORMAT_PARAMETERS

; Define the BAD_TRACK_NUMBER type. An array of elements of this type is
; returned by the driver on IOCTL_DISK_FORMAT_TRACKS requests, to indicate
; what tracks were bad during formatting. The length of that array is
; reported in the `Information' field of the I/O Status Block.

BAD_TRACK_NUMBER typedef WORD
PBAD_TRACK_NUMBER typedef ptr WORD

; Define the input buffer structure for the driver, when
; it is called with IOCTL_DISK_FORMAT_TRACKS_EX.

FORMAT_EX_PARAMETERS STRUCT
	MediaType			DWORD	?	; MEDIA_TYPE
	StartCylinderNumber	DWORD	?
	EndCylinderNumber	DWORD	?
	StartHeadNumber		DWORD	?
	EndHeadNumber		DWORD	?
	FormatGapLength		WORD	?
	SectorsPerTrack		WORD	?
	SectorNumber		WORD 1 dup(?)
						WORD	?	; padding
FORMAT_EX_PARAMETERS ENDS
PFORMAT_EX_PARAMETERS typedef ptr FORMAT_EX_PARAMETERS

; The following structure is returned on an IOCTL_DISK_GET_DRIVE_GEOMETRY
; request and an array of them is returned on an IOCTL_DISK_GET_MEDIA_TYPES
; request.

DISK_GEOMETRY STRUCT
	Cylinders			LARGE_INTEGER	<>
	MediaType			DWORD	?	; MEDIA_TYPE
	TracksPerCylinder	DWORD	?
	SectorsPerTrack		DWORD	?
	BytesPerSector		DWORD	?
DISK_GEOMETRY ENDS
PDISK_GEOMETRY typedef ptr DISK_GEOMETRY

; The following structure is returned on an IOCTL_DISK_GET_PARTITION_INFO
; and an IOCTL_DISK_GET_DRIVE_LAYOUT request.  It is also used in a request
; to change the drive layout, IOCTL_DISK_SET_DRIVE_LAYOUT.

PARTITION_INFORMATION STRUCT		; sizeof = 20h
	StartingOffset		LARGE_INTEGER	<>
	PartitionLength		LARGE_INTEGER	<>
	HiddenSectors		DWORD		?
	PartitionNumber		DWORD		?
	PartitionType		BYTE		?
	BootIndicator		BOOLEAN		?
	RecognizedPartition	BOOLEAN		?
	RewritePartition	BOOLEAN		?
						DWORD		?	; padding
PARTITION_INFORMATION ENDS
PPARTITION_INFORMATION typedef ptr PARTITION_INFORMATION

; The following structure is used to change the partition type of a
; specified disk partition using an IOCTL_DISK_SET_PARTITION_INFO
; request.

SET_PARTITION_INFORMATION STRUCT
	PartitionType	BYTE	?	; UCHAR
SET_PARTITION_INFORMATION ENDS
PSET_PARTITION_INFORMATION typedef ptr SET_PARTITION_INFORMATION

; The following structures is returned on an IOCTL_DISK_GET_DRIVE_LAYOUT
; request and given as input to an IOCTL_DISK_SET_DRIVE_LAYOUT request.

DRIVE_LAYOUT_INFORMATION  STRUCT	; sizeof = 28h
	PartitionCount		DWORD	?
	Signature			DWORD	?
	PartitionEntry		PARTITION_INFORMATION 1 dup(<>)
DRIVE_LAYOUT_INFORMATION ENDS
PDRIVE_LAYOUT_INFORMATION typedef ptr DRIVE_LAYOUT_INFORMATION

; The following structure is passed in on an IOCTL_DISK_VERIFY request.
; The offset and length parameters are both given in bytes.

VERIFY_INFORMATION  STRUCT
	StartingOffset	LARGE_INTEGER	<>
	_Length			DWORD			?
					DWORD			?	; pad
VERIFY_INFORMATION ENDS
PVERIFY_INFORMATION typedef ptr VERIFY_INFORMATION

; The following structure is passed in on an IOCTL_DISK_REASSIGN_BLOCKS
; request.

REASSIGN_BLOCKS  STRUCT
	Reserved		WORD	?
	Count			WORD	?
	BlockNumber		DWORD 1 dup(?)
REASSIGN_BLOCKS ENDS
PREASSIGN_BLOCKS typedef ptr REASSIGN_BLOCKS

;#if(_WIN32_WINNT >= 0x0500)

DISK_GEOMETRY_EX  STRUCT			; sizeof = 28h
	Geometry	DISK_GEOMETRY	<>	; Standard disk geometry: may be faked by driver.
	DiskSize	LARGE_INTEGER	<>	; Must always be correct
	Data		BYTE 1 dup(?)		; UCHAR Partition, Detect info
				BYTE 7 dup(?)		; pad
DISK_GEOMETRY_EX ENDS
PDISK_GEOMETRY_EX typedef ptr DISK_GEOMETRY_EX

;#endif // (_WIN32_WINNT > 0x0500)

;#if(_WIN32_WINNT >= 0x0400)

; IOCTL_DISK_CONTROLLER_NUMBER returns the controller and disk
; number for the handle.  This is used to determine if a disk
; is attached to the primary or secondary IDE controller.

DISK_CONTROLLER_NUMBER  STRUCT
	ControllerNumber	DWORD	?
	DiskNumber			DWORD	?
DISK_CONTROLLER_NUMBER ENDS
PDISK_CONTROLLER_NUMBER typedef ptr DISK_CONTROLLER_NUMBER

;#endif /* _WIN32_WINNT >= 0x0400 */

;#if(_WIN32_WINNT >= 0x0500)

; +
; IOCTL_DISK_SET_CACHE allows the caller to get or set the state of the disk
; read/write caches.
;
; If the structure is provided as the input buffer for the ioctl the read &
; write caches will be enabled or disabled depending on the parameters
; provided.
;
; If the structure is provided as an output buffer for the ioctl the state
; of the read & write caches will be returned. If both input and outut buffers
; are provided the output buffer will contain the cache state BEFORE any
; changes are made
; -

;typedef enum {
    EqualPriority		equ 0
    KeepPrefetchedData	equ 1
    KeepReadData		equ 2
;} DISK_CACHE_RETENTION_PRIORITY;


DISK_CACHE_INFORMATION  STRUCT			; sizeof = 18h

	; on return indicates that the device is capable of saving any parameters
	; in non-volatile storage.  On send indicates that the device should
	; save the state in non-volatile storage.

	ParametersSavable			BOOLEAN	?

	; Indicates whether the write and read caches are enabled.

	ReadCacheEnabled			BOOLEAN	?
	WriteCacheEnabled			BOOLEAN	?
								BYTE	?	; pad

	; Controls the likelyhood of data remaining in the cache depending on how
	; it got there.  Data cached from a READ or WRITE operation may be given
	; higher, lower or equal priority to data entered into the cache for other
	; means (like prefetch)

	ReadRetentionPriority		DWORD	?	; DISK_CACHE_RETENTION_PRIORITY
	WriteRetentionPriority		DWORD	?	; DISK_CACHE_RETENTION_PRIORITY

	; Requests for a larger number of blocks than this may have prefetching
	; disabled.  If this value is set to 0 prefetch will be disabled.

	DisablePrefetchTransferLength	WORD	?

	; If TRUE then ScalarPrefetch (below) will be valid.  If FALSE then
	; the minimum and maximum values should be treated as a block count
	; (BlockPrefetch)

	PrefetchScalar				BOOLEAN	?
								BYTE	?	; pad

	; Contains the minimum and maximum amount of data which will be
	; will be prefetched into the cache on a disk operation.  This value
	; may either be a scalar multiplier of the transfer length of the request,
	; or an abolute number of disk blocks.  PrefetchScalar (above) indicates
	; which interpretation is used.

	union								; 010h
		struct ScalarPrefetch
			Minimum				WORD	?
			Maximum				WORD	?

        	; The maximum number of blocks which will be prefetched - useful
        	; with the scalar limits to set definite upper limits.

			MaximumBlocks		WORD	?
								WORD	?	; pad
		ends	; ScalarPrefetch

		struct BlockPrefetch
			Minimum				WORD	?
			Maximum				WORD	?
		ends	; BlockPrefetch
	ends

DISK_CACHE_INFORMATION ENDS
PDISK_CACHE_INFORMATION typedef ptr DISK_CACHE_INFORMATION

; IOCTL_DISK_GROW_PARTITION will update the size of a partition
; by adding sectors to the length. The number of sectors must be
; predetermined by examining PARTITION_INFORMATION.

DISK_GROW_PARTITION STRUCT
	PartitionNumber		DWORD	?
						DWORD	?	; pad
	BytesToGrow			LARGE_INTEGER <>
DISK_GROW_PARTITION ENDS
PDISK_GROW_PARTITION typedef ptr DISK_GROW_PARTITION

;#endif /* _WIN32_WINNT >= 0x0500 */
