//
//  Driver.h
//  
//  TestBench on VS2010
//
//  History:
//     Begin:  05:08 PM, Nov 08, 2007, by Zhang Fan
//     Change: 12:21 PM, Aug 19, 2015, by Mighten Dai <mighten.dai@gmail.com>
//
#pragma once

#ifdef __cplusplus
extern "C"{
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


typedef struct _DEVICE_EXTENSION
{
	PDEVICE_OBJECT pDevice;
	UNICODE_STRING ustrDeviceName;
	UNICODE_STRING ustrSymLinkName;
}  DEVICE_EXTENSION, *PDEVICE_EXTENSION;



////////////////////////////////////////////////////////////
// Function Declaration

NTSTATUS 
   CreateDevice( IN PDRIVER_OBJECT pDriverObject );

VOID
   HelloDDKUnload ( IN PDRIVER_OBJECT pDriverObject );

NTSTATUS
   HelloDDKDispatchRoutine( IN PDEVICE_OBJECT pDevObj, IN PIRP pIrp  );