//
//  Driver.cpp
//  TestBench on VS2010
//
//  History:
//     Begin:  05:08 PM, Nov 08, 2007, by Zhang Fan
//     Change: 12:21 PM, Aug 19, 2015, by Mighten Dai <mighten.dai@gmail.com>
//
#include "Driver.h"

#pragma INITCODE

////////////////////////////////////////////////////////////////////////////
//        Name:   DriverEntry
// Description: Initialize Driver, locate & apply the hardware resource(s),
//                and also create the kernel object.
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//              -> pRegistryPath:  The Driver's path in Registry
//      Return: Driver's status.
//  *** NOTE that: Without extern "C", the compiler would trigger an LINK-time error.
////////////////////////////////////////////////////////////////////////////
extern "C" NTSTATUS DriverEntry (
            IN PDRIVER_OBJECT pDriverObject,
            IN PUNICODE_STRING pRegistryPath    ) 
{
    NTSTATUS status;
    KdPrint(("Enter DriverEntry\n"));

    // Register other CallBack-function's Entry
    pDriverObject->DriverUnload = HelloDDKUnload;
    pDriverObject->MajorFunction[IRP_MJ_CREATE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_CLOSE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_WRITE] = HelloDDKDispatchRoutine;
    pDriverObject->MajorFunction[IRP_MJ_READ] = HelloDDKDispatchRoutine;
    
    //Create Device object
    status = CreateDevice(pDriverObject);

    KdPrint(("DriverEntry end\n"));
    return status;
}

////////////////////////////////////////////////////////////////////////////
//        Name:   CreateDevice
// Description: Initialize Device.
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma INITCODE

NTSTATUS CreateDevice (
        IN PDRIVER_OBJECT    pDriverObject) 
{
    NTSTATUS status;
    PDEVICE_OBJECT pDevObj;
    PDEVICE_EXTENSION pDevExt;
    
    // Get prepared for creating --using Unicode String.
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

    // Symbolic link.
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

////////////////////////////////////////////////////////////////////////////
//        Name:   HelloDDKUnload
// Description: Uninstall Driver
//  Parameters: -> pDriverObject:  Object passed from I/O Manager
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma PAGEDCODE
VOID HelloDDKUnload (IN PDRIVER_OBJECT pDriverObject) 
{
    PDEVICE_OBJECT    pNextObj;
    KdPrint(("Enter DriverUnload\n"));
    pNextObj = pDriverObject->DeviceObject;
    
    // Traverse, to remove all of them
    while (pNextObj != NULL) 
    {
        PDEVICE_EXTENSION pDevExt = (PDEVICE_EXTENSION) pNextObj->DeviceExtension;
        //delete the symbolic link
        UNICODE_STRING pLinkName = pDevExt->ustrSymLinkName;
        IoDeleteSymbolicLink(&pLinkName);
        pNextObj = pNextObj->NextDevice;
        IoDeleteDevice( pDevExt->pDevice );
    }
}


////////////////////////////////////////////////////////////////////////////
//        Name: HelloDDKDispatchRoutine
// Description: Deal with IRP(I/O Request Package)
//  Parameters: -> pDevObj:  FDO
//              ->    pIrp:  IRP
//      Return: Driver's status.
////////////////////////////////////////////////////////////////////////////
#pragma PAGEDCODE
NTSTATUS HelloDDKDispatchRoutine(IN PDEVICE_OBJECT pDevObj,
                                 IN PIRP pIrp) 
{
    KdPrint(("Enter HelloDDKDispatchRoutine\n"));
    NTSTATUS status = STATUS_SUCCESS;
    // Complete IRP
    pIrp->IoStatus.Status = status;
    pIrp->IoStatus.Information = 0;
    IoCompleteRequest( pIrp, IO_NO_INCREMENT );
    KdPrint(("Leave HelloDDKDispatchRoutine\n"));
    return status;
}