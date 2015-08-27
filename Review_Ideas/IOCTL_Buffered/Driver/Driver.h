//
//  Driver.h
//  Direct I/O Header file.
//
//  History:
//     Begin:  Nov 01, 2007, by Zhang Fan
//     Change: 01:49 PM, Aug 24, 2015, by Mighten Dai <mighten.dai@gmail.com>
//
#pragma once

#ifdef __cplusplus
extern "C"
{
#endif
#include <NTDDK.h>
#ifdef __cplusplus
}
#endif 

#define PAGEDCODE code_seg("PAGE")
#define LOCKEDCODE code_seg()
#define INITCODE code_seg("INIT")

#define PAGEDDATA data_seg("PAGE")
#define LOCKEDDATA data_seg()
#define INITDATA data_seg("INIT")

#define arraysize(p) (sizeof(p)/sizeof((p)[0]))

#define MAX_FILE_LENGTH 1024

typedef struct _DEVICE_EXTENSION {
	PDEVICE_OBJECT pDevice;
	UNICODE_STRING ustrDeviceName;
	UNICODE_STRING ustrSymLinkName;

	PUCHAR     buffer;
	ULONG      file_length;  //  The length of file imitated , less than or equal to MAX_FILE_LENGTH
} DEVICE_EXTENSION, *PDEVICE_EXTENSION;

////////////////////////////////////////////////////////////
// Function Declaration
NTSTATUS   CreateDevice(    IN PDRIVER_OBJECT pDriverObject );
VOID       HelloDDKUnload(  IN PDRIVER_OBJECT pDriverObject );
NTSTATUS   HelloDDKDispatchRoutine(IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp);
NTSTATUS   HelloDDKDeviceIOControl(IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp);