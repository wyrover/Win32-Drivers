//
//   Lookaside.cpp
//
//   The more efficient way of managing your driver's memory accessing, especially when:
//    > allocating of fixed size every time
//    > frequently allocating/releasing
//
//   History:
//    10:24 PM, Aug 22, 2015, by Mighten Dai <mighten.dai@gmail.com>\
//        Original Author: Zhang Fan, wrote it in Nov 01, 2007
//
#include "Driver.h"

typedef struct _MYDATASTRUCT 
{
    CHAR buffer[64];

} MYDATASTRUCT, *PMYDATASTRUCT;


VOID LookasideTest() 
{
    PAGED_LOOKASIDE_LIST     pageList;
    ExInitializePagedLookasideList( &pageList, 
                                    NULL, NULL, 0, sizeof(MYDATASTRUCT),
                                    '1234',  // Single-quotation mark is required by MSDN
                                    0 );

#define ARRAY_NUMBER 50
    PMYDATASTRUCT MyObjectArray[ARRAY_NUMBER];

    // imitate for frequently allocation 
    for (int i=0;i<ARRAY_NUMBER;i++)
    {
        MyObjectArray[i] = (PMYDATASTRUCT)ExAllocateFromPagedLookasideList(&pageList);
    }

    // simulate Frequently recycling
    for (i=0;i<ARRAY_NUMBER;i++)
    {
        ExFreeToPagedLookasideList(&pageList,MyObjectArray[i]);
        MyObjectArray[i] = NULL;
    }

    //  Delete this Lookaside Object.
    ExDeletePagedLookasideList(&pageList);
}






extern "C" NTSTATUS DriverEntry (
            IN PDRIVER_OBJECT pDriverObject,
            IN PUNICODE_STRING pRegistryPath    ) 
{
    NTSTATUS status;
    KdPrint(("Enter DriverEntry\n"));

    pDriverObject->DriverUnload = HelloDDKUnload;
    pDriverObject->MajorFunction[IRP_MJ_CREATE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_CLOSE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_WRITE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_READ] = HelloDDKDispatchRoutine;
    
    status = CreateDevice(pDriverObject);

    /////////////////////////
    // Do this test.
    LookasideTest();

    KdPrint(("DriverEntry end\n"));
    return status;
}

NTSTATUS CreateDevice (
        IN PDRIVER_OBJECT    pDriverObject) 
{
    NTSTATUS status;
    PDEVICE_OBJECT pDevObj;
    PDEVICE_EXTENSION pDevExt;
    
    UNICODE_STRING devName;
    RtlInitUnicodeString(&devName,L"\\Device\\MyDDKDevice");
    
    status = IoCreateDevice( pDriverObject,
                        sizeof(DEVICE_EXTENSION),
                        &(UNICODE_STRING)devName,
                        FILE_DEVICE_UNKNOWN,
                        0, TRUE,
                        &pDevObj );
    if (!NT_SUCCESS(status))
        return status;

    pDevObj->Flags |= DO_BUFFERED_IO;
    pDevExt = (PDEVICE_EXTENSION)pDevObj->DeviceExtension;
    pDevExt->pDevice = pDevObj;
    pDevExt->ustrDeviceName = devName;

    UNICODE_STRING symLinkName;
    RtlInitUnicodeString(&symLinkName,L"\\??\\HelloDDK");
    pDevExt->ustrSymLinkName = symLinkName;
    status = IoCreateSymbolicLink( &symLinkName,&devName );
    if (!NT_SUCCESS(status)) 
    {
        IoDeleteDevice( pDevObj );
        return status;
    }
    return STATUS_SUCCESS;
}

VOID HelloDDKUnload (IN PDRIVER_OBJECT pDriverObject) 
{
    PDEVICE_OBJECT    pNextObj;
    KdPrint(("Enter DriverUnload\n"));
    pNextObj = pDriverObject->DeviceObject;
    while (pNextObj != NULL) 
    {
        PDEVICE_EXTENSION pDevExt = (PDEVICE_EXTENSION)
            pNextObj->DeviceExtension;

        UNICODE_STRING pLinkName = pDevExt->ustrSymLinkName;
        IoDeleteSymbolicLink(&pLinkName);
        pNextObj = pNextObj->NextDevice;
        IoDeleteDevice( pDevExt->pDevice );
    }
}

NTSTATUS HelloDDKDispatchRoutine(IN PDEVICE_OBJECT pDevObj,
                                 IN PIRP pIrp) 
{
    KdPrint(("Enter HelloDDKDispatchRoutine\n"));
    NTSTATUS status = STATUS_SUCCESS;

    pIrp->IoStatus.Status = status;
    pIrp->IoStatus.Information = 0;    // bytes processed.
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );
    KdPrint(("Leave HelloDDKDispatchRoutine\n"));
    return status;
}