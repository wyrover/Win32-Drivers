
RAMDISK_MEDIA_TYPE      equ 0F8h
DIR_ENTRIES_PER_SECTOR  equ 16

BYTES_PER_SECTOR		equ 512
SECTORS_PER_TRACK		equ 32
TRACKS_PER_CYLINDER		equ 2

BOOT_SECTOR STRUCT
	Jump				BYTE 3 dup(?)	; x86 jmp instruction, checked by FS
	OemName				BYTE 8 dup(?)	; OEM name of formatter
	BytesPerSector		WORD	?		; Bytes per Sector
	SectorsPerCluster	BYTE	?		; Sectors per Cluster
	ResSectors			WORD	?		; Reserved Sectors
	FATs				BYTE	?		; Number of FATs - we always use 1
	RootDirEntries		WORD	?		; Number of Root Dir Entries
	Sectors				WORD	?		; Number of Sectors
	Media				BYTE	?		; Media type - we use RAMDISK_MEDIA_TYPE
	FatSectors			WORD	?		; Number of FAT sectors
	SectorsPerTrack		WORD	?		; Sectors per Track - we use 32
	Heads				WORD	?		; Number of Heads - we use 2
	HiddenSectors		DWORD	?		; Hidden Sectors - we set to 0
	HugeSectors			DWORD	?		; Number of Sectors if > 32 MB size
	DriveNumber			BYTE	?		; Drive Number - not used
	Reserved1			BYTE	?		; Reserved
	BootSignature		BYTE	?		; New Format Boot Signature - 0x29
	VolumeID			DWORD	?		; VolumeID - set to 0x12345678
	_Label				BYTE 11 dup(?)	; Label - set to RamDisk
	FileSystemType		BYTE 8 dup(?)	; File System Type - FAT12 or FAT16
	Reserved2			BYTE 448 dup(?)	; Reserved
	Sig2				BYTE 2 dup(?)	; Originial Boot Signature - 0x55, 0xAA
BOOT_SECTOR ENDS
PBOOT_SECTOR typedef ptr BOOT_SECTOR

DIR_ENTRY STRUCT
	_Name				BYTE 8 dup(?)	; File Name
	Extension			BYTE 3 dup(?)	; File Extension
	Attributes			BYTE	?		; File Attributes
	Reserved			BYTE	?		; Reserved
	Time				WORD	?		; File Time
	Date				WORD	?		; File Date
	StartCluster		WORD	?		; First Cluster of file
	FileSize			DWORD	?		; File Length
DIR_ENTRY ENDS
PDIR_ENTRY typedef ptr DIR_ENTRY

; Directory Entry Attributes

DIR_ATTR_READONLY   equ 01h
DIR_ATTR_HIDDEN     equ 02h
DIR_ATTR_SYSTEM     equ 04h
DIR_ATTR_VOLUME     equ 08h
DIR_ATTR_DIRECTORY  equ 10h
DIR_ATTR_ARCHIVE    equ 20h
comment ^
DISK_GEOMETRY STRUCT
	Cylinders			_LARGE_INTEGER	<>
	MediaType			DWORD			?	; MEDIA_TYPE
	TracksPerCylinder	DWORD			?
	SectorsPerTrack		DWORD			?
	BytesPerSector		DWORD			?
DISK_GEOMETRY ENDS
PDISK_GEOMETRY typedef ptr DISK_GEOMETRY

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

PARTITION_INFORMATION STRUCT
	StartingOffset			_LARGE_INTEGER		<>
	PartitionLength			_LARGE_INTEGER		<>
	HiddenSectors			DWORD				?
	PartitionNumber			DWORD				?
	PartitionType			BYTE				?
	BootIndicator			BOOLEAN				?
	RecognizedPartition		BOOLEAN				?
	RewritePartition		BOOLEAN				?
PARTITION_INFORMATION ENDS
PPARTITION_INFORMATION typedef ptr PARTITION_INFORMATION
^